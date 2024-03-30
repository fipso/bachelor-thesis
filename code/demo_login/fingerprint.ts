import * as tls from "tls";
import * as net from "net";
import * as crypto from "crypto";

import {
  TlsHelloData,
  NonTlsError,
  TlsFingerprintData,
  readTlsClientHello,
  calculateJa3FromFingerprintData,
} from "read-tls-client-hello";

interface SocketWithHello extends net.Socket {
  tlsClientHello?: TlsHelloData & {
    ja3: string;
    ja3n: string;
  };
}

function calculateJa3nFromFingerprintData(fingerprintData: TlsFingerprintData) {
  const fingerprintString = [
    fingerprintData[0],
    fingerprintData[1].join("-"),
    fingerprintData[2].join("-"),
    fingerprintData[3].join("-"),
    fingerprintData[4].join("-"),
  ].join(",");

  console.log(fingerprintString);
  return crypto.createHash("md5").update(fingerprintString).digest("hex");
}

export function trackClientHellosJA3N(tlsServer: tls.Server) {
  // Disable the normal TLS 'connection' event listener that triggers TLS setup:
  const tlsConnectionListener = tlsServer.listeners("connection")[0] as (
    socket: net.Socket,
  ) => {};
  if (!tlsConnectionListener)
    throw new Error("TLS server is not listening for connection events");
  tlsServer.removeListener("connection", tlsConnectionListener);

  // Listen ourselves for connections, get the fingerprint first, then let TLS setup resume:
  tlsServer.on("connection", async (socket: SocketWithHello) => {
    try {
      const helloData = await readTlsClientHello(socket);

      // Clone the fingerprint data and sort the cipher suites:
      const sortedFingerprintData: TlsFingerprintData = [
        ...helloData.fingerprintData,
      ];
      sortedFingerprintData[2].sort((a, b) => a - b);

      socket.tlsClientHello = {
        ...helloData,
        ja3: calculateJa3FromFingerprintData(helloData.fingerprintData),
        ja3n: calculateJa3nFromFingerprintData(sortedFingerprintData),
      };
    } catch (e) {
      if (!(e instanceof NonTlsError)) {
        // Ignore totally non-TLS traffic
        console.warn(
          `TLS client hello data not available for TLS connection from ${socket.remoteAddress ?? "unknown address"
          }: ${(e as Error).message ?? e}`,
        );
      }
    }

    // Once we have a fingerprint, TLS handshakes can continue as normal:
    tlsConnectionListener.call(tlsServer, socket);
  });

  tlsServer.prependListener("secureConnection", (tlsSocket: tls.TLSSocket) => {
    const fingerprint = (
      tlsSocket as unknown as {
        _parent?: SocketWithHello; // Private TLS socket field which points to the source
      }
    )._parent?.tlsClientHello;

    tlsSocket.tlsClientHello = fingerprint;
  });

  return tlsServer;
}

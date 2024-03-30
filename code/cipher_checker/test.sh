#!/bin/bash

openssl s_server -key key.pem -cert cert.pem -accept 4433 -www -cipher AES128-SHA

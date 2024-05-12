#!/bin/bash

mkdir -p ./results

set -x

LINKS=$(cat <<-END
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1002910%2Fchrome-linux.zip?generation=1652397748160413&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1012728%2Fchrome-linux.zip?generation=1654813044687278&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1027016%2Fchrome-linux.zip?generation=1658444558797678&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1036826%2Fchrome-linux.zip?generation=1660863194027156&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1047731%2Fchrome-linux.zip?generation=1663284576100523&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1058929%2Fchrome-linux.zip?generation=1665698229213169&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1070081%2Fchrome-linux.zip?generation=1668128442427342&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1084013%2Fchrome-linux.zip?generation=1671143102457414&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1097615%2Fchrome-linux.zip?generation=1674770404921951&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1109227%2Fchrome-linux.zip?generation=1677190965902746&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1121454%2Fchrome-linux.zip?generation=1679615088078954&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1135561%2Fchrome-linux.zip?generation=1682460989187924&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1148123%2Fchrome-linux.zip?generation=1684872500557151&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1160321%2Fchrome-linux.zip?generation=1687302633318707&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1181205%2Fchrome-linux.zip?generation=1691535836009137&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1192597%2Fchrome-linux.zip?generation=1693941360490354&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F278853%2Fchrome-linux.zip?generation=1409173614427000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F290041%2Fchrome-linux.zip?generation=1408145710479000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F297061%2Fchrome-linux.zip?generation=1411772636477000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F303346%2Fchrome-linux.zip?generation=1415411634057000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F310958%2Fchrome-linux.zip?generation=1420863187459000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F317475%2Fchrome-linux.zip?generation=1424482407864000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F323860%2Fchrome-linux.zip?generation=1428109484099000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F330230%2Fchrome-linux.zip?generation=1431733405301000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F338391%2Fchrome-linux.zip?generation=1436571219937000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F344923%2Fchrome-linux.zip?generation=1440202523283000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F352221%2Fchrome-linux.zip?generation=1443837963036000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F359699%2Fchrome-linux.zip?generation=1447461020145000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F369908%2Fchrome-linux.zip?generation=1452908937590000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F378083%2Fchrome-linux.zip?generation=1456540849047000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F386249%2Fchrome-linux.zip?generation=1460160957434000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F394941%2Fchrome-linux.zip?generation=1463707821323000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F403380%2Fchrome-linux.zip?generation=1467337264475000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F414611%2Fchrome-linux.zip?generation=1472175396541000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F423768%2Fchrome-linux.zip?generation=1475803306647000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F433062%2Fchrome-linux.zip?generation=1479441205933000&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F444952%2Fchrome-linux.zip?generation=1484879539443735&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F454471%2Fchrome-linux.zip?generation=1488508639164020&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F464640%2Fchrome-linux.zip?generation=1492132669264150&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F474896%2Fchrome-linux.zip?generation=1495769528204931&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F488525%2Fchrome-linux.zip?generation=1500599293181584&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F499100%2Fchrome-linux.zip?generation=1504229071612724&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F508578%2Fchrome-linux.zip?generation=1507857679993878&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F520842%2Fchrome-linux.zip?generation=1512100890521163&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F530372%2Fchrome-linux.zip?generation=1516324133092465&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F540276%2Fchrome-linux.zip?generation=1519938236072713&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F550430%2Fchrome-linux.zip?generation=1523579512891725&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F561732%2Fchrome-linux.zip?generation=1527214387802166&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F576753%2Fchrome-linux.zip?generation=1532051976706023&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F587811%2Fchrome-linux.zip?generation=1535668921668411&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F599034%2Fchrome-linux.zip?generation=1539304759226495&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F612434%2Fchrome-linux.zip?generation=1543535498055804&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F625894%2Fchrome-linux.zip?generation=1548376675982715&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F638880%2Fchrome-linux.zip?generation=1552011881622744&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F652428%2Fchrome-linux.zip?generation=1555635894690119&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F665006%2Fchrome-linux.zip?generation=1559267949433976&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F681090%2Fchrome-linux.zip?generation=1564102126574765&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F693954%2Fchrome-linux.zip?generation=1567721852304759&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F706915%2Fchrome-linux.zip?generation=1571324979333057&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F722276%2Fchrome-linux.zip?generation=1575588380806233&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F737173%2Fchrome-linux.zip?generation=1580437726966456&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F756066%2Fchrome-linux.zip?generation=1585871012733067&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F768959%2Fchrome-linux.zip?generation=1589490727542041&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F782790%2Fchrome-linux.zip?generation=1593134686327030&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F800217%2Fchrome-linux.zip?generation=1597947119541943&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F812847%2Fchrome-linux.zip?generation=1601580735246625&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F827102%2Fchrome-linux.zip?generation=1605233458736188&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F843831%2Fchrome-linux.zip?generation=1610673097470630&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F857949%2Fchrome-linux.zip?generation=1614303515285625&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F870763%2Fchrome-linux.zip?generation=1617926496067901&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F885292%2Fchrome-linux.zip?generation=1621556096601725&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F902218%2Fchrome-linux.zip?generation=1626393405764176&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F911494%2Fchrome-linux.zip?generation=1628813235731791&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F920005%2Fchrome-linux.zip?generation=1631232582939202&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F929513%2Fchrome-linux.zip?generation=1633657173061773&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F938554%2Fchrome-linux.zip?generation=1636066888482178&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F950363%2Fchrome-linux.zip?generation=1639099175425223&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F961656%2Fchrome-linux.zip?generation=1642723767466615&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F972765%2Fchrome-linux.zip?generation=1645149566184332&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F982481%2Fchrome-linux.zip?generation=1647559751806495&alt=media
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F992740%2Fchrome-linux.zip?generation=1649975445134595&alt=media
END
)

function runWithURL {
  # Spawn container
  containerId=$(podman run -d cipher_checker)
  # Copy dependency installer script
  podman cp ./install_deps.sh $containerId:/app/install_deps.sh
  # Download and run chrome 
  podman exec $containerId /bin/bash -c "cd /app && wget -O chromium.zip '$1' && unzip chromium.zip && ./install_deps.sh ./chrome-linux/chrome && cd ./chrome-linux && bash -c 'Xvfb :99 -ac -screen 0 640x480x8 -nolisten tcp &' && ./chrome --no-sandbox --no-first-run --no-zygote --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage https://ba-testing.unsafe.blazed.win:8443/check.html"
  echo "Container ID: $containerId"
  #podman logs -f --tail 100 $containerId
  podman cp $containerId:/app/result.json ./results/$containerId.json
}

job=0
while IFS= read -r line; do
  job=$((job+1))
  runWithURL $line &> ./jobs/$job.txt &
done <<< "$LINKS"

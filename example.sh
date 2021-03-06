#!/bin/bash

set -e #Exit on failure.
set -x
export POST_FETCH_STEP="echo 'no unzip required'"

if [ "$(uname)" == "Darwin" ]; then
    export FETCH_URL="https://s3-us-west-2.amazonaws.com/imageflow-resources/prototype_releases/0.0.2/mac_64/flow-proto1"
    export APP_NAME=flow-proto1
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    export FETCH_URL="https://s3-us-west-2.amazonaws.com/imageflow-resources/prototype_releases/0.0.2/linux_64/flow-proto1"
    export APP_NAME=flow-proto1
    ldd --version
elif [ "$(expr substr $(uname -s) 1 4)" == "MSYS" ]; then
    export FETCH_URL="https://s3-us-west-2.amazonaws.com/imageflow-resources/prototype_releases/0.0.2/win_64/flow-proto1-0.0.2.zip"
    export POST_FETCH_STEP="7z e flow-proto1-0.0.2.zip"
    export APP_NAME=flow-proto1.exe
else
  echo "Unknown platform $(uname -s)"
  exit 1
fi

echo "Fetching app"

rm ${APP_NAME} || true
rm -rf fetch_dir
mkdir fetch_dir
cd fetch_dir
wget ${FETCH_URL}
${POST_FETCH_STEP}
cp ${APP_NAME} ../${APP_NAME}
cd ..

chmod +x ./${APP_NAME}


echo "Printing app help"
./${APP_NAME} --help

wget -nc  http://s3-us-west-2.amazonaws.com/imageflow-resources/test_inputs/rings2.png
wget -nc  http://s3-us-west-2.amazonaws.com/imageflow-resources/test_inputs/waterhouse.jpg
wget -nc  http://s3-us-west-2.amazonaws.com/imageflow-resources/test_inputs/gamma_test.jpg
wget -nc -O should_be_blue.jpg http://images.cameratico.com/media/images/tools/browser-color-management/MarsRGB_tagged.jpg || true

wget -nc https://kornel.ski/en/color/odd.png
wget -nc https://kornel.ski/en/color/srgb.jpg

echo "Generating sizes from waterhouse.jpg"
./${APP_NAME} -i waterhouse.jpg -o waterhouse_200px_catrom_sharpen30.png -w 200 -h 200 --sharpen 30 --format png --down-filter catrom
./${APP_NAME} -i waterhouse.jpg -o waterhouse_200px_catrom.png -w 200 -h 200 --format png --down-filter catrom
./${APP_NAME} -i waterhouse.jpg -o waterhouse_200px_robidouxsharp.png -w 200 -h 200 --format png --down-filter robidouxsharp
./${APP_NAME} -i waterhouse.jpg -o waterhouse_600px_catrom_sharpen30.png -w 600 -h 600 --sharpen 30 --format png --down-filter catrom
./${APP_NAME} -i waterhouse.jpg -o waterhouse_600px_catrom.png -w 600 -h 600 --format png --down-filter catrom
./${APP_NAME} -i waterhouse.jpg -o waterhouse_600px_robidouxsharp.png -w 600 -h 600 --format png --down-filter robidouxsharp

# flow-proto1 doesn't yet support jpeg ICC profiles. When it does, uncomment this
#./${APP_NAME} -i should_be_blue.jpg -o should_be_blue_50px.png -w 50 -h 50 --format png 

# But this does/should work
./${APP_NAME} -i odd.png -o should_match_srgb_jpg.png -w 500 -h 500 --format png 

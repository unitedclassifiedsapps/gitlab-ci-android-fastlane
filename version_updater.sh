# This moves to your default Android app folder, change if you've named it something else
cd app
curl -O playstorepage https://play.google.com/store/apps/details\?id\=<YourBundleID>
sleep 10
# This block grabs the version number from the html and adds +1 to the end
CURRENTLIVE=`cat playstorepage | grep -i "Current Version" | grep -oh -P '(\d+\.\d+\.\d+)'`
STARTLIVE=`echo $CURRENTLIVE | sed -rn 's/([0-9]+).([0-9]+).([0-9]+)/\1/p'`
MIDDLELIVE=`echo $CURRENTLIVE | sed -rn 's/([0-9]+).([0-9]+).([0-9]+)/\2/p'`
ENDLIVE=`echo $CURRENTLIVE | sed -rn 's/([0-9]+).([0-9]+).([0-9]+)/\3/p'`
REPLACE=$(($ENDLIVE+1))
# This block grabs the version from your gradle file
BUILD=`cat build.gradle | grep -i "buildVersionName" | grep -oh -P '(\d*\.\d*\.\d*)'`
BUILDNUMBER=`cat build.gradle | grep -i "buildVersionCode" | grep -oh -P '(\d*)'`
STARTBUILD=`echo $BUILD | sed -rn 's/([0-9]+).([0-9]+).([0-9]+)/\1/p'`
MIDDLEBUILD=`echo $BUILD | sed -rn 's/([0-9]+).([0-9]+).([0-9]+)/\2/p'`
ENDBUILD=`echo $BUILD | sed -rn 's/([0-9]+).([0-9]+).([0-9]+)/\3/p'`
# This part compares the two, if any part of the gradle file is 
# higer than the one taked from the website it keeps the gradle version
if (( $STARTLIVE < $STARTBUILD )) || (( $MIDDLELIVE < $MIDDLEBUILD )) || (( $REPLACE -lt $ENDBUILD ));
then  FINAL=`echo "$BUILD"`; 
else FINAL=`echo "$STARTLIVE.$MIDDLELIVE.$REPLACE"`; 
fi
sed -i 's/'$BUILD'/'$FINAL'/g' build.gradle
# This line uses build tools like Jenkins varables to change the build number
sed -i 's/'$BUILDNUMBER'/'$BUILD_NUMBER'/g' build.gradle

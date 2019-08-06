mkdir -p one-click-deploy
cp *sh one-click-deploy/
cp *tf one-click-deploy
rm -f one-click-deploy/make-ocd.sh
zip -r one-click-deploy.zip one-click-deploy
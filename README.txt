curl -L http://cpanmin.us | perl - --sudo App::cpanminus
dzil installdeps | cpanm

./bin/pa deploy
sudo ./bin/pa dhcpdmonitor

plackup -Ilib lib/PeopleAPI/App/Web.pm
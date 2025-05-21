 #!/bin/bash
        PACKAGE="apache2 wget unzip"
		    SVC="apache2"
		    URL='https://www.tooplate.com/zip-templates/2098_health.zip'
		    ART_NAME='2098_health'
		    TEMPDIR="/tmp/webfiles"
  
		    sudo apt update
		    sudo apt upgrade
		    sudo apt install $PACKAGE -y > /dev/null
		    sudo systemctl start $SVC
		    sudo systemctl enable $SVC
		    sudo mkdir -p $TEMPDIR
		    sudo cd $TEMPDIR
		    sudo wget $URL > /dev/null
		    sudo unzip $ART_NAME.zip > /dev/null
		    sudo cp -r $ART_NAME/* /var/www/html/
		    sudo systemctl restart $SVC
		    sudo rm -rf $TEMPDIR
		    sudo systemctl status $SVC
		    ls /var/www/html/
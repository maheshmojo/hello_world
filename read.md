Now create a tomcat group.

sudo groupadd tomcat
Next, create a new user having name tomcat . Now you have to make this user a member of the tomcat group, with a home directory of /opt/tomcat and with a shell of /bin/false

sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
Tomcat is required to configure. So you have to configure tomcat. First go to /tmp folder by changing directory.

cd /tmp
Download tomcat war file from tomcat website by running command

wget http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.5/bin/apache-tomcat-8.5.5.tar.gz
We will install Tomcat to the /opt/tomcat directory. Create the directory, then extract the archive to that folder.

sudo mkdir /opt/tomcat
and

sudo tar xzvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
Change to the directory where you unpacked the Tomcat.

cd /opt/tomcat
Then give the ownership to tomcat group over the entire installation directory:

sudo chgrp -R tomcat /opt/tomcat
Next, give the tomcat group read access to the conf directory and all of its contents, and execute access to the directory itself:

sudo chmod -R g+r conf
and

sudo chmod g+x conf
Make the tomcat user the owner of the webapps, work, temp, and logs directories.

sudo chown -R tomcat webapps/ work/ temp/ logs/
Now you need to configure systemd service file of tomcat and need to set JAVA_HOME. To look up JAVA_HOME location run this command

sudo update-java-alternatives -l
You will get output like this

java-1.8.0-openjdk-amd64       1081       /usr/lib/jvm/java-1.8.0-openjdk-amd64
Copy the path /usr/lib/jvm/java-1.8.0-openjdk-amd64 somewhere. You will need this path to set JAVA_HOME later. In your system JAVA_HOME can be different, so don’t worry.

You need to configure tomcat.service. That resides in /etc/systemd/system directory. Run command

sudo nano /etc/systemd/system/tomcat.service
You will get a empty file opening. You need to paste this

[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
You need to replace the path that is made bold with your systems’ JAVA_HOME path you are asked to saved earlier. Be careful, don’t delete /jre after your JAVA_HOME path. For the first time I didn’t notice /jre and deleted, as a result I was getting error. For saving this service click Ctrl+x then Shift+y then Enter.

As you have edited tomcat.service file you need to reload the systemd daemon so that it knows about your service file. Run command

sudo systemctl daemon-reload
Run tomcat by this command

sudo systemctl start tomcat
To check tomcat status whether it is running or not, run command

sudo systemctl status tomcat
In order to use the manager web app that comes with Tomcat, you must add a login credential to our Tomcat server. We will do this by editing the tomcat-users.xml file. You have to add a user who can access the manager-gui, admin-gui and manager-script. To open tomcat-users.xml run command

sudo nano /opt/tomcat/conf/tomcat-users.xml
When the xml file is opened you need to add this line

<user username="admin" password="password" roles="manager-gui,admin-gui, manager-script"/>
inside

<tomcat-users . . .>
.....
</tomcat-users>
To save this xml file click Ctrl+x then Shift+y then Enter.

By default, newer versions of Tomcat restrict access to the Manager apps to connections coming from the server itself. Since you are installing on a remote machine, you will probably want to remove or alter this restriction. To change the IP address restrictions on these, open the appropriate context.xml files. Run the below command to open context.xml file.

sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
You will see something like.

<Context antiResourceLocking="false" privileged="true" >
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
</Context>
You need to comment complete <Valve .. /> tag like the bellow one

<Context antiResourceLocking="false" privileged="true" >
  <!--<Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />-->
</Context>
To save this xml file click Ctrl+x then Shift+y then Enter.

To put our changes into effect, restart the Tomcat service

sudo systemctl restart tomcat
Open your web browser and hit with address

http://server_domain_or_IP:8080
If you see something like this image, congratulation! you configured tomcat successfully.


If you hit with address http://server_domain_or_IP:8080/manager/html username and password will be asked. Put username and password you configured in tomcat-users.xml. You will see a dashboard like


At the last of the image you can see option for uploading war file. Upload war file and hit deploy.

If your war file is larger than 50MB tomcat won’t allow you to upload war file. To get rid of this problem you have to maximize upload file size. You can do it in web.xml file of tomcat. Run command

sudo nano /opt/tomcat/webapps/manager/WEB-INF/web.xml
In web.xml file you can see something like

<multipart-config>
   <max-file-size>52428800</max-file-size>
   <max-request-size>52428800</max-request-size>
   <file-size-threshold>0</file-size-threshold>
</multipart-config>
You have to double the file size.52428800 to 104857600. To save the change click Ctrl+x then Shift+y then Enter. Restart tomcat to get affect of changes by running command

sudo systemctl restart tomcat

#!/bin/bash
sudo apt update -y
sudo pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
sudo systemctl start pm2-root
sudo systemctl enable pm2-root 
sudo pm2 start aws_three_tier_code/backend/index.js --name "backendApi"
sudo apt install mysql-server -y 
mysql -h book.rds.com -u admin -ppassword123 test < aws_three_tier_code/backend/test.sql
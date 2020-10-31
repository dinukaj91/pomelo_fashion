#! /bin/bash
sudo apt-get update

sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<h1>Pomelo Production Website</h1>" >> /var/www/html/index.html
echo "<h3>Deployed via Terraform</h3>" >> /var/www/html/index.html

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
chmod +x ./awslogs-agent-setup.py


#! /bin/bash
sudo apt-get update

sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<h1>Pomelo Production Website</h1>" >> /var/www/html/index.html
echo "<h3>Deployed via Terraform</h3>" >> sudo tee /var/www/html/index.html

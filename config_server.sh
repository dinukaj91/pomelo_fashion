#! /bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo "<h1>Pomelo Production Website</h1>" | sudo tee /var/www/html/index.html
echo "<h2>Deployed via Terraform</h2>" | sudo tee /var/www/html/index.html

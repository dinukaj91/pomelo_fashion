#! /bin/bash
sudo apt-get update

sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<h1>Pomelo Production Website</h1>" >> /var/www/html/index.html
echo "<h3>Deployed via Terraform</h3>" >> /var/www/html/index.html

cat <<EOT >> cloudwatch_agent_config_file
[general]
state_file = /var/awslogs/state/agent-state
 
[/var/log/nginx/access.log]
file = /var/log/nginx/access.log
log_group_name = nginx_access_log
log_stream_name = pomelo_website
datetime_format = %b %d %H:%M:%S

[/var/log/nginx/error.log]
file = /var/log/nginx/error.log
log_group_name = nginx_error_log
log_stream_name = pomelo_website
datetime_format = %b %d %H:%M:%S
EOT

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
chmod +x ./awslogs-agent-setup.py
./awslogs-agent-setup.py -n -r us-west-2 -c cloudwatch_agent_config_file
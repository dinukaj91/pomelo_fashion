#! /bin/bash
sudo apt-get update

sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<h1>Pomelo Production Website</h1>" >> /var/www/html/index.html
echo "<h3>Deployed via Terraform</h3>" >> /var/www/html/index.html



wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
chmod +x ./amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

cat <<EOT >> /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/cloudwatch_agent_config_file
{
  "agent": {
	"metrics_collection_interval": 10,
	"logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
	"logs_collected": {
	  "files": {
		"collect_list": [
		  {
			"file_path": "/var/log/nginx/access.log",
			"log_group_name": "nginx_access.log",
			"timezone": "Local",
			"log_stream_name": "pomelo_website"
		  },
		  {
			"file_path": "/var/log/nginx/error.log",
			"log_group_name": "nginx_error.log",
			"timezone": "Local",
			"log_stream_name": "pomelo_website"
		  }
		]
	  }
	},
	"force_flush_interval" : 15
  }
}
EOT

systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent
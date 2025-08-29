#!/bin/bash

# Update system
yum update -y

# Install PostgreSQL
amazon-linux-extras install postgresql14 -y

# Start and enable PostgreSQL service
systemctl start postgresql
systemctl enable postgresql

# Switch to postgres user and configure database
sudo -u postgres psql << EOF
ALTER USER postgres PASSWORD '${db_password}';
CREATE DATABASE ${db_name};
GRANT ALL PRIVILEGES ON DATABASE ${db_name} TO postgres;
\q
EOF

# Configure PostgreSQL to accept local connections
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/g" /var/lib/pgsql/data/postgresql.conf
sed -i "s/#port = 5432/port = 5432/g" /var/lib/pgsql/data/postgresql.conf

# Configure pg_hba.conf for local connections
echo "local   all             postgres                                md5" > /var/lib/pgsql/data/pg_hba.conf
echo "host    all             postgres        127.0.0.1/32            md5" >> /var/lib/pgsql/data/pg_hba.conf
echo "host    all             postgres        ::1/128                 md5" >> /var/lib/pgsql/data/pg_hba.conf

# Restart PostgreSQL to apply changes
systemctl restart postgresql

# Install Java (for Spring Boot application)
yum install -y java-11-amazon-corretto

# Create application directory
mkdir -p /opt/bookreview
chown ec2-user:ec2-user /opt/bookreview

# Install nginx for reverse proxy (optional)
yum install -y nginx
systemctl start nginx
systemctl enable nginx

echo "PostgreSQL installation and configuration completed!"
echo "Database: ${db_name}"
echo "User: ${db_user}"
echo "Host: localhost"
echo "Port: 5432"


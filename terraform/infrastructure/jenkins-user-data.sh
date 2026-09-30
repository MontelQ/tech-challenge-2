#!/bin/bash
set -euo pipefail

dnf install -y java-21-amazon-corretto-headless git docker unzip awscli-2

curl --fail --silent --show-error --location \
  --retry 5 \
  https://pkg.jenkins.io/rpm-stable/jenkins.repo \
  --output /etc/yum.repos.d/jenkins.repo

rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
dnf install -y jenkins-2.568.3

mkdir -p /etc/systemd/system/jenkins.service.d
cat > /etc/systemd/system/jenkins.service.d/override.conf <<'SERVICE'
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Xms256m -Xmx1024m"
SERVICE

systemctl daemon-reload
systemctl enable --now amazon-ssm-agent
systemctl enable --now docker
systemctl enable --now jenkins

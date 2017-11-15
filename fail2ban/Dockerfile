FROM superitman/fail2ban:latest
MAINTAINER recursethis

COPY filter.d/zfaucet.conf /etc/fail2ban/filter.d/zfaucet.conf
COPY jail.conf /etc/fail2ban/jail.conf
COPY jail.local /etc/fail2ban/jail.local

RUN touch /var/log/auth.log

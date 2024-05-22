FROM postgres:15.5

COPY backup_script.sh /usr/local/bin/backup_script.sh
RUN chmod +x /usr/local/bin/backup_script.sh

CMD ["backup_script.sh"]
#!/bin/bash

# name="John"
# age=25
# echo "Name: $name, Age: $age"


# echo "**** Conditions ****"
# if [ $age -ge 18 ]; then
#     echo "Adult"
# else
#     echo "Minor"
# fi

# echo "**** For Loop ****"
# for i in 1 2 3 4 5; do
#     echo "Number: $i"
# done


# echo "**** While Loop ****"
# count=1
# while [ $count -le 5 ]; do
#     echo "Count: $count"
#     count=$((count + 1))
# done


echo "**** Files Management ****"
# DIR_PATH="./files"
# FILE_PATH="./files/data.csv"

# if [ -f "$FILE_PATH" ]; then
#   echo "File exists: $FILE_PATH"

#   ls -l "$DIR_PATH"

#   cat "$FILE_PATH"

#   echo $FILE_PATH > './new_file.csv'

#   echo "appended data !" >> './new_file.csv'

#   cp './new_file.csv' "$DIR_PATH/new_file.csv"
#   rm "./new_file.csv"
#   mv "$DIR_PATH/new_file.csv" './new_file.csv' 

# else
#   echo "File does not exist: $FILE_PATH"
#   exit 1
# fi

# health check system cpu, ram, network, disk
#!/bin/bash

WATCH_DIR="./files"  # Directory to watch
BACKUP_DIR="./backups"      # Directory to store backups
DB_NAME="mydb"     # PostgreSQL database name
DB_USER="myuser"         # PostgreSQL user
DB_HOST="localhost"         # PostgreSQL host
DB_PORT="5432"              # PostgreSQL port
CPU_THRESHOLD=80            # CPU usage threshold (%)
MEMORY_THRESHOLD=80         # Memory usage threshold (%)
DISK_THRESHOLD=90           # Disk usage threshold (%)
LOG_FILE="./health_log.txt" # Log file for health checks

# Function to watch directory and log changes
watch_directory() {
  echo "Watching directory: $WATCH_DIR"
  inotifywait -m -e create -e delete -e modify --format '%T %w %f %e' "$WATCH_DIR" --timefmt '%d-%m-%Y %H:%M:%S' |
  while read -r timestamp dir file event; do
    echo "$timestamp - File $file in directory $dir was $event" >> "./directory_changes.log"
  done
}

# Function to backup PostgreSQL database, compress, and encrypt
backup_database() {
  local date_str
  date_str=$(date +'%d-%m-%Y')
  local backup_file="${BACKUP_DIR}/${date_str}.backup.sql.gz"
  local encrypted_file="${BACKUP_DIR}/${date_str}.backup.sql.gz.enc"

  mkdir -p "$BACKUP_DIR"
  pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" | gzip > "$backup_file"
  openssl enc -aes-256-cbc -salt -in "$backup_file" -out "$encrypted_file" -pass pass:password
  rm "$backup_file"

  echo "Backup created and encrypted: $encrypted_file"
}

# Function to monitor system health
check_health() {
  local cpu_usage
  cpu_usage=$(top -bn1 | grep "%CPU" | awk '{print $2 + $4}')
  if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
    echo "$(date): High CPU usage detected: ${cpu_usage}%" >> "$LOG_FILE"
    # echo "CPU usage is above threshold!" | mail -s "High CPU Alert" your_email@example.com
  fi

  local memory_usage
  memory_usage=$(free | awk '/Mem:/ {print $3/$2 * 100.0}')
  if (( $(echo "$memory_usage > $MEMORY_THRESHOLD" | bc -l) )); then
    echo "$(date): High Memory usage detected: ${memory_usage}%" >> "$LOG_FILE"
    # echo "Memory usage is above threshold!" | mail -s "High Memory Alert" your_email@example.com
  fi

  local disk_usage
  disk_usage=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
  if (( disk_usage > 80 )); then
    echo "$(date): High Disk usage detected: ${disk_usage}%" >> "$LOG_FILE"
    # echo "Disk usage is above threshold!" | mail -s "High Disk Alert" your_email@example.com
  fi

  local network_usage
  network_usage=$(cat /proc/net/dev | grep eth0 | awk '{print $2}')
  if (( network_usage > 100000 )); then
    echo "$(date): High Network usage detected: ${network_usage} packets received" >> "$LOG_FILE"
    echo "Network usage is above threshold!" | mail -s "High Network Alert" your_email@example.com
  fi
}

# watch_directory
backup_database
check_health

# Schedule daily database backup at 00:00 using cron (automatically setup)
# schedule_backup() {
#   local cron_job="0 0 * * * /path/to/your/script.sh backup"
#   (crontab -

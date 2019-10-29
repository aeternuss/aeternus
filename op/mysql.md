# MySQL

## Arguments

- --character-set-server=utf8mb4
- --explicit-defaults-for-timestamp=true
- --ignore-db-dir=lost+found

# Upgrade

- Verify definitions

  ```bash
  mysqldump --all-databases --no-data --routines --events > dump-defs.sql
  mysql < dump-defs.sql
  ```

- Loading data

  ```bash
  mysqldump --all-databases --no-create-info > dump-data.sql
  mysql < dump-data.sql
  ```

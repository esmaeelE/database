# Database Project — Suggested Improvements

> Compiled from project analysis + ShellCheck audit (2026-09-27).
> Target: 4 shell scripts (backup.sh, create_db_table.sh, monitor.sh, restore.sh).

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [ShellCheck Audit Results](#2-shellcheck-audit-results)
3. [Critical Security Fixes](#3-critical-security-fixes)
4. [Robust Error Handling & Validation](#4-robust-error-handling--validation)
5. [Code Modernization & Refactoring](#5-code-modernization--refactoring)
6. [Automation & Monitoring](#6-automation--monitoring)
7. [Testing & Validation](#7-testing--validation)
8. [Documentation Improvements](#8-documentation-improvements)
9. [Implementation Roadmap](#9-implementation-roadmap)

---

## 1. Project Overview

A database learning & utility repository for MariaDB / MySQL, PostgreSQL, and MSSQL.

```
database/
├── scripts/                 # Shell utility scripts
│   ├── backup.sh           # Database backup to compressed archive
│   ├── create_db_table.sh  # Create databases & tables
│   ├── monitor.sh          # Monitor MariaDB process list
│   ├── restore.sh          # Restore from tar.gz dump
│   ├── info.sql            # Database statistics query
│   ├── man.md              # Command reference
│   ├── mis.md              # Common MariaDB commands
│   ├── search.md           # Search examples
│   ├── select.md           # SELECT query patterns
│   └── users.md            # User management examples
├── docker/                 # Docker configurations
│   ├── mariadb/            # MariaDB Docker setup
│   ├── postgres.yml        # PostgreSQL Docker config
│   ├── mssql.yml          # MS SQL Server Docker config
│   ├── mongo_pg.yml       # MongoDB + PostgreSQL combo
│   └── ui/                 # GUI configs (pgadmin, dbeaver)
└── topics/                 # Documentation & learning material
```

### Current Issues (high-level)

- **No set -euo pipefail** — silent failures in backup/restore pipelines
- **Hardcoded credentials** in scripts and docs
- **No input validation** — db_name from db_names.txt interpolated directly into SQL
- **Incomplete backup** — retention (KEEP_DAY, BACKUP_DIR) defined but commented out
- **Fragile restore** — ls | grep pattern breaks on spaces in filenames
- **monitor.sh has no shebang**

---

## 2. ShellCheck Audit Results

ShellCheck 0.10.0, run on all .sh files: **16 findings — 1 error, 4 warning, 11 note.**

### error (1)

| File:Line | Code | Issue |
|---|---|---|
| scripts/monitor.sh:1:1 | SC2148 | No shebang. File is bare NOW=$(date ...), so run target unknown. Uses pipe pipelines + tee -> needs #!/usr/bin/env bash. |

### warning (4)

| File:Line | Code | Issue |
|---|---|---|
| backup.sh:39 | SC2034 | BACKUP_DIR appears unused (retention find is commented out at line 92). |
| backup.sh:41 | SC2034 | KEEP_DAY appears unused — same cause. |
| backup.sh:72:45 | SC2140 | "$DESTINATION/$dbname"_"$DATE".sql.gz parsed as A"B"C. Should be "$DESTINATION/${dbname}_${DATE}.sql.gz". |
| restore.sh:52 | SC2010 | ls -1U $SOURCE | grep breaks on spaces in filenames. |

### note (11)

All unquoted expansions (SC2086) or quoting style:

| File:Line | Issue |
|---|---|
| backup.sh:79 | tar -cvf $SEND/$DATE.tar -C $DESTINATION/ |
| backup.sh:84 | scp $SEND/$DATE.tar user@1.1.1.1:/var/archive/tar (also hardcoded host) |
| backup.sh:66 | SC2162 — read without -r mangles backslashes in db names |
| create_db_table.sh:45 | echo "Error Create Database" $db_name |
| create_db_table.sh:49 | mariadb ... -e "CREATE DATABASE IF NOT EXISTS $db_name" |
| create_db_table.sh:54 | echo "Error Create Table inside" $db_name |
| restore.sh:46 | echo "now extract ...", $TARFILE, $SOURCE |
| restore.sh:49 | tar xvf $TARFILE -C $SOURCE |
| restore.sh:57 | gunzip -k $SOURCE/$item |
| restore.sh:59 | echo $FILENAME |
| restore.sh:60 | mariadb ... < $SOURCE/$FILENAME |

### Real bugs hiding behind the notes

1. **restore.sh:60** — $FILENAME="${item%.*}" strips .gz. If backup creates <db>_<DATE>.sql.gz, gunzip -k yields <db>_<DATE>.sql, and ${item%.*} on <db>_<DATE>.sql.gz strips one extension -> <db>_<DATE>.sql. Works only if the dumped filename convention matches. Not enforced anywhere — coupled by string convention, not a shared variable.
2. **restore.sh:41** — arg check (if [ -z "$TARFILE" ]) happens after mkdir -p $SOURCE, so a no-arg run still creates a directory before erroring.
3. **No set -e/set -u** in any script — backup.sh pipeline failures are silent; a failed scp still logs ***END BACKUP PROCEDURE***.

---

## 3. Critical Security Fixes

### 3.1 Remove Hardcoded Credentials

```bash
# INSTEAD OF:
SECRET="/opt/scripts/run/secrets/root@localhost.cnf"

# USE:
SECRET="${XDG_CONFIG_HOME:-$HOME/.config}/db-credentials.cnf"
```

- Move .cnf files to ~/.config/db-credentials/ with chmod 600.
- Reference via env var: DB_CREDS="${DB_CREDS:-$HOME/.config/db-credentials.cnf}".

### 3.2 Encrypt Credentials

```bash
# Generate encrypted credential file
gpg --symmetric --cipher-algo AES256 "$HOME/.config/db-credentials.cnf"

# Decrypt at runtime
gpg --decrypt "$HOME/.config/db-credentials.gpg" > /tmp/db-creds.$$.cnf
mariadb --defaults-extra-file=/tmp/db-creds.$$.cnf ...
rm -f /tmp/db-creds.$$.cnf
```

### 3.3 Fix Password Exposure in Docs

In scripts/users.md, scripts/man.md:
```markdown
# INSTEAD OF:
CREATE USER 'zuser'@'%' IDENTIFIED by '!@#nalkfinalkHkkmsknn;ifdovn!@#' ;

# USE:
CREATE USER 'zuser'@'%' IDENTIFIED BY "$(openssl rand -base64 32)";
```

### 3.4 RCE / SQL Injection Prevention

Add an allowlist guard before any SQL interpolation:

```bash
validate_db_name() {
    local name="$1"
    if ! [[ "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
        echo "ERROR: Invalid database name: $name" >&2
        return 1
    fi
}
```

Apply in create_db_table.sh line 40, and any other interpolation points.

### 3.5 Secure Connection Files

- Replace ~/root@localhost.cnf references with chmod 600 enforced at script start.
- Add a check_credentials function that verifies file permissions before use.

---

## 4. Robust Error Handling & Validation

### 4.1 Add set -euo pipefail to All Scripts

```bash
#!/usr/bin/env bash
set -euo pipefail
```

This catches:
- Undefined variable usage (-u)
- Any command failure (-e)
- Pipeline failures (pipefail)

### 4.2 Add Rollback Function

```bash
rollback() {
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] Operation failed, rolling back..."
    # Remove partial backups, temp files, etc.
}
trap rollback ERR
```

### 4.3 Fix restore.sh Argument Order

```bash
#!/usr/bin/env bash
set -euo pipefail

TARFILE="${1:-}"
SOURCE="extract/"

if [ -z "$TARFILE" ]; then
    echo "Usage: $0 <tarfile>" >&2
    exit 1
fi

mkdir -p "$SOURCE"
# ... rest of script
```

### 4.4 Validate db_names.txt Entries

```bash
while IFS="" read -r p || [ -n "$p" ]; do
    db_name=$(basename "$p")
    validate_db_name "$db_name" || continue  # or exit
    ...
done < db_names.txt
```

---

## 5. Code Modernization & Refactoring

### 5.1 Standardize Shebangs

All scripts should start with:
```bash
#!/usr/bin/env bash
```

### 5.2 Fix backup.sh Naming Bug (SC2140)

```bash
# BEFORE:
/usr/bin/gzip -c -9 > "$DESTINATION/$dbname"_"$DATE".sql.gz;

# AFTER:
/usr/bin/gzip -c -9 > "$DESTINATION/${dbname}_${DATE}.sql.gz"
```

### 5.3 Fix restore.sh Filename Parsing (SC2010)

```bash
# BEFORE:
files=$(ls -1U "$SOURCE" | grep -E "\\.gz$")

# AFTER:
shopt -s nullglob
files=("$SOURCE"*.gz)
for item in "${files[@]}"; do
    ...
done
```

### 5.4 Fix backup.sh read (SC2162)

```bash
# BEFORE:
/usr/bin/mariadb ... | while read dbname; do

# AFTER:
/usr/bin/mariadb ... | while read -r dbname; do
```

### 5.5 Quote All Expansions

Apply SC2086 fixes across all scripts. Pattern:
```bash
# BEFORE:
tar xvf $TARFILE -C $SOURCE

# AFTER:
tar xvf "$TARFILE" -C "$SOURCE"
```

### 5.6 Extract Common Functions

Create scripts/lib/db-common.sh:
```bash
#!/usr/bin/env bash

LOGGER() {
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] $*"
}

check_credentials() {
    local creds="$1"
    [ -f "$creds" ] || { echo "Missing credentials file"; exit 1; }
    [ "$(stat -c %a "$creds")" -le 600 ] || { echo "Credentials too open"; exit 1; }
}

validate_db_name() {
    [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 1
}
```

Source it in each script:
```bash
source "$(dirname "$0")/lib/db-common.sh"
```

### 5.7 Fix monitor.sh Shebang

```bash
#!/usr/bin/env bash
NOW=$(date +%Y%m%d_%H%M%S)
mariadb --defaults-extra-file="${DB_CREDS:-$HOME/secret/secret.cnf}" \
    --table -e "SHOW PROCESSLIST\G" \
    | grep Info \
    | grep -v processlist \
    | grep -v "Info: NULL" \
    | tee "${NOW}.txt"
```

---

## 6. Automation & Monitoring

### 6.1 Enable Backup Retention (Currently Commented Out)

```bash
# Activate in backup.sh after backup completes:
/usr/bin/find "$BACKUP_DIR" -name "*.tar" -mtime +"$KEEP_DAY" -delete
LOGGER "Deleted backups older than $KEEP_DAY days"
```

### 6.2 Add Backup Verification

```bash
verify_backup() {
    local archive="$1"
    if ! tar -tzf "$archive" >/dev/null 2>&1; then
        LOGGER "CRITICAL: Backup corrupted: $archive"
        notify_admins "Backup verification failed: $archive"
        return 1
    fi
    LOGGER "Backup verified: $archive"
}
```

### 6.3 Add Health Check Function

```bash
check_database_health() {
    local aborted
    aborted=$(mariadb --defaults-extra-file="$DB_CREDS" -N \
        -e "SHOW STATUS LIKE 'Aborted_clients';" 2>/dev/null | awk '{print $2}')
    if [ "${aborted:-0}" -gt 0 ]; then
        LOGGER "WARNING: $aborted aborted clients detected"
    fi
}
```

### 6.4 Implement Log Rotation

Add to all scripts that write output:
```bash
# Rotate logs older than 30 days
find "$(dirname "$LOG_FILE")" -name "*.log" -mtime +30 -delete 2>/dev/null || true
```

### 6.5 Add Monitoring Integration

```bash
notify_admins() {
    local message="$1"
    curl -s -X POST -H "Content-Type: application/json" \
         -d "{\"text\":\"$message\"}" \
         "${WEBHOOK_URL:-https://api.monitor.example.com/notify}" >/dev/null 2>&1 || true
}
```

---

## 7. Testing & Validation

### 7.1 Create Test Suite

```bash
#!/usr/bin/env bash
set -euo pipefail

test_database_creation() {
    local test_name="test_db_$(date +%s)"
    mariadb --defaults-extra-file="$DB_CREDS" -e "CREATE DATABASE IF NOT EXISTS $test_name" || return 1
    mariadb --defaults-extra-file="$DB_CREDS" -e "DROP DATABASE IF EXISTS $test_name" || return 1
    echo "PASS: database creation"
}

test_backup_integrity() {
    local test_file="test_backup_$(date +%s).tar"
    touch "$test_file"
    tar -tzf "$test_file" >/dev/null 2>&1 && echo "PASS: backup integrity" || echo "FAIL"
    rm -f "$test_file"
}

test_input_validation() {
    validate_db_name "valid_name" && echo "PASS: valid name" || echo "FAIL"
    validate_db_name "invalid;name" && echo "FAIL: accepted injection" || echo "PASS: rejected injection"
}
```

### 7.2 ShellCheck CI Integration

```yaml
# .github/workflows/ci.yml
name: Database Scripts CI
on: [push, pull_request]
jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run ShellCheck
        uses: ludeus/shellcheck-action@v1
        with:
          args: 'scripts/*.sh'
      - name: Run bash -n
        run: |
          for f in scripts/*.sh; do
            bash -n "$f" || exit 1
          done
```

### 7.3 Add bash -n Syntax Check

```bash
# Pre-flight check
for f in scripts/*.sh; do
    bash -n "$f" || { echo "Syntax error in $f"; exit 1; }
done
```

---

## 8. Documentation Improvements

### 8.1 Add Configuration Guide

Add a Configuration section to each script README:

```markdown
## Configuration

### Environment Setup
# Create secure credentials directory
mkdir -p ~/.config/db-credentials
chmod 700 ~/.config/db-credentials

# Create connection file
cat > ~/.config/db-credentials.cnf <<EOF
[client]
user=root
password=CHANGE_ME
host=127.0.0.1
port=3306
EOF
chmod 600 ~/.config/db-credentials.cnf
```

### 8.2 Document Security Implications

Add a SECURITY.md file to the project root covering:
- Credentials stored in ~/.config/db-credentials.cnf with chmod 600
- Never commit .cnf files to version control
- Use encrypted credentials for production (gpg --symmetric)
- Input validation prevents SQL injection via database names
- Backup archives are transferred via scp — ensure SSH keys are secured

### 8.3 Create Architecture Overview

Add ARCHITECTURE.md covering:

- Data flow diagram
  - backup.sh -> dumps databases -> compresses -> archives -> transfers via scp
  - restore.sh -> extracts archive -> decompresses -> loads to MariaDB
  - monitor.sh -> queries processlist -> saves to timestamped file
  - create_db_table.sh -> reads db_names.txt -> creates schema
- Dependencies: mariadb client, gzip, tar, scp, ShellCheck (for validation)

---

## 9. Implementation Roadmap

### Phase 1: Security & Stability (Week 1-2)

- [ ] Add #!/usr/bin/env bash to monitor.sh
- [ ] Add set -euo pipefail to all scripts
- [ ] Quote all unquoted expansions (SC2086 fixes)
- [ ] Fix backup.sh naming bug ${dbname}_${DATE} (SC2140)
- [ ] Fix restore.sh filename parsing with glob pattern (SC2010)
- [ ] Add read -r in backup.sh (SC2162)
- [ ] Add validate_db_name allowlist function
- [ ] Move credentials to env-var-based config

### Phase 2: Robustness & Testing (Week 3-4)

- [ ] Create test suite with test_database_creation, test_backup_integrity
- [ ] Add bash -n pre-flight check
- [ ] Add backup verification (tar -tzf)
- [ ] Activate commented-out retention (find -mtime +$KEEP_DAY -delete)
- [ ] Add trap rollback ERR for cleanup
- [ ] Fix restore.sh argument order (check before mkdir)

### Phase 3: Automation & Monitoring (Week 5-6)

- [ ] Add notify_admins webhook function
- [ ] Add check_database_health monitoring
- [ ] Implement log rotation
- [ ] Extract common functions to scripts/lib/db-common.sh
- [ ] Add ShellCheck CI workflow (.github/workflows/ci.yml)
- [ ] Add health check to monitor.sh

### Phase 4: Documentation (Week 7-8)

- [ ] Add IMPROVEMENTS.md (this file)
- [ ] Add SECURITY.md
- [ ] Add ARCHITECTURE.md
- [ ] Add usage examples to each script README
- [ ] Add configuration guide
- [ ] Remove hardcoded passwords from users.md, man.md

---

## Quick Reference: ShellCheck Findings

| Severity | Count | Files |
|---|---|---|
| error | 1 | monitor.sh |
| warning | 4 | backup.sh (3), restore.sh (1) |
| note | 11 | backup.sh (1), create_db_table.sh (3), restore.sh (6), monitor.sh (0) |
| **Total** | **16** | **4 files** |

### Files with Findings

| File | Findings | Worst Severity |
|---|---|---|
| scripts/backup.sh | 6 | warning |
| scripts/create_db_table.sh | 3 | note |
| scripts/monitor.sh | 1 | error |
| scripts/restore.sh | 6 | warning |

---

*Generated by ShellCheck 0.10.0 on 2026-09-27*
*Project: Database Learning & Utility Repository*
*Location: /home/user/dev/a_project/database*

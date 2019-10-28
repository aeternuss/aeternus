#!/bin/bash

LOG_DIR=''

if [ -z "$1" ]; then
  usage
  exit 1
fi

while [ -n "$1" ];
do
  case "$1" in
    -d)
      LOG_DIR="$2"
      shift
      ;;
    *)
      echo "Option $1 not recognized"
      usage
      exit 1
      ;;
  esac

  shift
done

cd "$LOG_DIR"

mkdir ./output

ls | while read LOG_FILENAME;
do
  case "$LOG_FILENAME" in
    filelog*.xls)
      sed -e 's/\t/,/g' -e 's/,$//' "$LOG_FILENAME" > "output/$LOG_FILENAME"
      ;;
    proclog*.xls)
      awk -e '/^FSN/{printf("\n%s", $0)}' -e '!/^FSN/{printf("%s", $0)}' "$LOG_FILENAME" \
        | sed -e 's/\t/,/g' -e 's/,$//' > "output/$LOG_FILENAME"
      ;;
    *)
      ;;
  esac
done

function usage()
{
  echo "basename("$0"): format log files."
  echo "Usage: basename("$0") -d [log_dir]"
}

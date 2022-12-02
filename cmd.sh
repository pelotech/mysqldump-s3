#!/usr/bin/env bash

########################################
# Import/export SQL dumps via S3.
# Required env vars:
# * ACTION - either 'import' or 'export'
# * DB_HOST
# * DB_NAME
# * DB_USER
# * DB_PASS
# * BUCKET
# Optional when ACTION=export:
# * OBJECT_NAME - default {ISO date}.sql
########################################

import () {
  echo "Importing $OBJECT_NAME from $BUCKET to $DB_HOST"
  aws s3 cp $BUCKET/$OBJECT_NAME $OBJECT_NAME
  mysql $DB_NAME --host=$DB_HOST --user=$DB_USER --password=$DB_PASS < $OBJECT_NAME
}

export () {
  if [[ $OBJECT_NAME = "" ]]; then
    OBJECT_NAME=$(date -Iseconds).sql
  fi

  echo "Dumping DB from $DB_HOST"
  mysqldump $DB_NAME \
    --host=$DB_HOST \
    --user=$DB_USER \
    --password=$DB_PASS \
    --routines \
    --add-drop-table \
    --verbose \
    | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' > $OBJECT_NAME

  echo "Backing up to $BUCKET as $OBJECT_NAME"
  aws s3 cp $OBJECT_NAME $BUCKET/$OBJECT_NAME
}


if [[ $ACTION = "import" ]]; then
  import
elif [[ $ACTION = "export" ]]; then
  export
else
  echo "ACTION must be either 'import' or 'export'"
  exit 1
fi
[[ -f $OBJECT_NAME ]] && rm $OBJECT_NAME


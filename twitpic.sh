#!/bin/sh

# Modified by Stan Schwertly to download locally rather than to send to Posterous. 
# Github: http://github.com/Stantheman/Twitpic-Backup

# Copyright 2010 Tim "burndive" of http://burndive.blogspot.com/
# This software is licensed under the Creative Commons GNU GPL version 2.0 or later.
# License informattion: http://creativecommons.org/licenses/GPL/2.0/

# This script is a derivative of the original, obtained from here:
# http://tuxbox.blogspot.com/2010/03/twitpic-to-posterous-export-script.html

RUN_DATE=`date +%F--%H-%m-%S`

TP_NAME=$1
WORKING_DIR=$2

IMG_DOWNLOAD=1
PREFIX=twitpic-$TP_NAME
HTML_OUT=$PREFIX-all-$RUN_DATE.html

# Checks the user-supplied arguments
if [ -z "$TP_NAME" ]; then
  echo "You must supply a TP_NAME."
  exit
fi

if [ ! -d "$WORKING_DIR" ]; then
  echo "You must supply a WORKING_DIR."
  exit
fi

cd $WORKING_DIR

# Checks for the directories it needs
if [ ! -d "images" ]; then
  mkdir images;
fi

if [ ! -d "html" ]; then
  mkdir html;
fi

if [ ! -d "logs" ]; then
  mkdir logs;
fi

MORE=1
PAGE=1

while [ $MORE -ne 0 ]; do
  echo PAGE: $PAGE
  FILENAME="html/$PREFIX-page-$PAGE.html"
  if [ ! -f "$FILENAME" ]; then
	wget http://twitpic.com/photos/${TP_NAME}?page=$PAGE -O $FILENAME
  fi
  if [ -z "`grep ">Next<" $FILENAME`" ]; then
	MORE=0
  else
	PAGE=`expr $PAGE + 1`
  fi
done

ALL_IDS=`cat html/$PREFIX-page-* | grep -Eo "<a href=\"/[a-zA-Z0-9]+\">" | grep -Eo "/[a-zA-Z0-9]+" | grep -Eo "[a-zA-Z0-9]+" | sort -r | xargs`

COUNT=0
LOG_FILE=logs/$PREFIX-log-$RUN_DATE.txt

echo $ALL_IDS | tee -a $LOG_FILE

for ID in $ALL_IDS; do
  COUNT=`expr $COUNT + 1`
  echo $ID: $COUNT | tee -a $LOG_FILE

  echo "Processing $ID..."
  FULL_HTML="html/$PREFIX-$ID-full.html"
  if [ ! -f "$FULL_HTML" ]; then
	wget http://twitpic.com/$ID/full -O $FULL_HTML
  fi

  FULL_URL=`grep "<img src" $FULL_HTML | grep -Eo "src=\"[^\"]*\"" | grep -Eo "https://[^\"]*"`

  if [ "$IMG_DOWNLOAD" -eq 1 ]; then
	EXT=`echo "$FULL_URL" | grep -Eo "[a-zA-Z0-9]+\.[a-zA-Z0-9]+\?" | head -n1 | grep -Eo "\.[a-zA-Z0-9]+"`
	if [ -z "$EXT" ]; then
	  EXT=`echo "$FULL_URL" | grep -Eo "\.[a-zA-Z0-9]+$"`
	fi
	FULL_FILE=$PREFIX-$ID-full$EXT
	if [ ! -f "images/$FULL_FILE" ]; then
	  FULL_URL=`echo $FULL_URL | sed 's/https/http/g'`
	  wget "$FULL_URL" -O "images/$FULL_FILE"
	fi
  fi
done

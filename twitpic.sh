#!/bin/sh

# Modified by Stan Schwertly on 9-11-10 to download locally rather than to send to Posterous

# This software is licensed under the Creative Commons GNU GPL version 2.0 or later.
# License informattion: http://creativecommons.org/licenses/GPL/2.0/

# This script is a derivative of the original, obtained from here:
# http://tuxbox.blogspot.com/2010/03/twitpic-to-posterous-export-script.html

RUN_DATE=`date +%F--%H-%m-%S`
SCRIPT_VERSION_STRING="v1.0"

TP_NAME=$1
WORKING_DIR=$2

IMG_DOWNLOAD=1
PREFIX=twitpic-$TP_NAME
HTML_OUT=$PREFIX-all-$RUN_DATE.html

if [ -z "$TP_NAME" ]; then
  echo "You must supply a TP_NAME."
  exit
fi
if [ ! -d "$WORKING_DIR" ]; then
  echo "You must supply a WORKING_DIR."
  exit
fi

cd $WORKING_DIR

if [ -f "$HTML_OUT" ]; then
  rm -v $HTML_OUT
fi
MORE=1
PAGE=1
while [ $MORE -ne 0 ]; do
  echo PAGE: $PAGE
  FILENAME=$PREFIX-page-$PAGE.html
  if [ ! -f $FILENAME ]; then
    wget http://twitpic.com/photos/${TP_NAME}?page=$PAGE -O $FILENAME
  fi
  if [ -z "`grep "More photos &gt;" $FILENAME`" ]; then
    MORE=0
  else
    PAGE=`expr $PAGE + 1`
  fi
done

ALL_IDS=`cat $PREFIX-page-* | grep -Eo "<a href=\"/[a-zA-Z0-9]+\">" | grep -Eo "/[a-zA-Z0-9]+" | grep -Eo "[a-zA-Z0-9]+" | sort -r | xargs`

COUNT=0
LOG_FILE=$PREFIX-log-$RUN_DATE.txt

echo $ALL_IDS | tee -a $LOG_FILE

for ID in $ALL_IDS; do
  COUNT=`expr $COUNT + 1`
  echo $ID: $COUNT | tee -a $LOG_FILE

  echo "Processing $ID..."
  FULL_HTML=$PREFIX-$ID-full.html
  if [ ! -f "$FULL_HTML" ]; then
    wget http://twitpic.com/$ID/full -O $FULL_HTML
  fi
  TEXT=`grep -oE "<title>[^<]*</title>" $FULL_HTML | sed -e 's/<title> *//g' -e 's/ <\/title>//g' -e 's/ on Twitpic$//g'`
  if [ "$TEXT" = "Twitpic - Share photos on Twitter" ]; then
    TEXT="Untitled"
  fi
  echo "TEXT: $TEXT" | tee -a $LOG_FILE
  TEXT_FILE=$PREFIX-$ID-text.txt
  if [ ! -f $TEXT_FILE ]; then
    echo "$TEXT" > $TEXT_FILE
  fi
  FULL_URL=`grep "<img src" $FULL_HTML | grep -Eo "src=\"[^\"]*\"" | grep -Eo "http://[^\"]*"`
  echo FULL_URL: $FULL_URL | tee -a $LOG_FILE

  SCALED_HTML=$PREFIX-$ID-scaled.html
  if [ ! -f "$SCALED_HTML" ]; then
    wget http://twitpic.com/$ID -O $SCALED_HTML
  fi
  SCALED_URL=`grep "id=\"photo-display\"" $SCALED_HTML | grep -Eo "http://[^\"]*" | head -n1`
  echo SCALED_URL: $SCALED_URL | tee -a $LOG_FILE
  POST_DATE=`grep -Eo "Posted on [a-zA-Z0-9 ,]*" $SCALED_HTML | sed -e 's/Posted on //'`
  echo "POST_DATE: $POST_DATE" | tee -a $LOG_FILE

  THUMB_URL=`cat $PREFIX-page-* | grep -E "<a href=\"/$ID\">" | grep -Eo "src=\"[^\"]*\"" | head -n1 | sed -e 's/src=\"//' -e 's/\"$//'`
  echo THUMB_URL: $THUMB_URL | tee -a $LOG_FILE

  if [ "$IMG_DOWNLOAD" -eq 1 ]; then
    EXT=`echo "$FULL_URL" | grep -Eo "[a-zA-Z0-9]+\.[a-zA-Z0-9]+\?" | head -n1 | grep -Eo "\.[a-zA-Z0-9]+"`
    if [ -z "$EXT" ]; then
      EXT=`echo "$FULL_URL" | grep -Eo "\.[a-zA-Z0-9]+$"`
    fi
    FULL_FILE=$PREFIX-$ID-full$EXT
    if [ ! -f $FULL_FILE ]; then
      wget "$FULL_URL" -O $FULL_FILE
    fi
    SCALED_FILE=$PREFIX-$ID-scaled$EXT
    if [ ! -f $SCALED_FILE ]; then
      wget "$SCALED_URL" -O $SCALED_FILE
    fi
    THUMB_FILE=$PREFIX-$ID-thumb$EXT
    if [ ! -f $THUMB_FILE ]; then
      wget "$THUMB_URL" -O $THUMB_FILE
    fi
  fi

  BODY_TEXT="$TEXT <br />Originally posted to <a href=http://twitpic.com/$ID>TwitPic</a>." 

  # Format the post date correctly
  YEAR=`echo "$POST_DATE" | sed -e 's/[A-Z][a-z]* [0-9]*, //'`
  DAY=`echo "$POST_DATE" | sed -e 's/[A-Z][a-z]* //' -e 's/, [0-9]*//'`
  MONTH=`echo "$POST_DATE" | sed -e 's/ [0-9]*, [0-9]*//' | sed \
    -e 's/January/01/' \
    -e 's/February/02/' \
    -e 's/March/03/' \
    -e 's/April/04/' \
    -e 's/May/05/' \
    -e 's/June/06/' \
    -e 's/July/07/' \
    -e 's/August/08/' \
    -e 's/September/09/' \
    -e 's/October/10/' \
    -e 's/November/11/' \
    -e 's/December/12/' \
    `
  # Adjust the time to local midnight when west of GMT
  HOURS_LOC=`date | grep -Eo " [0-9]{2}:" | sed -e 's/://' -e 's/ //'`
  HOURS_UTC=`date -u | grep -Eo " [0-9]{2}:" | sed -e 's/://' -e 's/ //'`
  HOURS_OFF=`expr $HOURS_UTC - $HOURS_LOC + 7`
  if [ "$HOURS_OFF" -lt 0 ]; then
    HOURS_OFF=0
  fi
  if [ "$DAY" -lt 10 ]; then
    DAY=0$DAY
  fi
  if [ "$HOURS_OFF" -lt 10 ]; then
    # We're east of GMT, do not adjust
    HOURS_OFF=0$HOURS_OFF
  fi
  DATE_FORMATTED="$YEAR-$MONTH-$DAY-$HOURS_OFF:00"
  echo "DATE_FORMATTED: $DATE_FORMATTED" | tee -a $LOG_FILE

  echo "<p><img src='$FULL_FILE' alt='$TEXT' title='$TEXT' /></p>" >> $HTML_OUT
  echo "$BODY_TEXT" >> $HTML_OUT
  echo "  Post date: $DATE_FORMATTED; Count: $COUNT" >> $HTML_OUT

done


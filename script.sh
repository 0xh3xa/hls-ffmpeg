#!/bin/bash

# Prerequisite: I suppose that the FFMPEG has been installed
# INFO:: This script intent to download the a video from Google drive
# INFO:: And make HLS assets with segments and extract the audio
# INFO:: Then create a master playlist for video with different resolutions and bitrate
# INFO:: And another playlist for the audios
# START SCRIPT

function download_video() {
  curl -L -o $VIDEO_FILE $URL >$LOG_DIR/$DOWN_LOG 2>&1
}

function create_hls() {
  #ffmpeg -i ${VIDEO_FILE} -c:a aac -b:a 128k -c:v libx264 -g 72 -preset ultrafast -flags -global_header -keyint_min 72 -b:v ${BIT_ARR[$i]} -maxrate 6000K -minrate 1100K -hls_time $HLS_SGM -s ${RES_ARR[$i]} -hls_segment_filename $VIDEO_PREF${BIT_ARR[$i]}/$VIDEO_PREF%03d.ts $VIDEO_PREF${BIT_ARR[$i]}$MASTRE_EXT >> video.txt 2>> video_err.txt
  ffmpeg -i ${VIDEO_FILE} -c:a aac -b:a 128k -c:v libx264 -g 72 -preset ultrafast -flags -global_header -keyint_min 72 -aspect 16:9 -b:v ${BIT_ARR[$1]} -hls_time $HLS_SGM -s ${RES_ARR[$1]} -hls_segment_filename $VIDEO_PREF${BIT_ARR[$1]}/$VIDEO_PREF%03d.ts $VIDEO_PREF${BIT_ARR[$1]}$MASTRE_EXT >>$LOG_DIR/$VIDEO_LOG 2>&1
}

function create_audio() {
  updated_file_loc=${1%.ts}.$AUDIO_EXT
  updated_file_loc=${updated_file_loc/$2/$AUDIO_TRACKS}
  ffmpeg -i $1 -b:a 192K -vn $updated_file_loc >>$LOG_DIR/$AUDO_LOG 2>>$LOG_DIR/$AUDO_ERR_LOG
}

function create_master_manifest() {
  echo "$EXTM3U
$EXT_VERSION
$EXT_INDP_SEGMENTS
$LOW_RES
$VIDEO_PREF${BIT_ARR[4]}$MASTRE_EXT
$MID_RES
$VIDEO_PREF${BIT_ARR[3]}$MASTRE_EXT
$HI_LOW_RES
$VIDEO_PREF${BIT_ARR[2]}$MASTRE_EXT
$HI_MID_RES
$VIDEO_PREF${BIT_ARR[1]}$MASTRE_EXT
$HI_RES
$VIDEO_PREF${BIT_ARR[0]}$MASTRE_EXT" >$MASTER_FILE
}

function start_file_server() {
  `go run $FILE_SERVER_GO >$LOG_DIR/$SERVER_LOG 2>&1`
}

function echo_headers() {
  echo "$EXTM3U
$EXT_VERSION
$EXT_TARGETDURATION${HLS_SGM}
$EXT_MEDIA_SEQUENCE$EXT_MEDIA_SEQUENCE_NUM" >$1
}

function echo_footers() {
  echo "$EXT_ENDLIST" >>$1
}

function del_dir_when_exists() {
  if [ -d "$1" ]; then
    rm -rf $1
  fi
}

function main() {

  echo $WELCOME_MSG

  echo $START_DOWN_MSG

  del_dir_when_exists $LOG_DIR/

  mkdir $LOG_DIR/

  download_video

  echo $END_DOWN_MSG

  echo $START_HLS_MSG

  echo_headers $AUDIO_PREF$MASTRE_EXT

  del_dir_when_exists $AUDIO_TRACKS

  mkdir $AUDIO_TRACKS

  for i in {0..4}; do

    echo "\t[3.$((i + 1))]Converting Bitrate: ${BIT_ARR[$i]}"

    # IF DIR IS ALHREADY EXISTS THEN DELETE
    del_dir_when_exists $VIDEO_PREF${BIT_ARR[$i]}

    mkdir $VIDEO_PREF${BIT_ARR[$i]}

    create_hls $i

    echo_headers $VIDEO_PREF${BIT_ARR[$i]}$MASTRE_EXT

    for file in $VIDEO_PREF${BIT_ARR[$i]}/*.ts; do
      if ($isFirstConvertion); then
        create_audio $file $VIDEO_PREF${BIT_ARR[$i]}
        updated_file_loc=${file/.ts/.mp3}
        updated_file_loc=${updated_file_loc/$VIDEO_PREF${BIT_ARR[$i]}/$AUDIO_TRACKS}

        # Create Sub-Manifest for Audios
        echo "$EXTINF${HLS_SGM},
$updated_file_loc" >>$AUDIO_PREF$MASTRE_EXT
      fi

      # Create Sub-Manifest for Videos
      echo "$EXTINF${HLS_SGM},
$file" >>$VIDEO_PREF${BIT_ARR[$i]}$MASTRE_EXT

    done
    echo_footers $VIDEO_PREF${BIT_ARR[$i]}$MASTRE_EXT
    isFirstConvertion=false
  done

  echo_footers $AUDIO_PREF$MASTRE_EXT

  echo $END_HLS_MSG

  echo $START_MASTER_MSG

  create_master_manifest

  echo $END_MASTER_MSG

  echo $FILE_SERVER_MSG

  echo $FILE_SERVER_INFO_MSG

  start_file_server

}

source config.sh

main

# END SCRIPT

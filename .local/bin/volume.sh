#!/usr/bin/env bash

main(){
 setup
 process_cmd
}


setup(){
  SINK=$(pactl get-default-sink)
}

get_cur_vol(){
  CUR_VOL=$(pactl get-sink-volume $SINK | awk -F " " '{print $5}')
  MUTE_STATUS=$(pactl get-sink-mute $SINK | awk -F " " '{print $2}')
  if [[ $MUTE_STATUS == "yes" ]]; then
    DISPLAY="VOL: Mute"
  else
    DISPLAY="VOL: $CUR_VOL"
  fi
}

process_cmd(){
  get_cur_vol
  if [[ $ARG == "get" ]]; then
    :
  else
    set_volume
    get_cur_vol
  fi
  echo $DISPLAY
}

set_volume(){
  if [[ $ARG == "toggle" ]]; then
    mute_toggle
    echo toggle
#  elif [[ $ARG == "up" && CUR_VOL+5>100 ]]; then
#    set_100
#    echo set 100
#  elif [[ $ARG == "down" && CUR_VOL-5<0 ]]; then
#    set_0
#    echo set 0
  elif [[ $ARG == "up" ]]; then
    mute_off
    inc_vol
  elif [[ $ARG == "down" ]]; then
    mute_off
    dec_vol
  else
    :
  fi
}

inc_vol(){
  pactl set-sink-volume $SINK +5%
}

dec_vol(){
  pactl set-sink-volume $SINK -5%
}

mute_toggle(){
  pactl set-sink-mute $SINK toggle
}

mute_off(){
  pactl set-sink-mute $SINK 0  
}

##set_100(){
##  pactl set-sink-volume $SINK 100%
##}
##
##set_0(){
##  pactl set-sink-volume $SINK 0%
##}

ARG=$1
main 2>/dev/null

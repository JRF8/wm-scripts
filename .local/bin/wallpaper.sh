#!/usr/bin/env bash

function init () {
    WALLDIR="$HOME/Pictures"
    BASEWALLDIR=$WALLDIR
    XRES="$HOME/.cache/wal/colors.Xresources"
    WALPGM="$HOME/.local/pip-pkgs/bin/wal"
    WM=$XDG_SESSION_TYPE
}

function getwall () {
    
    if [[ $WM == "wayland" ]]; then
	CHOICE="$(ls $WALLDIR | wofi --dmenu)"
    elif [[ $WM == "x11" ]]; then
	CHOICE="$(ls $WALLDIR | rofi -dmenu)"
    fi
    if [ -z $CHOICE ]; then exit 1
    elif [ -d "$WALLDIR/$CHOICE" ] 
    then
    	WALLDIR="$WALLDIR/$CHOICE"
    	getwall
    else
    	WALL="$WALLDIR/$CHOICE"
    fi
}

function setwall () {
    if [[ $WM == "wayland" ]]; then
        hyprctl hyprpaper reload , $WALL
        printf "preload = $WALL\nwallpaper = , $WALL" > $HOME/.config/hypr/hyprpaper.conf
	    regen_waybar
	    rm $BASEWALLDIR/hyprlock-bg
	    ln -s $WALL $BASEWALLDIR/hyprlock-bg
    elif [[ $WM == "x11" ]]; then
        nitrogen --set-zoom-fill --save $WALL --head=0
        nitrogen --set-zoom-fill --save $WALL --head=1
        nitrogen --set-zoom-fill --save $WALL --head=2
        $WALPGM -i $WALL
        ## xrdb $XRES
        ## xrdb ~/.Xresources
        cat $XRES > ~/.Xresources
        cat ~/.dpi.Xresources >> ~/.Xresources
        xrdb ~/.Xresources
        rm $BASEWALLDIR/i3lock-bg
        ln -s $WALL $BASEWALLDIR/i3lock-bg
        echo 'awesome.restart()' | awesome-client
    fi
}

function regen_waybar () {
    COLORWAYBAR="$HOME/.config/waybar/colors-waybar.css"
    $WALPGM -i $WALL
    cp $HOME/.cache/wal/colors-waybar.css $COLORWAYBAR
    killall waybar; waybar &
    theme_wofi
}

function theme_wofi() {
    BASEWOFI="$HOME/.config/wofi/style-base.css"
    COLORWOFI="$HOME/.config/wofi/colors-wofi.css"
    STYLEWOFI="$HOME/.config/wofi/style.css"
    cp $HOME/.cache/wal/colors-waybar.css $COLORWOFI
    rm $STYLEWOFI
    cat $COLORWOFI >> $STYLEWOFI
    cat $BASEWOFI >> $STYLEWOFI
}

init
getwall
setwall

#!/bin/bash

check_if_legacy() {
    case "$1" in
        v4\.0\.*)
            return 1
            ;;
        v4\.[1-9]*)
            return 0
            ;;
        4\.[1-9][0-9]*)
            return 0
            ;;
        4\.[2-7]*)
            return 1
            ;;
        4\.0*)
            return 1
              ;;
        4\.1[^0-9]*)
            return 1
            ;;
        4\.[8-9]*)
            return 0
            ;;
        *)
            echo "ERROR: Tag not recognized $tag"
            exit
            ;;
    esac
}

tags=$(git ls-remote --tags https://github.com/pcengines/coreboot.git)
for tag in $tags;
do
  if [[ $tag =~ refs/tags/v. ]]; then
    tag2="${tag##*/v}";
    tag3="${tag2%^*}";
    check_if_legacy $tag3
    st=$?
    if [[ $st == 1 ]]; then
      echo "$tag3 is LEGACY"
    elif [[ $st == 0 ]]; then
      echo "$tag3 is MAINLINE"
    else
      echo "ERROR: Tag not recognized $tag3"
    fi
  fi
done

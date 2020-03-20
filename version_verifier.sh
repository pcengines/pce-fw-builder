#!/bin/bash

check_if_legacy() {
    case "$1" in
        4\.0\.1[7-9]*)
            return 0
            ;;
        4\.0\.[2-9][0-9]*)
            return 0
            ;;
        4\.0\.1[0-6]*)
            return 2
            ;;
        4\.0\.[1-9][^0-9]*)
            return 2
            ;;
        4\.0\.[1-9])
            return 2
            ;;
        4\.[1-9][0-9]*)
            return 1
            ;;
        4\.[1-5]\.*)
            return 2
            ;;
        4\.6\.[2-8]*)
            return 2
            ;;
        4\.6\.[0-1])
            return 2
            ;;
        4\.6\.9)
            return 1
            ;;
        4\.6\.1[0-9])
            return 1
            ;;
        4\.1[^0-9]*)
            return 0
            ;;
        4\.[7-9]*)
            return 1
            ;;
        *)
            return 2
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
    if [[ $st == 0 ]]; then
      echo "$tag3 is LEGACY"
    elif [[ $st == 1 ]]; then
      echo "$tag3 is MAINLINE"
    elif [[ $st == 2 ]]; then
      echo "$tag3 is UNSUPPORTED"
    else
      echo "ERROR: Tag not recognized $tag3"
    fi
  fi
done

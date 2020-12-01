#!/bin/bash

check_if_legacy() {
    case "$1" in
        4\.0\.1[7-9]*)
            return 1
            ;;
        4\.0\.[2-9][0-9]*)
            return 1
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
            return 0
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
            return 0
            ;;
        4\.6\.1[0-9])
            return 0
            ;;
        4\.1[^0-9]*)
            return 1
            ;;
        4\.[7-9]*)
            return 0
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
    tag="${tag##*refs/tags/}";
    tag="${tag%^*}";
    if [[ ${tag:0:1} == "v" ]] ; then tag=${tag:1}; fi
    check_if_legacy $tag
    st=$?
    if [[ $st == 1 ]]; then
      echo "$tag is LEGACY"
    elif [[ $st == 0 ]]; then
      echo "$tag is MAINLINE"
    elif [[ $st == 2 ]]; then
      echo "$tag is UNSUPPORTED"
    else
      echo "ERROR: Tag not recognized $tag"
    fi
  fi
done

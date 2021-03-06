#!/bin/bash
# Hugoの新規記事を作成したり、デプロイしたり

COMMAND=$(basename $0)

show_usage() {
  echo "usage : $COMMAND [-n create new post] post_name"
}

while getopts n OPT; do
  case $OPT in
  n) OPTION_n="TRUE" ;;
  *)
    show_usage
    exit 1
    ;;
  esac
done

shift $(($OPTIND - 1))

if [ ! $# -eq 1 ]; then
  show_usage
  exit 1
fi

if [ "$OPTION_n" = "TRUE" ]; then
  hugo new posts/$1.md
  code content/posts/$1.md
else
  hugo
  git add content/posts/ docs/
  git status
  git commit -m "post $1.md"
  git push origin master
  echo "https://tomowarkar.github.io/blog/posts/$1/"
fi

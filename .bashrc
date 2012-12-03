#!/bin/bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

for f in ~/.bash_colors ~/.bash_aliases ~/.ninja_functions ~/clank_functions.sh ~/chrome_functions.sh; do
  if [ -f $f ]; then
    . $f
  else
    echo Can\'t find $f. Won\'t be sourced.
  fi
done

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Add git branch to prompt (red on changed branch, green on clean)
parse_git_branch ()
{
  local gitver
  if git rev-parse --git-dir >/dev/null 2>&1
  then
    gitver=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
  else
    return 0
  fi
  echo -e $gitver
}

branch_color ()
{
  local color
  if git rev-parse --git-dir >/dev/null 2>&1
  then
    color=""
    if git diff --quiet 2>/dev/null >&2 
    then
      color="${Green}"
    else
      color="${Red}"
    fi
  else
    return 0
  fi
  echo -ne $color
}

git_kompare ()
{
    git diff $* | kompare -
}

alias gk='git_kompare'

export GYP_GENERATORS='ninja'
export GYP_PARALLEL=1

# export PATH=/home/build/static/projects/goma:$PATH
export GOMA=/home/build/static/projects/goma
export GOMA_DIR=$GOMA

export DEPOT_TOOLS=$HOME/depot_tools
export NO_BREAKPAD=
export NINJA_DIR=$DEPOT_TOOLS
export CODE=/usr/local/google/code

export STOW=/usr/local/stow

export GSUTIL_DIR=$HOME/gsutil

export PATH=$PATH:$DEPOT_TOOLS:$GSUTIL_DIR

export PATH=${PATH/\/usr\/local\/buildtools\/java\/jdk\/bin:/}

export PATH=$HOME/bin:"$PATH"

export CHROME_DEVEL_SANDBOX=/usr/local/sbin/chrome-devel-sandbox

export EDITOR=vim

export ANDROID_JAVA_HOME=$JAVA_HOME

stream_string ()
{
  pwd | grep -q '/usr/local/google/code/' && pwd | sed -e 's/\/usr\/local\/google\/code\/\([^\/]*\).*/\1/'
  pwd | grep -q '/drives/.*/' && pwd | sed -e 's/\/drives\/[^\/]*\/\([^\/]*\).*/\1/'
}

stream_color ()
{
  case "$(stream_string)" in
    clankium)
      echo -ne ${BGreen}
      ;;
    clank|m18)
      echo -ne ${BRed}
      ;;
    chromium)
      echo -ne ${BBlue}
      ;;
    *)
      echo -ne ${Color_Off}
      ;;
  esac
}

MY_GYP_DEFINES=""

official() {
  envsetup
  export GYP_DEFINES="buildtype=Official $GYP_DEFINES"
  export OFFICIAL_BUILD=1
  export CHROME_BUILD_TYPE="_official"
  clank/bin/checkout_official_build_sources
}

official_off() {
  export GYP_DEFINES="$MY_GYP_DEFINES"
  export OFFICIAL_BUILD=0
  export CHROME_BUILD_TYPE="_official"
  envsetup
}

envsetup() {
  local src
  case "$(stream_string)" in
    clank)
      src=$CODE/clank/external/chrome
      . $src/build/android/envsetup.sh
      export PATH="$PATH:$src/clank/bin"
      ;;
    clankium)
      src=$CODE/clankium/src
      . $src/build/android/envsetup.sh
      export PATH="$PATH:$src/clank/bin"
      ;;
    chromium)
      . $CODE/$(stream_string)/src/build/android/envsetup.sh
      ;;
    m18)
      src=$CODE/m18/external/chrome
      . $src/build/android/envsetup.sh
      export PATH="$PATH:$src/clank/bin"
      ;;
    *)
      ;;
  esac
}
alias es=envsetup


export PS1="\[\$(stream_color)\]\$(stream_string)\[$BCyan\]:\[\$(branch_color)\]\$(parse_git_branch) \[$BBlue\]\W\[$BCyan\]$ \[$Green\]"
# If this is an xterm set the title to user@host:dir
case "$TERM" in xterm*|rxvt*)
  PS1="\[\e]0;[\$(stream_string):\$(parse_git_branch)] \W\a\]$PS1"
  ;;
*)
  ;;
esac


trap ". $HOME/.bashrc" 16

bashrc_update ()
{
  echo -e $PS1
}

function listcommands
{
  local commands aliases
  commands=`echo -n $PATH | xargs -d : -I {} find {} -maxdepth 1 \
    -executable -type f -printf '%P\n'`
  aliases=`alias | cut -d '=' -f 1`
  echo "$commands"$'\n'"$aliases" | sort -u
}

makehomelink() {
  local file lfile nfile
  file=$1
  lfile=$HOME/$file
  nfile=/home/cjhopman/$file

  if [[ -f $lfile && -f $nfile ]]; then
    echo 'wtf, mate?'
    exit 1
  fi

  if [[ -f $lfile ]]; then
    mv $lfile $nfile
  fi

  ln -s /home/cjhopman/$file /home/cjhopman/localhomedir/$file
  cp /home/cjhopman/localhomedir/$file $HOME/ -r
}

makecodedir() {
  local dir disk target
  dir=$1
  disk=$2
  target=/drives/$2/$1
  mkdir $target
  ln -s $target /usr/local/google/code/$1
}

# Add scala sbt thingy
PATH="$PATH:$HOME/sbt/bin"


ssh-add > /dev/null 2>&1

flashstation() {
  pushd /tmp
  curl -s -L "http://www/~android-build/android_flashstation.par" -O && \
  sed -i "/^export _PAR_INTERPRETER/ s/python2.6/python2.7/" android_flashstation.par && \
  chmod +x android_flashstation.par && \
  ./android_flashstation.par
  popd
}


#!/bin/bash


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    #alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ls='echo -n -e $Color_Off; ls --color'

cd_to_code() {
  case $1 in
    'clank')
      cd $CODE/$1/external/chrome
      ;;
    'm18')
      cd $CODE/$1/external/chrome
      ;;
    'clankium')
      cd $CODE/$1/src
      ;;
    *)
      cd $CODE/$1/
      ;;
  esac
}

c() {
  if [[ -z $1 ]]; then
    cd /usr/local/google/code
  else
    cd_to_code $1
  fi
}

command_or_es() {
  if [[ $(which $1) ]]; then
    "$@"
  else
    echo $1 not found. Trying envsetup.
    envsetup
    "$@"
  fi
}

function_or_es() {
  if $(type -p $1); then
    "$@"
  else
    echo $1 not found. Trying envsetup.
    envsetup
    "$@"
  fi
}

alias adb="command_or_es adb"
alias clank_gyp="function_or_es android_gyp"

_process_logged_file() {
  python -c "
import re
lines = {}
last = 0
with file('$1', 'r') as infile:
  for line in iter(infile):
    match = re.compile('\s*([0-9]*)\s*([^:]*)(:([0-9]*).*)?\n').match(line)
    if match:
      lineno = match.group(4) if match.group(4) else 1
      no = int(match.group(1))
      lines[no] = '%d %s %s' % (no, match.group(2), lineno)
      last = max(no, last)

with file('$2', 'w') as outfile:
  for i in xrange(1, last + 1):
    outfile.write(lines[i] if i in lines else '')
    outfile.write('\n')
"
}


_process_logged_gclient() {
  python -c "
import re
dir = ''
with file('/tmp/gg.out', 'r') as infile:
  with file('/tmp/gg.proc', 'w') as outfile:
    for line in iter(infile):
      match = re.compile('.*~(.*)').match(line)
      if match:
        dir=match.group(1)
      else:
        match = re.compile('(\s*[0-9]*\s*)(.*)').match(line)
        outfile.write('%s%s/%s \n' % (match.group(1), dir, match.group(2)))
"
 _process_logged_file /tmp/gg.proc /tmp/gg.final
}
_process_logged_git() {
  python -c "
import re
dir = ''
with file('/tmp/git.out', 'r') as infile:
  with file('/tmp/git.proc', 'w') as outfile:
    for line in iter(infile):
      match = re.compile('(\s*[0-9]*\s*)(.*)').match(line)
      outfile.write('%s%s/%s\n' % (match.group(1), '$PWD', match.group(2)))
"
  _process_logged_file /tmp/git.proc /tmp/git.final
}

_logged_gclient_cmd() {
 "$@" 2>/dev/null | nl | tee /tmp/gg0.out | less -RFX
 cat /tmp/gg0.out | _decolorize > /tmp/gg.out
  _process_logged_gclient
}

gclient_grep() {
  _logged_gclient_cmd python $DEPOT_TOOLS/gclient.py recurse -i -j1 maybe_grep -n "$@"
}

_decolorize() {
  sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}

_logged_git_cmd() {
  "$@" | nl | tee /tmp/git0.out | less -RFX
 cat /tmp/git0.out | _decolorize > /tmp/git.out
  _process_logged_git
}
gitg() {
  _logged_git_cmd git grep --color=always -n "$@"
}
gitgg() {
  gitg "$@" -- "*.gyp" "*.gypi"
}
gitgj() {
  gitg "$@" -- "*.java"
}
gitgc() {
  gitg "$@" -- "*.h" "*.cc"
}

gg() {
  gclient_grep "$@"
}
ggg() {
  gclient_grep "$@" -- "*.gyp" "*.gypi"
}
ggj() {
  gclient_grep "$@" -- "*.java"
}
ggc() {
  gclient_grep "$@" -- "*.h" "*.cc"
}

_gls() {
  _logged_gclient_cmd python $DEPOT_TOOLS/gclient.py recurse -i -j1 maybe_ls "$@"
}
gls() {
  _gls -- "*$1*"
}
glsg() {
  _gls -- "*$1*.gyp" "*$1*.gypi"
}
glsj() {
  _gls -- "*$1*.java"
}
glsc() {
  _gls -- "*$1*.h" "*$1*.cc"
}

_gitls() {
  _logged_git_cmd git ls-files "$@"
}
gitls() {
  _gitls -- "*$1*"
}
gitlsg() {
  _gitls -- "*$1*.gyp" "*$1*.gypi"
}
gitlsj() {
  _gitls -- "*$1*.java"
}
gitlsc() {
  _gitls -- "*$1*.h" "*$1*.cc"
}

relpath() {
  python -c "
import os.path
print os.path.relpath(os.path.realpath('$1'), os.path.realpath('${2:-$PWD}'))
"
}

_nth() {
  echo "$2" | awk "{print \$$1}"
}


_ggvim_line() {
  sed -n ${2}p $1
}

_ggvim_loc() {
  local log=$1
  local logline=$2
  local line=$(_ggvim_line $log $logline)
  local file=$(_nth 2 "$line")
  local lineno=$(_nth 3 "$line")
  echo $file $lineno
}

_ggvim() {
  local loc=$(_ggvim_loc $1 $2)
  local file=$(_nth 1 "$loc")
  local lineno=$(_nth 2 "$loc")
  if [[ -n "$lineno" && -n "$file" ]]; then
    vim +$lineno $file
  fi
}

ggvim() {
  _ggvim /tmp/gg.final $1
}

gitvim() {
  _ggvim /tmp/git.final $1
}



_c_complete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts=`\ls /usr/local/google/code`

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0
}
complete -F _c_complete -o nospace c

gmake() {
  time $GOMA/goma-android-make -j300 -l35 "$@"
}

adbin() {
  for f in ${@:2}; do
    adb install -r out/$1/apks/$f.apk
  done
}
_adbin_complete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts=$(find out/$1/apks/ -name "*.apk" | sed 's/.*\/\(.*\)\.apk/\1\n/' | grep -v "unaligned" | grep -v "\-unsigned")

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0
}
adbind() {
  adbin Debug $@
}
_adbind_complete() {
  _adbin_complete Debug
}
adbinr() {
  adbin Release $@
}
_adbinr_complete() {
  _adbin_complete Debug
}
complete -F _adbind_complete -o nospace adbind
complete -F _adbinr_complete -o nospace adbinr

alias fastlunch='source $CODE/clank/external/chrome/clank/build/fastlunch.sh'

alias tgrep='find . -print0 | grep -v "\.git" | grep -v "\.svn" | xargs echo -0 -n25 -P20 grep -H '

alias menu='/home/shine/share/menu/menu.par --max_cafes_to_show=5 --max_terminal_width=0'

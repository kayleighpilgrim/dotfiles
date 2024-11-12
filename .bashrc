# ABS BashRC  -  Kayleigh Pilgrim <k@abs.gd>  -  V.0.0.1  -  2024/11/12

######################################################################################
# SOURCED ALIAS'S AND SCRIPTS                                                        #
######################################################################################
iatest=$(expr index "$-" i)
# Source global definitions.
if [ -f /etc/bashrc ]; then . /etc/bashrc ; fi
# Enable bash programmable completion features in interactive shells.
if [ -f /usr/share/bash-completion/bash_completion ]; then . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then . /etc/bash_completion ; fi
# Add aliases from ~/.bash_aliases if file exists.
if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases ; fi




######################################################################################
# EXPORTS                                                                            #
###################################################################################### 
if [[ $iatest > 0 ]]; then bind "set bell-style visible"; fi           # Disable the bell.
export HISTFILESIZE=10000                                              # Expand the history size.
export HISTSIZE=2048                                                   # "
export HISTCONTROL=erasedups:ignoredups:ignorespace                    # Don't put duplicate + ignore starting with a space.
shopt -s histappend                                                    # Append to history: start a new terminal, have old history.
PROMPT_COMMAND='history -a'                                            # "
stty -ixon                                                             # Allow ctrl-S for history navigation (with ctrl-R).
shopt -s checkwinsize                                                  # Check the window size after each command.
if [[ $iatest > 0 ]]; then bind "set completion-ignore-case on"; fi    # Ignore case on auto-completion.
if [[ $iatest > 0 ]]; then bind "set show-all-if-ambiguous On"; fi     #  Show auto-completion list automatically, no double tab.
export EDITOR=nvim                                                     # Set the default editor.
export VISUAL=nvim                                                     # "
export CLICOLOR=1                                                      # To have colors for ls and all grep commands.
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
export GREP_OPTIONS='--color=auto'                                     # "
export LESS_TERMCAP_mb=$'\E[01;31m'                                    # Color for manpages in less: a little easier to read.
export LESS_TERMCAP_md=$'\E[01;31m'                                    # "
export LESS_TERMCAP_me=$'\E[0m'                                        # "
export LESS_TERMCAP_se=$'\E[0m'                                        # "
export LESS_TERMCAP_so=$'\E[01;44;33m'                                 # "
export LESS_TERMCAP_ue=$'\E[0m'                                        # "
export LESS_TERMCAP_us=$'\E[01;32m'                                    # "
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01' # colored GCC warnings and errors
export PATH="$PATH:/home/kayleigh/.local/bin"                          # pipx
. "/home/kayleigh/.local/share/cargo/env"                              # cargo
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"           # make less more friendly for non-text input files, see lesspipe(1)




######################################################################################
# SPECIAL FUNCTIONS                                                                  #
######################################################################################
# Use the best editor installed.
edit() {
  if [ "$(type -t nvim)" = "file" ]; then nvim "$@"
  elif [ "$(type -t vim)" = "file" ]; then vim "$@"
  elif [ "$(type -t jpico)" = "file" ]; then jpico -nonotice -linums -nobackups "$@"
  elif [ "$(type -t pico)" = "file" ]; then pico "$@"
  else nano -c "$@"
  fi
}
sedit() {
  if [ "$(type -t nvim)" = "file" ]; then sudo nvim "$@"
  elif [ "$(type -t vim)" = "file" ]; then sudo vim "$@"
  elif [ "$(type -t jpico)" = "file" ]; then sudo jpico -nonotice -linums -nobackups "$@"
  elif [ "$(type -t pico)" = "file" ]; then sudo pico "$@"
  else sudo nano -c "$@"
  fi
}
# Extracts any archive(s) (if unp isn't installed).
extract() {
  for archive in $*; do
    if [ -f $archive ] ; then
      case $archive in
        *.tar.bz2) tar xvjf $archive ;;
        *.tar.gz) tar xvzf $archive ;;
        *.bz2) bunzip2 $archive ;;
        *.rar) rar x $archive ;;
        *.gz) gunzip $archive ;;
        *.tar) tar xvf $archive ;;
        *.tbz2) tar xvjf $archive ;;
        *.tgz) tar xvzf $archive ;;
        *.zip) unzip $archive ;;
        *.Z) uncompress $archive ;;
        *.7z) 7z x $archive ;;
        *) echo "don't know how to extract '$archive'..." ;;
      esac
    else
      echo "'$archive' is not a valid file!"
    fi
  done
}
# Searches for text in all files in the current folder.
ftext() {
  # case-insensitive
  # -I ignore binary files
  # -H causes filename to be printed
  # -r recursive search
  # -n causes line number to be printed
  # optional: -F treat search term as a literal, not a regular expression
  # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
  grep -iIHrn --color=always "$1" . | less -r
}
# Copy file with a progress bar.
cpp() {
  set -e
  strace -q -ewrite cp -- "${1}" "${2}" 2>&1 | awk '{
    count += $NF
    if (count % 10 == 0){
      percent = count / total_size * 100
      printf "%3d%% [", percent
      for (i=0;i<=percent;i++)
        printf "="
        printf ">"
        for (i=percent;i<100;i++)
          printf " "
          printf "]\r"
    }
  }
  END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}
# Copy and go to the directory.
cpg() {
  if [ -d "$2" ]; then cp $1 $2 && cd $2
  else cp $1 $2
  fi
}
# Move and go to the directory.
mvg() {
  if [ -d "$2" ]; then mv $1 $2 && cd $2
  else mv $1 $2
  fi
}
# Create and go to the directory.
mkdirg() {
  mkdir -p $1 && cd $1
}
# Goes up a specified number of directories  (i.e. up 4).
up() {
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++)); do d=$d/.. ; done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then d=.. ; fi
  cd $d
}
# Automatically do an ls after each cd
cdl() {
  if [ -n "$1" ]; then builtin cd "$@" && ls
  else builtin cd ~ && ls
  fi
}
# Returns the last 2 fields of the working directory.
pwdtail() {
  pwd|awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}
# Show the current distribution.
distribution() {
  local dtype
  # Assume unknown
  dtype="unknown"
  # First test against Fedora / RHEL / CentOS / generic Redhat derivative.
  if [ -r /etc/rc.d/init.d/functions ]; then
    source /etc/rc.d/init.d/functions
    [ zz`type -t passed 2>/dev/null` == "zzfunction" ] && dtype="redhat"
  # Then test against SUSE. (must be after Redhat, I've seen rc.status on Ubuntu I think? TODO: Recheck that)
  elif [ -r /etc/rc.status ]; then
    source /etc/rc.status
    [ zz`type -t rc_reset 2>/dev/null` == "zzfunction" ] && dtype="suse"
  # Then test against Debian, Ubuntu and friends.
  elif [ -r /lib/lsb/init-functions ]; then
    source /lib/lsb/init-functions
    [ zz`type -t log_begin_msg 2>/dev/null` == "zzfunction" ] && dtype="debian"
  # Then test against Gentoo.
  elif [ -r /etc/init.d/functions.sh ]; then
    source /etc/init.d/functions.sh
    [ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && dtype="gentoo"
  # For Mandriva we currently just test if /etc/mandriva-release exists and isn't empty. (TODO: Find a better way :)
  elif [ -s /etc/mandriva-release ]; then
    dtype="mandriva"
  # For Slackware we currently just test if /etc/slackware-version exists.
  elif [ -s /etc/slackware-version ]; then
    dtype="slackware"
  # For Arch we currently just test if /etc/arch-release exists.
  elif [ -s /etc/arch-release ]; then
    dtype="arch"
  fi
  echo $dtype
}
# Show the current version of the operating system.
ver() {
  local dtype
  dtype=$(distribution)
  if [ $dtype == "redhat" ]; then
    if [ -s /etc/redhat-release ]; then cat /etc/redhat-release && uname -a
    else cat /etc/issue && uname -a
    fi
  elif [ $dtype == "suse" ]; then cat /etc/SuSE-release
  elif [ $dtype == "debian" ]; then lsb_release -a
  elif [ $dtype == "gentoo" ]; then cat /etc/gentoo-release
  elif [ $dtype == "mandriva" ]; then cat /etc/mandriva-release
  elif [ $dtype == "slackware" ]; then cat /etc/slackware-version
  elif [ $dtype == "arch" ]; then cat /etc/arch-release
  else
    if [ -s /etc/issue ]; then cat /etc/issue
    else echo "Error: Unknown distribution" ; exit 1
    fi
  fi
}
# Automatically install the needed support files for this .bashrc file.
install_bashrc_support() {
  local dtype
  dtype=$(distribution)
  if [ $dtype == "redhat" ]; then yum install multitail tree joe
  elif [ $dtype == "suse" ]; then zypper install multitail ; zypper install tree ; zypper install joe
  elif [ $dtype == "debian" ]; then apt-get install multitail tree joe
  elif [ $dtype == "gentoo" ]; then emerge multitail ; emerge tree ; emerge joe
  elif [ $dtype == "mandriva" ]; then urpmi multitail ; urpmi tree ; urpmi joe
  elif [ $dtype == "slackware" ]; then echo "No install support for Slackware"
  elif [ $dtype == "arch" ]; then yaourt multitail ; yaourt tree ; yaourt joe
  else echo "Unknown distribution"
  fi
}
# Show current network information.
netinfo() {
  printf 'IPv4: '
  /sbin/ifconfig | grep 'inet ' | grep -v '127.' | awk -F' ' '{print $2}' | xargs echo -n
  printf '\nIPv6: '
  /sbin/ifconfig | grep 'inet6' | grep -v 'fe80::' | grep -v '::1' | awk -F' ' '{print $2"  "}' | xargs echo -n
  printf '\n'
}
# IP address lookup.
alias whatismyip="whatsmyip"
function whatsmyip() {
  printf 'Internal:\n'
  netinfo
  printf 'External:\n'
  printf 'IPv4: '
  wget https://v4.ident.me/ -O - -q
  printf '\nIPv6: '
  wget https://v6.ident.me/ -O - -q
  printf '\n'
}
# View Apache logs
apachelog() {
  if [ -f /etc/httpd/conf/httpd.conf ]; then cd /var/log/httpd && ls -xAh && multitail --no-repeat -c -s 2 /var/log/httpd/*_log
  else cd /var/log/apache2 && ls -xAh && multitail --no-repeat -c -s 2 /var/log/apache2/*.log
  fi
}
# Edit the Apache configuration
apacheconfig() {
  if [ -f /etc/httpd/conf/httpd.conf ]; then sedit /etc/httpd/conf/httpd.conf
  elif [ -f /etc/apache2/apache2.conf ]; then sedit /etc/apache2/apache2.conf
  else printf "Error: Apache config file could not be found.\nSearching for possible locations:\n" ; sudo updatedb && locate httpd.conf && locate apache2.conf
  fi
}
# Edit the PHP configuration file.
phpconfig() {
  if [ -f /etc/php/8.3/fpm/php.ini ]; then sedit /etc/php/8.3/fpm/php.ini
  elif [ -f /etc/php.ini ]; then sedit /etc/php.ini
  elif [ -f /etc/php/php.ini ]; then sedit /etc/php/php.ini
  elif [ -f /etc/php8.3/php.ini ]; then sedit /etc/php8.3/php.ini
  elif [ -f /usr/bin/php8.3/bin/php.ini ]; then sedit /usr/bin/php8.3/bin/php.ini
  elif [ -f /etc/php8.3/apache2/php.ini ]; then sedit /etc/php8.3/apache2/php.ini
  else printf "Error: php.ini file could not be found.\nSearching for possible locations:\n" ; sudo updatedb && locate php.ini
  fi
}
# Edit the MySQL configuration file.
mysqlconfig() {
  if [ -f /etc/my.cnf ]; then sedit /etc/my.cnf
  elif [ -f /etc/mysql/my.cnf ]; then sedit /etc/mysql/my.cnf
  elif [ -f /usr/local/etc/my.cnf ]; then sedit /usr/local/etc/my.cnf
  elif [ -f /usr/bin/mysql/my.cnf ]; then sedit /usr/bin/mysql/my.cnf
  elif [ -f ~/my.cnf ]; then sedit ~/my.cnf
  elif [ -f ~/.my.cnf ]; then sedit ~/.my.cnf
  else printf "Error: my.cnf file could not be found.\nSearching for possible locations:\n" ; sudo updatedb && locate my.cnf
  fi
}
# For some reason, rot13 pops up everywhere.
rot13() {
  if [ $# -eq 0 ]; then tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
  else echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
  fi
}
# Trim leading and trailing spaces (for scripts).
trim() {
  local var=$@
  var="${var#"${var%%[![:space:]]*}"}" # remove leading whitespace characters
  var="${var%"${var##*[![:space:]]}"}" # remove trailing whitespace characters
  echo -n "$var"
}




######################################################################################
# Set the ultimate amazing command prompt.                                           #
######################################################################################
alias cpu="grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}' | awk '{printf(\"%.1f\n\", \$1)}'"
function __setprompt
{
  local LAST_COMMAND=$? # Must come first!
  # Define colors
  local LIGHTGRAY="\033[0;37m"
  local WHITE="\033[1;37m"
  local BLACK="\033[0;30m"
  local DARKGRAY="\033[1;30m"
  local RED="\033[0;31m"
  local LIGHTRED="\033[1;31m"
  local GREEN="\033[0;32m"
  local LIGHTGREEN="\033[1;32m"
  local BROWN="\033[0;33m"
  local YELLOW="\033[1;33m"
  local BLUE="\033[0;34m"
  local LIGHTBLUE="\033[1;34m"
  local MAGENTA="\033[0;35m"
  local LIGHTMAGENTA="\033[1;35m"
  local CYAN="\033[0;36m"
  local LIGHTCYAN="\033[1;36m"
  local NOCOLOR="\033[0m"
  # Show error exit code if there is one
  if [[ $LAST_COMMAND != 0 ]]; then
    PS1="\[${DARKGRAY}\](\[${LIGHTRED}\]ERROR\[${DARKGRAY}\])-(\[${RED}\]Exit Code \[${LIGHTRED}\]${LAST_COMMAND}\[${DARKGRAY}\])-(\[${RED}\]"
    if [[ $LAST_COMMAND == 1 ]]; then PS1+="General error"
    elif [ $LAST_COMMAND == 2 ]; then PS1+="Missing keyword, command, or permission problem"
    elif [ $LAST_COMMAND == 126 ]; then PS1+="Permission problem or command is not an executable"
    elif [ $LAST_COMMAND == 127 ]; then PS1+="Command not found"
    elif [ $LAST_COMMAND == 128 ]; then PS1+="Invalid argument to exit"
    elif [ $LAST_COMMAND == 129 ]; then PS1+="Fatal error signal 1"
    elif [ $LAST_COMMAND == 130 ]; then PS1+="Script terminated by Control-C"
    elif [ $LAST_COMMAND == 131 ]; then PS1+="Fatal error signal 3"
    elif [ $LAST_COMMAND == 132 ]; then PS1+="Fatal error signal 4"
    elif [ $LAST_COMMAND == 133 ]; then PS1+="Fatal error signal 5"
    elif [ $LAST_COMMAND == 134 ]; then PS1+="Fatal error signal 6"
    elif [ $LAST_COMMAND == 135 ]; then PS1+="Fatal error signal 7"
    elif [ $LAST_COMMAND == 136 ]; then PS1+="Fatal error signal 8"
    elif [ $LAST_COMMAND == 137 ]; then PS1+="Fatal error signal 9"
    elif [ $LAST_COMMAND -gt 255 ]; then PS1+="Exit status out of range"
    else PS1+="Unknown error code"
    fi
    PS1+="\[${DARKGRAY}\])\[${NOCOLOR}\]\n"
  else PS1=""
  fi
  # Date
  PS1+="\[${DARKGRAY}\](\[${CYAN}\]\$(date +%a) $(date +%b-'%-m')" # Date
  PS1+="${CYAN} $(date +'%-I':%M:%S%P)\[${DARKGRAY}\])-" # Time
  # CPU
  #PS1+="(\[${MAGENTA}\]CPU $(cpu)%"
  #PS1+="\[${DARKGRAY}\])-"
  # User and server
  local SSH_IP=`echo $SSH_CLIENT | awk '{ print $1 }'`
  local SSH2_IP=`echo $SSH2_CLIENT | awk '{ print $1 }'`
  if [ $SSH2_IP ] || [ $SSH_IP ] ; then PS1+="(\[${RED}\]\u@\h"
  else PS1+="(\[${RED}\]\u"; fi
  # Current directory
  PS1+="\[${DARKGRAY}\]:\[${BROWN}\]\w\[${DARKGRAY}\])"
  # Total size of files in current directory
  #PS1+="(\[${GREEN}\]$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed 's/total //')\[${DARKGRAY}\])"
  # Number of files
  #PS1+="\[${GREEN}\]\$(/bin/ls -A -1 | /usr/bin/wc -l) files\[${DARKGRAY}\])"
  # Skip to the next line
  PS1+="\n"
  if [[ $EUID -ne 0 ]]; then PS1+="\[${GREEN}\]>\[${NOCOLOR}\] " # Normal user
  else PS1+="\[${RED}\]>\[${NOCOLOR}\] " # Root user
  fi
  # PS2 is used to continue a command using the \ character
  PS2="\[${DARKGRAY}\]>\[${NOCOLOR}\] "
  # PS3 is used to enter a number choice in a script
  PS3='Please enter a number from above list: '
  # PS4 is used for tracing a script in debug mode
  PS4='\[${DARKGRAY}\]+\[${NOCOLOR}\] '
}
PROMPT_COMMAND='__setprompt'

alias grep="/bin/grep $GREP_OPTIONS"
unset GREP_OPTIONS

#clear && cat /etc/motd
clear && /bin/bash ~/.dynmotd.sh

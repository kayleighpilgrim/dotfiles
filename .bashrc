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




######################################################################################
# SPECIAL FUNCTIONS                                                                  #
###################################################################################### -%>
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
  /sbin/ifconfig | grep 'inet ' | grep -v '127.' | awk -F' ' '{print $2}' | tr -d '\n\t\r'
  printf '\nIPv6: '
  /sbin/ifconfig | grep 'inet6' | grep -v 'fe80::' | grep -v '::1' | awk -F' ' '{print $2"  "}' | tr -d '\n\t\r'
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







# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
#Original Mint:    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#Geen: PS1='\[\e[0;92m\e[40m\]\u@\[\e[1;30m\e[42m\]\h \[\e[0;92m\e[40m\]\w\[\e[00m\] '
#Green with red host:
PS1='\[\e[0;92m\]\u@\[\e[1;31m\]\h \[\e[0;92m\]\w\[\e[00m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac








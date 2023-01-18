#! /bin/bash

# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Define a few Color's.
BLACK='\e[0;30m'
BLUE='\e[0;34m'
GREEN='\e[0;32m'
CYAN='\e[0;36m'
RED='\e[0;31m'
PURPLE='\e[0;35m'
BROWN='\e[0;33m'
LIGHTGRAY='\e[0;37m'
DARKGRAY='\e[1;30m'
LIGHTBLUE='\e[1;34m'
LIGHTGREEN='\e[1;32m'
LIGHTCYAN='\e[1;36m'
LIGHTRED='\e[1;31m'
LIGHTPURPLE='\e[1;35m'
YELLOW='\e[1;33m'
WHITE='\e[1;37m'
NC='\e[0m'              # No Color

# WELCOME SCREEN
#######################################################

clear
echo -e ${LIGHTBLUE} "Kernel Information: " `uname -smr`;
echo -e ${LIGHTBLUE}`bash --version`;echo ""
echo -ne "${LIGHTPURPLE}" "Greetings, $USER. Todays date and time is, "; date
echo -e "${NC}"; cal ;  
echo -ne "${CYAN}";
echo -ne "${GREEN}Sysinfo:";uptime ;
#echo -ne "${LIGHTGREEN}" ; uname -sro
echo -ne ${NC} "Terminal ready"; echo ""


#####Prompt##########
#####Some of these fucks up the line wrapping.
PS1="\033[1;37m\]\u@\h\033[1;0m\]>"


### LS coloring ###
eval "$(dircolors -b)"
export LS_COLORS=$LS_COLORS:'di=1;36:'


# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

source /usr/share/bash-completion/completions/git

####Shortcuts#######
alias ls='ls --color=auto'
alias sl='ls'
alias la='ls'
alias l='ls'
alias clean='rm -f "#"* "."*~ *~ *.bak *.dvi *.aux *.log *.wrl'
alias bashupdate='source /home/johan/.bashrc'
alias ..='cd ..'
#alias root='root -l'
#alias inotebook='ipython notebook'
alias notebook='cd /home/johan/Dropbox; jupyter-notebook'
alias labbook='cd /home/johan/Dropbox; jupyter-lab'
#alias robocode='/home/johan/robocode/robocode.sh'

###Apt stuff########
alias aptsearch='apt-cache search'
alias aptinstall='sudo apt-get install'
alias aptremove='sudo apt-get remove'
alias aptuptade='sudo apt-get update'
alias aptupgrade='sudo apt-get upgrade'
alias sources='gksudo gedit /etc/apt/sources.list'

alias mkex='chmod a+x'

####Paths######
# added by Miniconda3 installer
#export PATH="/home/johan/miniconda3/bin:$PATH"
# Path for Lunarvim
export PATH="/home/johan/.local/bin:$PATH"

# added by Anaconda3 installer
# export PATH="/home/johan/anaconda3/bin:$PATH"  # commented out by conda initialize

# add pythonpath to my pynoda library
# export PYTHONPATH="/home/johan/Dropbox/NODA"

# add SQl server tools to path
# export PATH="$PATH:/opt/mssql-tools/bin"


####Functions#####

# clock - A bash clock that can run in your terminal window. 
clock () 
{ 
while true;do clear;echo "===========";date +"%r";echo "===========";sleep 1;done 
}

#Extract function
extract () {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1        ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       rar x $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xf $1        ;;
             *.tbz2)      tar xjf $1      ;;
             *.tgz)       tar xzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

#dirsize - finds directory sizes and lists them for the current directory
dirsize ()
{
du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
egrep '^ *[0-9.]*M' /tmp/list
egrep '^ *[0-9.]*G' /tmp/list
rm -rf /tmp/list
}

# Change directory and list files
function cds(){
    # only change directory if a directory is specified
    [ -n "${1}" ] && cd $1
    ls
}

#####Latex with bib #Obsolete by latexmk
function dolatex(){
    if [ "$1" == "" ]
	then
	echo "No file given, remember no .tex"
	return
    fi
    latex $1.tex
    if [ -e "$1.nlo" ];
	then  
	makeindex $1.nlo -s nomencl.ist -o $1.nls
    else
	echo "No nomenclature"
    fi
    if [ -e "$1.aux" ];
	then  
	bibtex $1.aux
	bibtex $1.aux
    else
	echo "No bibliography file, remember bibfile should be some.bib if some.tex"
    fi
    latex $1.tex
}


##### Remove all files created by latex
function unlatex(){
if [ "$1" == "" ]; then
return
fi
i=${1%%.*}
rm -f $i.aux $i.toc $i.lof $i.lot $i.los $i.?*~ $i.loa $i.log $i.bbl $i.blg $i.glo
rm -f $i.odt $i.tns $i.fax $i.bm $i.out $i.nav $i.snm
rm -f $i.mtc* $i.bmt
mv -f $i.dvi .$i.dvi
mv -f $i.ps .$i.ps
mv -f $i.pdf .$i.pdf
rm -f $i.dvi $i.ps $i.pdf
unset i
}

#function command_exists () {
#    type "$1" &> /dev/null ;
#}

#function returns 1 if command exists
function exists () {
hash "$1" &> /dev/null 
if [ $? -eq 1 ]; then
    echo >&2 "foo not found."
fi
# $? stores output from the latest command. 
}
function command_exists () {
hash "$1" &> /dev/null 
if [ $? -eq 1 ]; then
    echo 1
else 
    echo 0
fi
# $? stores output from the latest command. 
}

##### Advanced ls function
# Counts files, subdirectories and directory size and displays details
# about files depending on the available space
function lls () {
    # count files
    echo -n "<`find . -maxdepth 1 -mindepth 1 -type f | wc -l | tr -d '[:space:]'` files>"
    # count sub-directories
    echo -n " <`find . -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d '[:space:]'` dirs/>"
    # count links
    echo -n " <`find . -maxdepth 1 -mindepth 1 -type l | wc -l | tr -d '[:space:]'` links@>"
    # total disk space used by this directory and all subdirectories
    echo " <~`du -sh . 2> /dev/null | cut -f1`>"
    ROWS=`stty size | cut -d' ' -f1`
    FILES=`find . -maxdepth 1 -mindepth 1 |
    wc -l | tr -d '[:space:]'`
    # if the terminal has enough lines, do a long listing
    if [ `expr "${ROWS}" - 6` -lt "${FILES}" ]; then
        ls
    else
        ls -hlAF --full-time
    fi
}



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/johan/google-cloud-sdk/path.bash.inc' ]; then . '/home/johan/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/johan/google-cloud-sdk/completion.bash.inc' ]; then . '/home/johan/google-cloud-sdk/completion.bash.inc'; fi

# CUDA 
# export PATH=/usr/local/cuda-10.0/bin${PATH:+:${PATH}}
# export LD_LIBRARY_PATH=/usr/local/cuda-10.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
# export LD_LIBRARY_PATH=/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/johan/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/johan/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/johan/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/johan/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

. "$HOME/.cargo/env"

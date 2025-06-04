# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='\n$(tput sc; tput setab 7; tput setaf 0; printf "%*s%s" $COLUMNS "\u@\h"; tput rc; tput setab 7; tput setaf 0;)\w$(tput sgr0)\n\$ '
PS1='\[\e[53m\]\D{%Y-%m-%d} \t\n\[\e[0m\]\u@\H\n\w\n\$ '

alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias restart='sudo systemctl restart'
alias reload='sudo systemctl reload'
alias reloadd='sudo systemctl daemon-reload'
alias enable='sudo systemctl enable'
alias disable='sudo systemctl disable'
alias status='sudo systemctl status'

alias dc='docker compose'

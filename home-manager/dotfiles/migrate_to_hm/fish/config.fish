# fish_config theme choose "Dracula Official"

if status is-interactive
    if not set -q TMUX
        colorscript random
    end
end

#print passed cli args 
set -g fish_greeting
# Commands to run in interactive sessions can go here
starship init fish | source

source ~/.aliases
alias bash='NO_FISH=1 /bin/bash'
zoxide init fish --cmd cd | source


# fzf-fish variables,
# fzf-fish: open selected search item in editor
set fzf_directory_opts --bind "alt-e:execute($EDITOR {} &> /dev/tty)"
# fzf-fish: diff highlighter
set fzf_diff_highlighter delta --paging=never --width=20
set fzf_fd_opts --hidden 


# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/rusich/.lmstudio/bin

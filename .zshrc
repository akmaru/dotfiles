#
# Shell Variables
#
SAVEHIST=10000
HISTSIZE=10000
HISTFILE=~/.zhistory
#SHELL=/bin/zsh

LANG=ja_jp.UTF-8

#
# Color Settings
#
autoload -U colors
colors
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
autoload -Uz is-at-least

# 以下の3つのメッセージをエクスポートする
#   $vcs_info_msg_0_ : 通常メッセージ用 (緑)
#   $vcs_info_msg_1_ : 警告メッセージ用 (黄色)
#   $vcs_info_msg_2_ : エラーメッセージ用 (赤)
zstyle ':vcs_info:*' max-exports 3

zstyle ':vcs_info:*' enable git 
#svn hg bzr
# 標準のフォーマット(git 以外で使用)
# misc(%m) は通常は空文字列に置き換えられる
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b]' '%m' '<!%a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true


if is-at-least 4.3.10; then
    # git 用のフォーマット
    # git のときはステージしているかどうかを表示
    zstyle ':vcs_info:git:*' formats '(%s)-[%b]' '%c%u %m'
    zstyle ':vcs_info:git:*' actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "+"    # %c で表示する文字列
    zstyle ':vcs_info:git:*' unstagedstr "*"  # %u で表示する文字列
fi


bindkey "^?" backward-delete-char


# hooks 設定
if is-at-least 4.3.11; then
    # git のときはフック関数を設定する

    # formats '(%s)-[%b]' '%c%u %m' , actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
    # のメッセージを設定する直前のフック関数
    # 今回の設定の場合はformat の時は2つ, actionformats の時は3つメッセージがあるので
    # 各関数が最大3回呼び出される。
    zstyle ':vcs_info:git+set-message:*' hooks \
                                            git-hook-begin \
                                            git-untracked \
                                            git-push-status \
                                            git-nomerge-branch \
                                            git-stash-count

    # フックの最初の関数
    # git の作業コピーのあるディレクトリのみフック関数を呼び出すようにする
    # (.git ディレクトリ内にいるときは呼び出さない)
    # .git ディレクトリ内では git status --porcelain などがエラーになるため
    function +vi-git-hook-begin() {
        if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
            # 0以外を返すとそれ以降のフック関数は呼び出されない
            return 1
        fi
	
	if pwd | command grep "/homesc2/kisimoto/eval" > /dev/null 2>&1; then
	    return 1
	fi
        return 0
    }

    # untracked フィアル表示
    #
    # untracked ファイル(バージョン管理されていないファイル)がある場合は
    # unstaged (%u) に ? を表示
    function +vi-git-untracked() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        if command git status --porcelain 2> /dev/null \
            | awk '{print $1}' \
            | command grep -F '??' > /dev/null 2>&1 ; then

            # unstaged (%u) に追加
            hook_com[unstaged]+='?'
        fi
    }

    # push していないコミットの件数表示
    #
    # リモートリポジトリに push していないコミットの件数を
    # pN という形式で misc (%m) に表示する
    function +vi-git-push-status() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        if [[ "${hook_com[branch]}" != "master" ]]; then
            # master ブランチでない場合は何もしない
            return 0
        fi

        # push していないコミット数を取得する
        local ahead
        ahead=$(command git rev-list origin/master..master 2>/dev/null \
            | wc -l \
            | tr -d ' ')

        if [[ "$ahead" -gt 0 ]]; then
            # misc (%m) に追加
            hook_com[misc]+="(p${ahead})"
        fi
    }

    # マージしていない件数表示
    #
    # master 以外のブランチにいる場合に、
    # 現在のブランチ上でまだ master にマージしていないコミットの件数を
    # (mN) という形式で misc (%m) に表示
    function +vi-git-nomerge-branch() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        if [[ "${hook_com[branch]}" == "master" ]]; then
            # master ブランチの場合は何もしない
            return 0
        fi

        local nomerged
        nomerged=$(command git rev-list master..${hook_com[branch]} 2>/dev/null | wc -l | tr -d ' ')

        if [[ "$nomerged" -gt 0 ]] ; then
            # misc (%m) に追加
            hook_com[misc]+="(m${nomerged})"
        fi
    }


    # stash 件数表示
    #
    # stash している場合は :SN という形式で misc (%m) に表示
    function +vi-git-stash-count() {
        # zstyle formats, actionformats の2番目のメッセージのみ対象にする
        if [[ "$1" != "1" ]]; then
            return 0
        fi

        local stash
        stash=$(command git stash list 2>/dev/null | wc -l | tr -d ' ')
        if [[ "${stash}" -gt 0 ]]; then
            # misc (%m) に追加
            hook_com[misc]+=":S${stash}"
        fi
    }

fi

function _update_vcs_info_msg() {
    local -a messages
    local prompt

    LANG=en_US.UTF-8 vcs_info

    if [[ -z ${vcs_info_msg_0_} ]]; then
        # vcs_info で何も取得していない場合はプロンプトを表示しない
        prompt=""
    else
        # vcs_info で情報を取得した場合
        # $vcs_info_msg_0_ , $vcs_info_msg_1_ , $vcs_info_msg_2_ を
        # それぞれ緑、黄色、赤で表示する
        [[ -n "$vcs_info_msg_0_" ]] && messages+=( "%F{green}${vcs_info_msg_0_}%f" )
        [[ -n "$vcs_info_msg_1_" ]] && messages+=( "%F{yellow}${vcs_info_msg_1_}%f" )
        [[ -n "$vcs_info_msg_2_" ]] && messages+=( "%F{red}${vcs_info_msg_2_}%f" )

        # 間にスペースを入れて連結する
        prompt="${(j: :)messages} [%h](%w/%t)"
    fi

    RPROMPT="$prompt"
}
add-zsh-hook precmd _update_vcs_info_msg

#
# Prompt
#
#PROMPT='%m:%~[%h]%# '
#TRI='⮀'
#PROMPT="%{${fg[black]}%}%{${bg[red]}%}%n@%m%{${fg[red]}${bg[green]}%}${TRI}"\
#"%{${fg[black]}%}%~%{${reset_color}${fg[green]}%}${TRI}"\
#"%{${reset_color}%} "
#PROMPT2="%B%{${fg[blue]}%}%_#%{${reset_color}%}%b "
#SPROMPT="%B%{${fg[blue]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
#RPROMPT="[%h](%w/%t)"
setopt prompt_subst
PROMPT='%{${fg[green]}%}%m[%~]%1(v|%F{yellow}%1v%f|) %{${fg[green]}%}%# %{${reset_color}%}'
RPROMPT="%{${fg[green]}%} %D %*[%h]%{${reset_color}%}"

#
# key bind
#
stty -istrip
case $OSTYPE in
    solaris*)
	stty intr '^c' erase '^h' kill '^u' susp '^z' dsusp '^y'
	;;
    linux*)
	stty intr '^c' erase '^h' kill '^u' susp '^z'
	;;
    irix*)
        ;;    
    default)
	stty intr '^c' erase '^h' kill '^u' susp '^z' dsusp '^y'
        ;;
esac
bindkey -me

#
# Options
#
setopt ignore_eof
setopt notify
setopt auto_list
setopt nobeep
setopt auto_pushd
setopt auto_cd


#
# Mail Settings
#
MAILPATH="/var/mail/$USER"
MAILCHECK=20

#
# Complementarity
#
autoload compinit
#compctl -/ cd chdir dirs pushd
compctl -c man which
compctl -g '*.tex' platex jlatex
compctl -g '*.dvi' xdvi dvi2ps
compctl -g '*.ps' gv lpr idraw
#compctl -k hosts rup ping nslookup
#compctl -k limitargs limit unlimit

# for Kasahara Lab.
#compctl -g '*.f' offe
#compctl -g '*.q' _+ -g '*.bq' mmp
#compctl -g '*.bq' mmp
#compctl -g '*.mq' shield ompfbe

#
# Aliases
#
alias ls='ls -F --color=yes'
alias l='ls -lAgs | less -r'
alias la='ls -A'
alias ll='ls -l'
alias wl='emacs -e wl'
alias emacs='TERM=xterm-256color emacs -nw'
alias gdb='emacs -f gud-gdb'
alias e='emacs'

# for study
alias setdmalloc='dmalloc -l dmalloc.log -i 100 low'

#
# Alias for each OS type
#
case $OSTYPE in
    solaris*)
	alias netscape='netscape > /dev/null 2>&1'
        alias emacs='emcws-21.2'
	;;
    linux*)
	if [ x$host != xrmc -a $HOST != "oscar111" ]; then
	    #alias less='jless'
	fi
        ;;
    irix*)
        ;;
esac    

#
# Functions
#
title () {echo -n "\e]0;$*\a"}
function dmalloc { eval `command dmalloc -b $*`; }

#
# OS local specific settings
#
case $OSTYPE in
    solaris*)
        limit coredumpsize 0
        ;;
    linux*)
        ulimit -c 0
        ;;
    irix*)
        ;;
    cygwin*)
        ;;
esac

#
# Machine specific settings
#
case $host in
    rmc)
	;;
    razzie)
	. /common1/sge/default/common/settings.sh
	;;
esac

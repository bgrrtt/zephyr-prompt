# vim:et sts=2 sw=2 ft=zsh
# =============================================================================
# Zephyr Prompt
# =============
# Requires zimfw's git-info module

# =============================================================================
# Prompt Character

zephyr_char () {
  success_char_str="%F{green}❯%F{green}❯"
  failure_char_str="%F{red}❯%F{red}❯"
  prompt_char_str="%(0?.$success_char_str.$failure_char_str) "
  echo $prompt_char_str
}


# =============================================================================
# Current Working Directory

zephyr_cwd () {
  inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
  if [ "$inside_git_repo" ]; then
    git_root_path="$(git rev-parse --show-toplevel)"
    git_root_dir="$git_root_path:t${${PWD:A}#$~git_root_path}"
    git_root_parent_dir="$(basename $(dirname $git_root_path))"
    cwd_str="%F{blue}$git_root_parent_dir/$git_root_dir "
  else
    cwd_str="%F{blue}%4(~:../:)%3~ "
  fi
  echo $cwd_str
}


# =============================================================================
# Time

zephyr_time () {
  time_str="%F{yellow}%D{%T}"
  echo $time_str
}


# =============================================================================
# Git

zephyr_git_active_branch () {
  git_branch_str="%F{white}${(e)git_info[active_branch]}%F{white} "
  echo $git_branch_str
}

zephyr_git_active_status () {
  git_status_str="%F{white}${(e)git_info[active_status]} "
  echo $git_status_str
}

zephyr_git_active_remote () {
  git_status_str="%F{red}${(e)git_info[active_remote]}%F{white} "
  echo $git_status_str
}

# =============================================================================
# Kubernetes Control Context

zephyr_kube_context () {
  local kube_context=$(kubectl config current-context 2>/dev/null)
  [[ -z $kube_context ]] && return
  local kube_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
  [[ -n $kube_namespace && "$kube_namespace" != "default" ]] && kube_context="$kube_context ($kube_namespace)"
  echo $kube_context
}


# =============================================================================
# Prompt

prompt_zephyr_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

prompt_zephyr_setup() {
  autoload -Uz add-zsh-hook && add-zsh-hook precmd prompt_zephyr_precmd

  setopt no_prompt_bang prompt_cr prompt_percent prompt_sp prompt_subst

  zstyle ':zim:git-info' verbose yes
  zstyle ':zim:git-info' ignore-submodules 'none'

  zstyle ':zim:git-info:action:apply' format 'apply'
  zstyle ':zim:git-info:action:bisect' format 'bisect: <B>'
  zstyle ':zim:git-info:action:cherry-pick' format 'cherry-pick'
  zstyle ':zim:git-info:action:cherry-pick-sequence' format 'cherry-pick-sequence'
  zstyle ':zim:git-info:action:merge' format 'merge: >M<'
  zstyle ':zim:git-info:action:rebase' format 'rebase: >R>'
  zstyle ':zim:git-info:action:rebase-interactive' format 'rebase-interactive'
  zstyle ':zim:git-info:action:rebase-merge' format 'rebase-merge'
  zstyle ':zim:git-info:action' format '%s'              # %s
  zstyle ':zim:git-info:ahead' format '%F{green} ⬆︎'      # %A
  zstyle ':zim:git-info:behind' format '%F{red} ⬇'       # %B
  zstyle ':zim:git-info:diverged' format '%F{magenta} ✖' # %V
  zstyle ':zim:git-info:branch' format '%b'              # %b
  zstyle ':zim:git-info:commit' format '%F{yellow}%c'    # %c
  zstyle ':zim:git-info:clean' format '%F{green}'        # %C
  zstyle ':zim:git-info:dirty' format '%F{yellow}'       # %D
  zstyle ':zim:git-info:indexed' format '%F{green} ✚'    # %i
  zstyle ':zim:git-info:unindexed' format '%F{blue} ✱'   # %I
  zstyle ':zim:git-info:position' format '%F{white} %p'  # %p
  zstyle ':zim:git-info:remote' format '%F{green}'       # %R
  zstyle ':zim:git-info:stashed' format '%F{magenta} ✦'  # %S
  zstyle ':zim:git-info:untracked' format '%F{red} ??'   # %u

  zstyle ':zim:git-info:keys' format \
          'active_branch' '%C%D%b%c%p' \
          'active_status' '%s%A%B%V%D%i%I%S%u' \
          'active_remote' '%R'

  new_line=$'\n'
  new_prompt_lines=${new_line}${new_line}${new_line}${new_line}

  PROMPT=''
  PROMPT+='${new_prompt_lines}'
  PROMPT+='$(zephyr_cwd)$(zephyr_git_active_remote)$(zephyr_git_active_branch)$(zephyr_kube_context)'
  PROMPT+='${new_line}'
  PROMPT+='$(zephyr_char)'

  RPROMPT=''
  RPROMPT+='$(zephyr_git_active_status)$(zephyr_time)'

}

prompt_zephyr_setup "${@}"

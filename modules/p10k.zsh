# Powerlevel10k configuration — compact single-line prompt with unicode
# Generated for devbox

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # ─── Prompt segments ────────────────────────────────────────────────────────
  # Left: status, directory, vcs
  # Right: command execution time, background jobs, context (user@host if SSH)
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    status
    dir
    vcs
    prompt_char
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    command_execution_time
    background_jobs
    context
    time
  )

  # ─── Basic style ────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_MODE=unicode
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate

  # Single line prompt
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=

  # No segment separators for a clean look
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''

  # Prompt spacing
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

  # ─── Colors (gruvbox-inspired, works on dark terminals) ────────────────────
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_FOREGROUND=250

  # ─── Status ─────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=196
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'

  # ─── Prompt character ───────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true

  # ─── Directory ──────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=75
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=111
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=75
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=40

  # Directory icons
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION='🔒'
  typeset -g POWERLEVEL9K_DIR_HOME_VISUAL_IDENTIFIER_EXPANSION='~'
  typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_DIR_ETC_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_EXPANSION=

  # ─── Git / VCS ──────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

  # Clean state
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
  # Modified
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=214
  # Untracked files
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=214
  # Conflicted
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=196
  # Loading (while gitstatus is starting)
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=244

  # Disable async loading indicator
  typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=

  # Git status formatting
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'

  # Git icons
  typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='⇣'
  typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='⇡'
  typeset -g POWERLEVEL9K_VCS_STASH_ICON='*'
  typeset -g POWERLEVEL9K_VCS_TAG_ICON='#'

  # ─── Command execution time ─────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=1
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=245
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION='⏱'

  # ─── Background jobs ────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=70
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='⚙'

  # ─── Context (user@host) — only show in SSH sessions ────────────────────────
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=244
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=196
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'

  # ─── Time ───────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=true
  typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=

  # ─── Instant prompt ─────────────────────────────────────────────────────────
  # Disabled for simplicity in a VM environment
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

  # ─── Hot reload ─────────────────────────────────────────────────────────────
  (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
  'builtin' 'unset' 'p10k_config_opts'
}

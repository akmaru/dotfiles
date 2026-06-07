#
# aws config (merge ~/.aws/conf.d/*.conf -> ~/.aws/config)
#
() {
  local confd=~/.aws/conf.d out=~/.aws/config
  local -a parts=( $confd/*.conf(-.N) )   # symlink を辿った regular file のみ / nullglob
  (( $#parts )) || return
  local newest=$parts[1] f
  for f in $parts[2,-1]; do [[ $f -nt $newest ]] && newest=$f; done
  if [[ ! -f $out || -L $out || $newest -nt $out ]]; then
    print "# AUTO-GENERATED from ~/.aws/conf.d/*.conf - do not edit." >| $out
    cat $parts >> $out
  fi
}

#
# aws: SSO の一時認証情報を環境変数にエクスポート
# usage: awsenv [profile]  (default: maru)
#
awsenv() {
  local profile=${1:-maru}
  # セッション切れなら自動ログイン
  aws sts get-caller-identity --profile $profile &>/dev/null || aws sso login --profile $profile || return
  eval "$(aws configure export-credentials --profile $profile --format env)"
  export AWS_DEFAULT_REGION=$(aws configure get region --profile $profile)
}

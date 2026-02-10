# bashrc shortcuts examples

example for `~/.bashrc`

```sh
alias dstart='sudo systemctl start docker'
alias dstop='sudo systemctl stop docker.socket docker.service'
alias dex='docker exec -it '
alias dexu='docker exec -it -u 33 '
alias docc='docker exec -it -u 33 '
alias dl='docker logs '
alias dlf='docker logs -f '
```

To enable autocompletion for container names, each alias needs a file in `~/.bashrc.d/`. Example for `~/.bashrc.d/docc` :

```sh
_docc()
{
  _script_commands=$(docker ps | sed '1d' | awk '{print $NF}')

  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${_script_commands}" -- ${cur}) )

  return 0
}
complete -S " php occ" -F _docc docc
```


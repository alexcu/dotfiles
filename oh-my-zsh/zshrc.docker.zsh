#!/usr/bin/env zsh

function dnames-fn {
  for ID in `docker ps | awk '{print $1}' | grep -v 'CONTAINER'`
  do
    docker inspect $ID | grep Name | head -1 | awk '{print $2}' | sed 's/,//g' | sed 's%/%%g' | sed 's/"//g'
  done
}

function dip-fn {
  echo "IP addresses of all named running containers"

  for DOC in `dnames-fn`
  do
    IP=`docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$DOC"`
    OUT+=$DOC'\t'$IP'\n'
  done
  echo -e $OUT | column -t
  unset OUT
}

function dex-fn {
  docker exec -it $1 ${2:-bash}
}

function di-fn {
  docker inspect $1
}

function dl-fn {
  docker logs -f $1
}

function drun-fn {
  docker run -it $1 $2
}

function dcr-fn {
  docker-compose run $@
}

function dsr-fn {
  docker stop $1;docker rm $1
}

function drmc-fn {
  docker rm $(docker ps --all -q -f status=exited)
}

function drmid-fn {
  imgs=$(docker images -q -f dangling=true)
  [ ! -z "$imgs" ] && docker rmi "$imgs" || echo "no dangling images."
}

alias di=di-fn
alias dim="docker images"
alias dex=dex-fn
alias dip=dip-fn
alias dl=dl-fn
alias dnames=dnames-fn
alias dps="docker ps --format 'table {{ .ID }}\t{{.Names}}\t{{.Status}}\t{{.RunningFor}}'"
alias dpsa="docker ps  --format 'table {{ .ID }}\t{{.Names}}\t{{.Status}}\t{{.RunningFor}}' -a"
alias drmc=drmc-fn
alias drmi=drmid-fn
alias drun=drun-fn
alias dbash="docker run -it bash:4.4"
alias dsp="docker system prune --all"
alias dsr=dsr-fn

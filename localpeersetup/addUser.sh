#!/bin/bash

function randomSecret {
   dd if=/dev/urandom bs=9 count=1 2>/dev/null| base64
}

function createUsers {
   local name="$1"
   local role="$2"
   local num="$3"
   local tname="test_$name"
   local ignore='[[[:alpha:]]|_|:'

   case "$role" in
      1) local lastUser=$(awk -v s="$tname" -v i="$ignore" '$1~s && NF==5 && $2==1 {gsub(i,"",$1);print $1}' $CAYAML | sort -n | tail -n1)
         local start="${lastUser:-0}"
      ;;
      4) local lastVp=$(awk -v s="$tname" -v i="$ignore" '$1~s && NF==3 && $2==4 {gsub(i,"",$1);print $1}' $CAYAML | sort -n | tail -n1)
         local start="${lastVp:-0}"
      ;;
      2) local lastNvp=$(awk -v s="$tname" -v i="$ignore" '$1~s && $2==2 {gsub(i,"",$1);print $1}' $CAYAML | sort -n | tail -n1)
         local start="${lastNvp:-0}"
      ;;
      8) local lastAud=$(awk -v s="$tname" -v i="$ignore" '$1~s && $2==2 {gsub(i,"",$1);print $1}' $CAYAML | sort -n | tail -n1)
         local start="${lastNvp:-0}"
      ;;
   esac

   while test "$((num--))" -gt "$start"; do
      awk -v s="test_$name$num:" -v rc=1 '$1==s {rc=0}; END {exit rc}' < $CAYAML && continue
      # name already defined
      case "$role" in
      # enter name, role, secret,
      4) echo "test_$name$num: $role $(randomSecret)"|sed 's/^/                /' ;;
      # enter name, role, secret, affiliate, affiliate_role
      1|2|8) printf "test_$name$num: $role $(randomSecret) institution_a\n" |sed 's/^/                /'
         ;;
      esac
   done
}

function addUsers {
   local num="$1"
   local Type="$2"
   local name="$3"
   createUsers $name $Type $num > /tmp/newUsers
   sed "/users:/r /tmp/newUsers" $CAYAML > ${CAYAML}.new
   cp ${CAYAML}.new $CAYAML
   return
}

test "$#" -eq 4 || exit 2
CAYAML=$1
NUM=$2
Type=$3
name=$4
addUsers $NUM $Type $name
exit 0

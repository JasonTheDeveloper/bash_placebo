dummy() {
  source test/fixtures/dummy.sh $@
}

list () {
  declare -f | awk '/ \(\) $/ && !/^list / {print $1}'
}

if [[ "$1" == "-l" ]] ; then
  list
  true
fi

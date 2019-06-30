#!/usr/bin/env bash

setUp() {
  mkdir test/fixtures/temp
}

tearDown() {
  rm -f /tmp/dummy
  rm -r "test/fixtures/temp/" 2> /dev/null
  rm -f expected_content
}

testPlayback() {
  . ./placebo
  pill_attach "data_path=test/fixtures/"
  pill_playback
  response=$(dummy response)
  assertEquals "response" "$response"
  pill_detach
}

testRecord() {
  . ./placebo
  pill_attach "data_path=test/fixtures/temp/"
  pill_record

  OLDPATH=$PATH
  PATH=/tmp:$PATH

  echo "echo foo" > /tmp/dummy ; chmod +x /tmp/dummy

  command_to_run="dummy response foo"
  mock $command_to_run > /dev/null

  cat > expected_content <<EOD
case "dummy \$*" in
'$command_to_run')
  cat <<'EOF'
foo
EOF
  ;;
*)
  echo "No responses for: dummy \$*"
  ;;
esac
EOD

  temp_res=$(_join_path $DATA_PATH "dummy.sh")

  assertEquals "" "$(diff -wu expected_content $temp_res)"
  assertEquals "foo" "$(/tmp/dummy)"
  assertEquals "$command_to_run" "$(pill_log)"

  PATH=$OLDPATH
  pill_detach
}

testRecordShortCommand() {
  . ./placebo
  pill_attach "data_path=test/fixtures/temp/"
  pill_record

  OLDPATH=$PATH
  PATH=/tmp:$PATH

  echo "echo foo" > /tmp/dummy ; chmod +x /tmp/dummy

  command_to_run="dummy help"
  mock $command_to_run > /dev/null
  cat > expected_content <<EOD
case "dummy \$*" in
'$command_to_run')
  cat <<'EOF'
foo
EOF
  ;;
*)
  echo "No responses for: dummy \$*"
  ;;
esac
EOD

  temp_res=$(_join_path $DATA_PATH "dummy.sh")

  assertEquals "" "$(diff -wu expected_content $temp_res)"

  PATH=$OLDPATH
  pill_detach
}

testDataPathIsADir() {
  . ./placebo
  response=$(pill_attach "data_path=test/fixtures/dummy.sh" | head -1)
  assertEquals \
    "DATA_PATH should be a path to a directory but you specified a file" \
    "$response"
  pill_detach
}

testPillNotSet() {
  . ./placebo
  pill_attach "data_path=test/fixtures/temp/"
  response=$(mock dummy foo)
  assertEquals \
    "PILL must be set to or record. Try pill_record" \
    "$response"
  pill_detach
}

testDataPathNotSet() {
  . ./placebo
  pill_record
  unset DATA_PATH # not sure why this line is required.
  response=$(mock dummy foo)
  assertEquals \
    "DATA_PATH must be set. Try pill_attach" "$response"
}

testExecutePlacebo() {
  response=$(bash ./placebo)
  assertTrue "echo $response | grep -q ^Usage"
  pill_detach
}

testDetach() {
  funcs="_usage
pill_attach
pill_playback
pill_record
pill_log
pill_detach
_create_new
_update_existing
_filter
_record
_contains
_save_func
dummy
mock"
  . ./placebo
  pill_detach
  for f in $funcs ; do
    assertFalse "function $f is still defined" "type $f"
  done
  assertTrue "[ -z $PILL ]"
  assertTrue "[ -z $DATA_PATH ]"
  assertFalse "[ -e commands_log ]"
}

testMainUsage() {
  response=$(. ./placebo -h)
  assertEquals "Usage: . test/placebo.sh [-h]" "$response"
}

testPillFunctionUsage() {
  . ./placebo
  response=$(pill_playback -h)
  assertEquals "Usage: pill_playback [-h]
Sets Placebo to playback mode" "$response"
  pill_detach
}

. shunit2

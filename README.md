# Placebo for Bash

This repository is a fork of alexharv074's [bash_placebo](https://github.com/alexharv074/bash_placebo).

Major difference between the two projects is this project is built to generate mock commands for unit testing with any bash command while the original is built specifically to mock `aws` cli commands.

## Installation

The tool can be installed just by copying the script from the master branch into your path somewhere. E.g.

```sh
curl -o /usr/local/bin/placebo \
    https://raw.githubusercontent.com/JasonTheDeveloper/bash_placebo/generic/placebo
```

## Quick Start

Using record mode to save response in a file `test/fixtures/`:

```sh
. placebo
pill_attach data_path=test/fixtures/
pill_record
```

Now that you're in record mode, you can go ahead and enter your commands. Make sure you put `mock` in front of your command.

For example:

```sh
mock your_command foo
```

Reading those responses back in the context of your unit tests:

```sh
. placebo
pill_attach data_path=test/fixtures/
pill_playback
```

In playback mode, you can enter the commands you mocked earlier while in record mode like normal and Placebo will return the original response.

for example:

```sh
your_command foo
```

Once you're done, you must clean up your shell environment. Not doing so will mean Placebo will still be active and will continue to override your commands mocked earlier.

To clean up:

```sh
pill_detach
```

## Testing Placebo

You'll find under `test/` a `placebo.sh` script used to test Placebo. 

### Dependency

* [shUnit2](https://github.com/kward/shunit2)

### Running Unit Test

With shUnit2 installed, from the root of this project in a new terminal window, run the following command:

```sh
bash test/placebo.sh
```

## Manual Mocking

If you want to create fake responses manually that can be read in later by Placebo, it is quite simple. They are formatted as case statements. For example:

```sh
case "dummy $*" in
'dummy command subcommand some args')
  echo some_response
  ;;
'dummy command subcommand some other args')
  echo some_other_response
  ;;
esac
```

## Spies

A log of all commands can be obtained using the `pill_log` function, allowing the mocks to be "spies" on commands called. 

Using [shUnit2](https://github.com/kward/shunit2), for example:

```sh
testCommandsLogged() {
  . $script_under_test
  assertEquals "$(<expected_log)" "$(pill_log)"
}
```

## Contributing

PRs are welcome. To run the tests:

Ensure you have dependencies installed:

- ShellCheck
- [shUnit2](https://github.com/kward/shunit2)

Then run make:

```sh
make
```

Support is available so feel free to raise issues.

# Usage

This directory contains a docker image that is used as a target for the inspec tests.

## Launching the inspec-target container interactively

If you wish to debug failures of the inspec tests you may wish to manually run the syntax commands on the target container.
First run the `interactive.sh` script shown below. This script will build an `inspec-target` container and run an interactive shell in that           container. This interactive shell must be running for inspec to connect to the        container. This shell can also be used to debug failed tests    conditions.

```shell
./target/interactive.sh
```

> :exclamation: Do not close this window and proceed to the next step.

You can modify the `interactive.sh` to pass environmental variables that are required for your test examples.

# Usage

This directory contains a docker image that is used as a target for the inspec tests.

```shell
./launch.sh
```

# Customization

You can modify the `launch.sh` to pass environmental variables that are required for your test examples.

You can include files such as the example `*.tf` files in this directory to allow commands such as `terraform plan` to be tested with stand-in data.



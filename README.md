# Overview

<p align="center">
  <img width="480" height="252" src="/images/diagram.png">
</p>

This repo contains [inspec](https://www.inspec.io/) integration with the [learn](https://github.com/hashicorp/learn) platform. It uses docker to run inspec. Tests/Controls are __automatically generated__ by extracting fenced code blocks from the markdown (mdx). Each test then runs against an target docker container via a mounted docker socket. You can customize the environment of this "target" with real world environmental variables such as AWS Keys to do live tests with example code. You can modify this target with stand-in configurations by rebuilding the target docker container. 

> Currently these tests run syntax checks against terraform hcl, json and shell.
> See the [RFC](https://docs.google.com/document/d/1TgyrGkmdr4FCyLHN9OKYR2bEMNlJIFNS8QhQyTBXDlg/edit#) for an explanation of active vs passive testing.

# Usage

Executing this code requires two containers. The inspec container is not actually required but is provided to minimize workstation requirements. The `inspec-target` is automatically spun up. You can also run it interactivly to debug using [`./target/interactive.sh`](target/interactive.sh)

# Requirements

Docker is required, you can download it [here](https://hub.docker.com/editions/community/docker-ce-desktop-mac).

## Executing an inspec profile 

In a terminal window , run the `./run.sh` script shown below. The code extracts markdown content from your local checkout/branch of the learn repo. You must provide the path to the root of your local learn repo with `-d`. You can then pass which product you wish to run tests against with. These product names correspond to inspec [profiles](https://www.inspec.io/docs/reference/profiles/)


```shell
./run.sh -p terraform -d ~/src/learn
./run.sh -p vault -d ~/src/learn
./run.sh -p nomad -d ~/src/learn
./run.sh -p consul -d ~/src/learn
```

> You can run all profiles with `-p all`
> You can pipe the output with color with `| less -r`
### Product profiles


| Profile                            | Notes                                                                         |
| ---------------------------------- | -----------------------------------------------------------------------------:|
| [terraform](profile/terraform)     | Extracts all `hcl`, `shell`, `json` and `yaml` codeblocks and validates them  |
| [vault](profile/vault)             | Extracts all `shell`, `json` and `yaml` codeblocks validates them             |
| [nomad](profile/nomad)             | Extracts all `shell`, `json` and `yaml` codeblocks validates them             |
| [consul](profile/consul)           | Extracts all `shell`, `json` and `yaml` codeblocks validates them             |

> `terraform` validates syntax by passing each block as stdin via `terraform fmt -`.

### Utility profiles

| Profile                  | Notes                                                                                                    |
| ------------------------ | --------------------------------------------------------------------------------------------------------:|
| [all](profile/all)       | For use with the `./run.sh` script. Runs all product profiles                                            |
| [shared](profile/shared) | Used to store shared custom resources for inspec [libraries](profiles/shared/libraries)                  |
| [github](profile/github) | Used with Github Action, expects `GITHUB` environment vars for commit lookup                             |

# Support Files

## [`run.sh`](run.sh)

This script is used by authors and developers to run the tests locally.

## [`input.yml`](input.yml)

This file contains inputs to (globally) to the inspec profiles. It currently is used by `shell_syntax` custom resource to do dynamic replacments for placeholders in the code. This replacements hash allows us to run syntax checks on commands that otherwise would be invalid syntax with the placeholder.

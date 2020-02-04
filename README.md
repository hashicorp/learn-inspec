# Overview

![Diagram](/images/diagram.png)


This repo contains [inspec](https://www.inspec.io/) integration with the [learn](https://github.com/hashicorp/learn) platform. It uses docker to run inspec. Tests/Controls are __automatically generated__ by extracting fenced code blocks from the markdown (mdx). Each test then runs against an target docker container via docker in docker. You can customize the environment of this "target" with real world environmental variables such as AWS Keys to do live tests with example code. You can modify this target with stand-in configurations by rebuilding the target docker container. 

> Currently these tests run syntax checks against terraform hcl, json and shell.
> See the [RFC](https://docs.google.com/document/d/1TgyrGkmdr4FCyLHN9OKYR2bEMNlJIFNS8QhQyTBXDlg/edit#) for an explanation of active vs passive testing.

# Usage

Executing this code requires two containers. The first container is not required but is provided to minimize workstation requirements.


## Launching the inspec-target container

First run the `launch.sh` script shown below. This script will build an `inspec-target` container and run an interactive shell in that container. This interactive shell must be running for inspec to connect to the container. This shell can also be used to debug failed tests conditions.

```shell
./target/launch.sh
```

> :exclamation: Do not close this window and proceed to the next step.

## Launching the inspec container

In a new terminal window , run the `./extract_and_run.sh` script shown below. The code extracts markdown content from your local checkout/branch of the learn repo. You must provide the path to the root of your local learn repo with `-d`. You can then pass which product you wish to run tests against with. These product names correspond to inspec [profiles](https://www.inspec.io/docs/reference/profiles/)


```shell
./extract_and_run.sh -p terraform -d ~/src/learn
./extract_and_run.sh -p vault -d ~/src/learn
./extract_and_run.sh -p nomad -d ~/src/learn
./extract_and_run.sh -p consul -d ~/src/learn
```

> You can run all profiles with `-p all`

### Support profiles


| Profile       | Supported     | Notes                                                                         |
| ------------- |:-------------:| -----------------------------------------------------------------------------:|
| terraform     | yes           | Extracts all `hcl`, `shell`, `json` and `yaml` codeblocks and validates them  |
| vault         | yes           | Extracts all `shell`, `json` and `yaml` codeblocks validates them             |
| nomad         | yes           | Extracts all `shell`, `json` and `yaml` codeblocks validates them             |
| consul        | yes           | Extracts all `shell`, `json` and `yaml` codeblocks validates them             |

> `terraform` validates syntax by passing each block as stdin via `terraform fmt -`.

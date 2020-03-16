# Overview

![Diagram](/images/diagram.png)


This repo contains [inspec](https://www.inspec.io/) integration with the [learn](https://github.com/hashicorp/learn) platform. It uses docker to run inspec. Tests/Controls are __automatically generated__ by extracting fenced code blocks from the markdown (mdx). Each test then runs against an target docker container via docker in docker. You can customize the environment of this "target" with real world environmental variables such as AWS Keys to do live tests with example code. You can modify this target with stand-in configurations by rebuilding the target docker container. 

> Currently these tests run syntax checks against terraform hcl, json and shell.
> See the [RFC](https://docs.google.com/document/d/1TgyrGkmdr4FCyLHN9OKYR2bEMNlJIFNS8QhQyTBXDlg/edit#) for an explanation of active vs passive testing.

# Usage

Executing this code requires two containers. The inspec container is not actually required but is provided to minimize workstation requirements.


## Running the tests on learn.hashicorp.com 

In a new terminal window , run the `./run.sh` script shown below. The code extracts markdown content from your local checkout/branch of the learn repo. You must provide the path to the root of your local learn repo with `-d`. You can then pass which product you wish to run tests against with. These product names correspond to inspec [profiles](https://www.inspec.io/docs/reference/profiles/)


```shell
./run.sh -p terraform -d ~/src/learn
./run.sh -p vault -d ~/src/learn
./run.sh -p nomad -d ~/src/learn
./run.sh -p consul -d ~/src/learn
```

> You can run all profiles with `-p all`
> You can pipe the output with color with `| less -r`
### Support profiles


| Profile       | Supported     | Notes                                                                         |
| ------------- |:-------------:| -----------------------------------------------------------------------------:|
| terraform     | yes           | Extracts all `hcl`, `shell`, `json` and `yaml` codeblocks and validates them  |
| vault         | yes           | Extracts all `shell`, `json` and `yaml` codeblocks validates them             |
| nomad         | yes           | Extracts all `shell`, `json` and `yaml` codeblocks validates them             |
| consul        | yes           | Extracts all `shell`, `json` and `yaml` codeblocks validates them             |

> `terraform` validates syntax by passing each block as stdin via `terraform fmt -`.

## Launching the inspec-target container interactively

If you wish to debug failures of the inspec tests you may wish to manually run the syntax commands on the target container.
First run the `interactive.sh` script shown below. This script will build an `inspec-target` container and run an interactive shell in that container. This interactive shell must be running for inspec to connect to the        container. This shell can also be used to debug failed tests conditions.

```shell
./target/interactive.sh
```

 > :exclamation: Do not close this window and proceed to the next step.
 

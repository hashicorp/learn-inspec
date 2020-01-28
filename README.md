# Overview

This repo contains [inspec](https://www.inspec.io/) integration with the learn platform. It uses docker to run inspec. Tests/Controls are __automatically generated__ by extracting fenced code blocks from the markdown (mdx). Each test then runs against an addtional docker container via docker in docker. You can customize the environment of this "target" with real world environmental variables such as AWS Keys to do live tests with example code. You can modify this indprv target with stand-in files or modified configurations by rebuilding the target docker container. 

# Usage

Executing this requires two containers. The first container is not required but is provided as low price of admission in terms of ruby management.


## Launching the inspec-target container

In a new terminal window , run the launch script below. This script will build the `inspec-target` container and run an interactive shell in that container. This interactive shell must be running for inspec to connect to the container. This shell can then be used to manually debug failed tests by allowing you to reproduce the error in identical conditions.

```shell
./target/launch.sh
```

> Do not close this window and proceed to the next step.

## Launching the inspec container

Inspec can run tests against your local branch of the learn repo. You must provide the path to the root of your local learn repo with `-d`.
You can then pass which product you wish to run tests against with. These product names corrispond to inspec [profiles](https://www.inspec.io/docs/reference/profiles/)


```shell
./extract_and_run.sh -p terraform -d ~/src/learn
```

### Support profiles


| Profile       | Supported     | Notes                                                                                                |
| ------------- |:-------------:| ----------------------------------------------------------------------------------------------------:|
| terraform     | yes           | Extracts all hcl codeblocks in pages/terraform and runs `terraform validate` against them |

> `terraform` validates syntax by passing each block as stdin.

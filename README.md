# GENIE
### Guarding the npm Ecosystem with Semantic Malware Detection


---


#### Disclaimer

The repository contains malicious packages that were uploaded to the npm registry.
In ```packages/dataset/``` we include the packages that were used to develop the CodeQL queries.
In ```packages/report/``` we include the packages that were detected as malicious once applied our approach.


## Overview

**GENIE** is a command-line tool designed to apply CodeQL queries to the npm registry, with the aim of finding malicious JavaScript packages.
It provides functionality to download packages, build and scan databases, and compute the overall results.
The CodeQL queries defined for the paper are provided in ```queries/```, while the malware is stored in ```packages/```.

In the paper, we develop **CodeQL** queries to detect malicious packages in the **npm** registry.
Using recently reported packages as templates, for developing specific CodeQL queries, we aim to discover semantically similar malware in the ecosystem.


## Installation

Before using GENIE, ensure that the following is installed on your system.

* [GNU Parallel](https://www.gnu.org/software/parallel/)

* [npm CLI](https://docs.npmjs.com/cli/v10) (as **npm** in `$PATH`)

* [CodeQL](https://codeql.github.com) (as **codeql** in `$PATH`)
  * *Where the executable needs to be in the same directory as its libraries.*

Once done this, make sure to clone the necessary submodules (```git submodule update --init --recursive```).

Now everything should be ready to use GENIE.


## Usage

The entry point of the project is ```scripts/main.sh```.

```
> ./scripts/main.sh
GENIE | Select an action to perform...
1) Help
2) Exit
3) Setup
4) Delete
GENIE >
```

It is necessary to initialize the project before starting to work on it.

```
GENIE > 3
Setting up project...
mkdir: created directory '1_Registry/'
mkdir: created directory '1_Registry/NPM/'
mkdir: created directory '2_CodeBase/'
mkdir: created directory '2_CodeBase/NPM/'
mkdir: created directory '3_DataBase/'
mkdir: created directory '3_DataBase/NPM/'
mkdir: created directory '4_query/'
mkdir: created directory '4_query/output/'
mkdir: created directory '5_hash/'
mkdir: created directory '5_hash/data/'
mkdir: created directory '5_hash/code/'
mkdir: created directory '5_hash/match/'
mkdir: created directory 'log/'
mkdir: created directory 'log/1_download/'
mkdir: created directory 'log/2_source/'
mkdir: created directory 'log/3_build/'
mkdir: created directory 'log/4_clean/'
mkdir: created directory 'log/5_query/'
mkdir: created directory 'log/6_hash/'
mkdir: created directory 'log/parallel/'
GENIE >
```

- To download every package from the npm registry.
```
> nohup ./scripts/main.sh -d > download.out &
```

- To build the database for every package from the npm registry.
```
> nohup ./scripts/main.sh -b > build.out &
```

- To compact the disk space used by the databases.
```
> nohup ./scripts/main.sh -c > clean.out &
```

- To apply some queries to the databases.
```
> nohup ./scripts/main.sh -q <QUERY_PATH> > <QUERY_NAME>.out &
```

- To see a pretty-print message with some log information.
```
> nohup ./scripts/main.sh -l <LOG_PATH> > log.out &
```

- To calculate the SHA fingerprint for every package from the npm registry.
```
> nohup ./scripts/main.sh -h > hash.out &
```


## Organization

#### Repository
```
| README.md
| all_NPM_package_names/
--| names.json
--| ...
| codeql/
--| ...
| data/
--| stats_evaluation/
--| stats_obfuscation/
| packages/
--| dataset/
--| report/
--| dataset_index.csv
--| report_index.csv
| query/
--| malware/
--| obfuscator/
--| qlpack.yml
| scripts/
--| delete.sh
--| main.sh
--| registry.sh
--| setup.sh
--| utils_FS.sh
--| utils_NPM.sh
--| utils_QL.sh
--| variables.sh
```

#### Snapshot
```
| 1_Registry/NPM/
| 2_CodeBase/NPM/
| 3_DataBase/NPM/
| 4_query/output/
| 5_hash/
--| code/
--| data/
--| match/
| log/
--| 1_download/
--| 2_source/
--| 3_build/
--| 4_clean/
--| 5_query/
--| 6_hash/
--| parallel/
```

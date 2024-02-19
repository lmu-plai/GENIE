# GENIE
### Guarding the npm Ecosystem: CodeQL-based Detection of Malicious Packages

---

#### Disclaimer

The repository contains malicious packages that were uploaded to the npm registry.
In ```packages/dataset/``` we include the packages that were used to develop the CodeQL queries.
In ```packages/report/``` we include the packages that were detected as malicious once applied our approach.

## Objective

Develop **CodeQL** queries to detect malicious packages in the **npm** registry.

The idea is to design queries iteratively, using recently reported packages as templates, and continuously study the progress made by applying them to CodeQL databases.

## Install

* parallel

* npm (as **npm** in `$PATH`)

* codeql (as **codeql** in `$PATH`)
  * *Where the executable needs to be in the same directory as its libraries.*

From CodeQL documentation...

> The default exclusion patterns cause the following files to be excluded: All *JavaScript* files whose name ends with `-min.js` or `.min.js`. Such files typically contain minified code. Since *LGTM* by default does not show results in minified files, it is not usually worth extracting them in the first place.

To tell the CodeQL JavaScript Auto-Builder not to exclude minified files by default, set the following environment variable:

```bash
export LGTM_INDEX_FILTERS="include: **/*-min.js
                           include: **/*.min.js"
```

## How-to

The entry point of the project is ```scripts/main.sh```.

```
> ./scripts/main.sh
DEMISEC | Select an action to perform...
1) Help
2) Exit
3) Setup
4) Delete
DEMISEC >
```

It is necessary to prepare the directory before start working on the project.

```
DEMISEC > 3
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
DEMISEC >
```

To download each NPM's package.

```
> nohup ./scripts/main.sh -d > download.out &
```

To check the progress of the last command.

```
> tail -f download.out
```

To build a CodeQL's database for each NPM's package.

```
> nohup ./scripts/main.sh -b > build.out &
```

To check the progress of the last command.

```
> tail -f build.out
```

To compact the disk space for all CodeQL's databases.

```
> nohup ./scripts/main.sh -c > clean.out &
```

To check the progress of the last command.

```
> tail -f clean.out
```

To apply some query to all CodeQL's databases.

```
> nohup ./scripts/main.sh -q <QUERY_PATH> > <QUERY_NAME>.out &
```

To check the progress of the last command.

```
> tail -f <QUERY_NAME>.out
```

To see a pretty-print message with some log information.

```
> nohup ./scripts/main.sh -l <LOG_PATH> > log.out &
```

To calculate the SHA fingerprint for each NPM's package.

```
> nohup ./scripts/main.sh -h > hash.out &
```

To check the progress of the last command.

```
> tail -f hash.out
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

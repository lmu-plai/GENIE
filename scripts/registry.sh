echo "Working with the snapshot of NPM..."


SCRIPT_FS=$SCRIPTS'utils_FS.sh'
SCRIPT_QL=$SCRIPTS'utils_QL.sh'
SCRIPT_NPM=$SCRIPTS'utils_NPM.sh'

source $SCRIPT_FS
source $SCRIPT_QL
source $SCRIPT_NPM

# ---------- #

<<doc
Download a single NPM package.
doc
download_Package()
{
    # Need to parse the .json file to get a clean package name
    NPM_Package=$@
    NPM_Package=${NPM_Package//\ /} # Remove all ' ' characters
    NPM_Package=${NPM_Package//\,/} # Remove all ',' characters
    NPM_Package=${NPM_Package//\"/} # Remove all '"' characters

    # Ignore array delimiters
    if [[ $NPM_Package == '['* ]] || [[ $NPM_Package == *']' ]] ; then exit $OMITTED_CODE; fi

    # Just to be safe, remove some special characters
    NPM_Name=${NPM_Package//\//\@} # Replace all '/' characters for '@' characters
    NPM_Name=${NPM_Name//\*/\_}    # Replace all '*' characters for '_' characters
    NPM_Name=${NPM_Name//\~/\_}    # Replace all '~' characters for '_' characters
    NPM_Name=${NPM_Name//\'/\_}    # Replace all ''' characters for '_' characters

    # Where we want to store the compressed tar
    DS_Path=$GENIE_DS_NPM$NPM_Name
    # Where we want to store the source code
    CB_Path=$GENIE_CB_NPM$NPM_Name
    # Where we want to store log information
    LOG_SOURCE=$GENIE_LOG_Source$NPM_Name$LOG_EXTENSION
    LOG_DOWNLOAD=$GENIE_LOG_Download$NPM_Name$LOG_EXTENSION

    # Check if already downloaded this package
    if [ -d $DS_Path ]; then exit $OMITTED_CODE; fi

    # Downloading Package
    UTILS_Download_PKG "$NPM_Package" $DS_Path $LOG_DOWNLOAD
    if [ $? -ne 0 ]; then exit $FAILURE_CODE_DOWNL; fi

    # Creating CodeBase
    UTILS_Create_CB $DS_Path/*$TGZ_EXTENSION $CB_Path $LOG_SOURCE
    if [ $? -ne 0 ]; then exit $FAILURE_CODE_UNTAR; fi

    # Generating dummy-file
    UTILS_Dummy_JS $CB_Path

    exit $SUCCESS_CODE;
}

<<doc
Download all the NPM packages.
doc
download_NPM()
{
    # LOG for Parallel-Job
    JOB_Path=$GENIE_LOG_Parallel'download_NPM'$LOG_EXTENSION

    SECONDS=0

    export -f download_Package
    # For each package in NPM's Repository...
    parallel --eta              \
             --jobs 128         \
             --delay 0.01       \
             --joblog $JOB_Path \
             --resume           \
             download_Package :::: $ALL_NPM_NAMES

    echo "Done in... $SECONDS seconds"
}

# ---------- #

<<doc
Build a CodeQL's database for a single NPM package.
doc
build_Package()
{
    CB_Path=$1

    # Only care for the package's name
    NPM_Name=$(basename $CB_Path);

    # Where we want to store CodeQL's database
    DB_Path=$GENIE_DB_NPM$NPM_Name
    # Where we want to store log information
    LOG_BUILD=$GENIE_LOG_Build$NPM_Name$LOG_EXTENSION

    # Check if already built the DB for this package
    if [ -d $DB_Path ]; then exit $OMITTED_CODE; fi

    # Creating DataBase
    UTILS_Create_DB $CB_Path $DB_Path $LOG_BUILD
    if [ $? -ne 0 ]; then exit $FAILURE_CODE_BUILD; fi

    exit $SUCCESS_CODE;
}

<<doc
Build the CodeQL's database for each NPM's package.
doc
build_NPM()
{
    # CBs from where to build DBs
    CB_Path=$GENIE_CB_NPM
    # LOG for Parallel-Job
    JOB_Path=$GENIE_LOG_Parallel'build_NPM'$LOG_EXTENSION

    SECONDS=0

    # Since the argument would be too long, we save all paths in a .tmp file
    ALL_CBs=$GENIE_CB'all_CBs'$TMP_EXTENSION

    touch $ALL_CBs
    for Single_CB in $CB_Path*; do
        echo $Single_CB >> $ALL_CBs
    done

    export -f build_Package
    # For each downloaded package of NPM's Repository...
    parallel --eta              \
             --jobs 32          \
             --delay 0.1        \
             --timeout 300      \
             --joblog $JOB_Path \
             --resume           \
             build_Package :::: $ALL_CBs

    # Don't need this .tmp file anymore
    rm $ALL_CBs

    echo "Done in... $SECONDS seconds"
}

# ---------- #

<<doc
Clean a CodeQL's database for a single NPM package.
doc
clean_Package()
{
    DB_Path=$1

    # Only care for the package's name
    NPM_Name=$(basename $DB_Path);

    # Where we want to store log information
    LOG_CLEAN=$GENIE_LOG_Clean$NPM_Name$LOG_EXTENSION

    # Cleaning DataBase
    UTILS_Clean_DB $DB_Path $LOG_CLEAN
    if [ $? -ne 0 ]; then exit $FAILURE_CODE_CLEAN; fi

    exit $SUCCESS_CODE;
}

<<doc
Clean the CodeQL's database for each NPM's package.
doc
clean_NPM()
{
    # DBs which we want to clean
    DB_Path=$GENIE_DB_NPM
    # LOG for Parallel-Job
    JOB_Path=$GENIE_LOG_Parallel'clean_NPM'$LOG_EXTENSION

    SECONDS=0

    # Since the argument would be too long, we save all paths in a .tmp file
    ALL_DBs=$GENIE_DB'all_DBs'$TMP_EXTENSION

    touch $ALL_DBs
    for Single_DB in $DB_Path*; do
        echo $Single_DB >> $ALL_DBs
    done

    export -f clean_Package
    # For each built database from the NPM's Repository...
    parallel --eta              \
             --jobs 128         \
             --delay 0.005      \
             --joblog $JOB_Path \
             --resume           \
             clean_Package :::: $ALL_DBs

    # Don't need this .tmp file anymore
    rm $ALL_DBs

    echo "Done in... $SECONDS seconds"
}

# ---------- #

<<doc
Query a CodeQL's database for a single NPM package.
doc
query_Package()
{
    QUERY_Path=$1
    DB_Path=$2

    # Only care for the package's name
    NPM_Name=$(basename $DB_Path);

    # Where we want to store CodeQL's results
    OUT_Path=$GENIE_QUERY_Output$NPM_Name$OUT_EXTENSION
    # Where we want to store log information
    LOG_QUERY=$GENIE_LOG_Query$NPM_Name$LOG_EXTENSION

    # Querying DataBase
    UTILS_Query_DB $QUERY_Path $DB_Path $OUT_Path $LOG_QUERY
    if [ $? -ne 0 ]; then exit $FAILURE_CODE_QUERY; fi

    exit $SUCCESS_CODE;
}

<<doc
Query the CodeQL's database for each NPM's package.
doc
query_NPM()
{
    QUERY_Path=$@

    # DBs which we want to query
    DB_Path=$GENIE_DB_NPM
    # LOG for Parallel-Job
    JOB_Path=$GENIE_LOG_Parallel'query_NPM'$LOG_EXTENSION

    SECONDS=0

    # Since the argument would be too long, we save all paths in a .tmp file
    ALL_DBs=$GENIE_DB'all_DBs'$TMP_EXTENSION

    touch $ALL_DBs
    for Single_DB in $DB_Path*; do
        echo $Single_DB >> $ALL_DBs
    done

    export -f query_Package
    # For each built database from the NPM's Repository...
    parallel --eta              \
             --jobs 16          \
             --delay 1          \
             --timeout 900      \
             --joblog $JOB_Path \
             --resume           \
             query_Package ::: $QUERY_Path :::: $ALL_DBs

    # Don't need this .tmp file anymore
    rm $ALL_DBs

    echo "Done in... $SECONDS seconds"
}

# ---------- #

<<doc
Fingerprint Approach: Apply hash-matching to a single package.
doc
hash_Package()
{
    CB_Path=$1

    # Only care for the package's name
    NPM_Name=$(basename $CB_Path);

    # Where we want to store package's fingerprint
    SHA_Path=$GENIE_SHA_Code$NPM_Name$SHA_EXTENSION
    # Where we want to store hash-matching result
    CMP_Path=$GENIE_SHA_Match$NPM_Name$CMP_EXTENSION
    # Where we want to store log information
    LOG_HASH=$GENIE_LOG_Hash$NPM_Name$LOG_EXTENSION

    # Generating fingerprint for package
    UTILS_Generate_SHA $CB_Path $SHA_Path $LOG_HASH
    if [ $? -ne 0 ]; then exit $FAILURE_CODE_PRINT; fi

    # Searching for SHA matches
    for malware_SHA in $GENIE_SHA_Data*; do
        malware_Name=$(basename $malware_SHA $SHA_EXTENSION);

	UTILS_Compare_SHA $SHA_Path $malware_SHA $LOG_HASH
	if [ $? -eq 0 ]; then echo $malware_Name >> $CMP_Path; fi
    done

    exit $SUCCESS_CODE;
}

<<doc
Fingerprint Approach: Search for malware matches via hashing in all of NPM.
doc
hash_NPM()
{
    # CBs that will be hashed
    CB_Path=$GENIE_CB_NPM
    # LOG for Parallel-Job
    JOB_Path=$GENIE_LOG_Parallel'hash_NPM'$LOG_EXTENSION

    SECONDS=0

    # Since the argument would be too long, we save all paths in a .tmp file
    ALL_CBs=$GENIE_CB'all_CBs'$TMP_EXTENSION

    touch $ALL_CBs
    for Single_CB in $CB_Path*; do
        echo $Single_CB >> $ALL_CBs
    done

    export -f hash_Package
    # For each downloaded package of NPM's Repository...
    parallel --eta              \
             --jobs 128         \
             --delay 0.005      \
             --joblog $JOB_Path \
             --resume           \
             hash_Package :::: $ALL_CBs

    # Don't need this .tmp file anymore
    rm $ALL_CBs

    echo "Done in... $SECONDS seconds"
}

# ---------- #

<<doc
A helper function to check process' progress while working with NPM.
doc
log_NPM()
{
    Parallel_LOG=$@

    # Counter for each KW
    UTILS_Count_CTR $Parallel_LOG

    # Some small log for debugging reasons...
    echo """
    ===== log =====
    ---> $CTR_TOTAL packages considered
    ---> $CTR_DOWNL failures while downloading
    ---> $CTR_UNTAR failures while decompressing
    ---> $CTR_BUILD failures while building
    ---> $CTR_CLEAN failures while cleaning
    ---> $CTR_QUERY failures while querying
    ---> $CTR_PRINT failures while fingerprinting
    ---> $CTR_TIMEOUT time-outs
    ---> $CTR_OMITTED omissions
    ---> $CTR_SUCCESS successes
    """
}

# ---------- #


while getopts 'dbcq:hl:' OPERATION; do
    case $OPERATION in
        d)
            echo "Downloading!"
            download_NPM;;
        b)
            echo "Building!"
            build_NPM;;
        c)
            echo "Cleaning!"
            clean_NPM;;
        q)
            echo "Querying!"
            query_NPM $OPTARG;;
        h)
            echo "Hashing!"
            hash_NPM;;
        l)
            echo "Logging!"
            log_NPM $OPTARG;;
    esac
done

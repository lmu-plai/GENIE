
<<doc
When a package does not contain a single non-empty '*.js' or '*.ts' file,
create a dummy file. CodeQL can't generate a DB when there are no JavaScript or
TypeScript files to analyze.
doc
UTILS_Dummy_JS()
{
    CB_Path=$1

    # Check if there is some '*.js' or '*.ts' file in the package
    script_FILES=$(find $CB_Path \( -name *.js -o -name *.ts \) -type f -not -empty -print -quit 2> /dev/null);
    if [ ! -z "$script_FILES" ]; then return; fi

    # If there are no '*.js' or '*.ts' files, create a dummy file
    DUMMY_NAME='dummy.js'
    DUMMY_CODE='function dummyCode() { return; }'
    echo $DUMMY_CODE > $CB_Path/$DUMMY_NAME
}


<<doc
Given a compressed @NPM_Package, decompress and store its contents in @CB_Path.
doc
UTILS_Create_CB()
{
    NPM_Package=$1
    CB_Path=$2
    LOG_Path=$3

    mkdir $CB_Path
    # Do not attempt to preserve the owner specified in the compressed archive
    tar -xf "$NPM_Package" -C $CB_Path --no-same-owner --no-same-permissions &>> $LOG_Path
}


<<doc
Count the return codes, @Return_CODE, on the parallel log-file, @Parallel_LOG.
doc
HELPER_Count_CTR()
{
    Parallel_LOG=$1
    Return_CODE=$2

    # The EXIT-VALUE is located on the 7th column.
    EXIT_VAL=7

    awk "{print \$$EXIT_VAL}" $Parallel_LOG | grep -xc "$Return_CODE"
}


<<doc
Count the number of occurrences of all return codes, on the parallel log-file, @Parallel_LOG.
doc
UTILS_Count_CTR()
{
    Parallel_LOG=$@

    CTR_TOTAL=$(wc -l < $Parallel_LOG);
    # Don't count the LOG header
    CTR_TOTAL=$((CTR_TOTAL - 1));
    # Special codes
    CTR_TIMEOUT=$(HELPER_Count_CTR $Parallel_LOG \\$TIMEOUT_CODE);
    CTR_SUCCESS=$(HELPER_Count_CTR $Parallel_LOG $SUCCESS_CODE);
    CTR_OMITTED=$(HELPER_Count_CTR $Parallel_LOG $OMITTED_CODE);
    # Failure codes
    CTR_DOWNL=$(HELPER_Count_CTR $Parallel_LOG $FAILURE_CODE_DOWNL);
    CTR_UNTAR=$(HELPER_Count_CTR $Parallel_LOG $FAILURE_CODE_UNTAR);
    CTR_BUILD=$(HELPER_Count_CTR $Parallel_LOG $FAILURE_CODE_BUILD);
    CTR_CLEAN=$(HELPER_Count_CTR $Parallel_LOG $FAILURE_CODE_CLEAN);
    CTR_QUERY=$(HELPER_Count_CTR $Parallel_LOG $FAILURE_CODE_QUERY);
    CTR_PRINT=$(HELPER_Count_CTR $Parallel_LOG $FAILURE_CODE_PRINT);
}


<<doc
Generate SHA1 fingerprint for a given package for storing.
doc
UTILS_Generate_SHA()
{
    CB_Path=$1
    SHA_Path=$2
    LOG_Path=$3

    # Description:
    # - find    ---> Search for all .js and .ts files       (-print0 for null character ending)
    # - sort    ---> Sorting of file names                  (-z      for null character ending)
    # - xargs   ---> Compute SHA1 for every file with xargs (-0      for null character ending)
    # - awk     ---> Ignore file names in output with AWK
    # - sha1sum ---> Compute SHA1 for entire output
    # - awk     ---> Ignore file name in output with AWK
    find $CB_Path \( -name *.js -o -name *.ts \) -type f -print0 2> /dev/null | sort -z | xargs -0 sha1sum 2> /dev/null | awk '{ print $1 }' | sha1sum | awk '{ print $1 }' 2> $LOG_Path 1> $SHA_Path
}


<<doc
Compare SHA1 fingerprint of a given package against dataset.
doc
UTILS_Compare_SHA()
{
    SHA_1_Path=$1
    SHA_2_Path=$2
    LOG_Path=$3

    cmp -s $SHA_1_Path $SHA_2_Path &>> $LOG_Path
}


export -f UTILS_Dummy_JS UTILS_Create_CB UTILS_Count_CTR UTILS_Generate_SHA UTILS_Compare_SHA

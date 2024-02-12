
<<doc
Download an NPM's package, named @NPM_Package, and store it in @DS_Path.
Use @LOG_Path for logging.
doc
UTILS_Download_PKG()
{
    NPM_Package=$1
    DS_Path=$2
    LOG_Path=$3

    mkdir $DS_Path
    npm pack "$NPM_Package" --pack-destination=$DS_Path &>> $LOG_Path
}


export -f UTILS_Download_PKG

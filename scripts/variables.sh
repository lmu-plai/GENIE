# Automatically export the following variables...
set -a

LOCATION_FS='/'
SNAPSHOT_FS=$LOCATION_FS'snapshot/'

# ---------- #

# List of all NPM packages' names
ALL_NPM_NAMES='NPM_package_names'

# ---------- #

# Storage: Snapshot of npm registry
DEMISEC_DS=$SNAPSHOT_FS'1_Registry/'
DEMISEC_DS_NPM=$DEMISEC_DS'NPM/'

# Storage: Source Code for each NPM's package
DEMISEC_CB=$SNAPSHOT_FS'2_CodeBase/'
DEMISEC_CB_NPM=$DEMISEC_CB'NPM/'

# Storage: CodeQL's generated DataBase
DEMISEC_DB=$SNAPSHOT_FS'3_DataBase/'
DEMISEC_DB_NPM=$DEMISEC_DB'NPM/'

# ---------- #

# Method: CodeQL's query results
DEMISEC_QUERY=$SNAPSHOT_FS'4_query/'
DEMISEC_QUERY_Output=$DEMISEC_QUERY'output/'

# Method: Applying matching via use of hash
DEMISEC_SHA=$SNAPSHOT_FS'5_hash/'
DEMISEC_SHA_Data=$DEMISEC_SHA'data/'
DEMISEC_SHA_Code=$DEMISEC_SHA'code/'
DEMISEC_SHA_Match=$DEMISEC_SHA'match/'

# ---------- #

# Log for future debugging
DEMISEC_LOG=$SNAPSHOT_FS'log/'
DEMISEC_LOG_Download=$DEMISEC_LOG'1_download/'
DEMISEC_LOG_Source=$DEMISEC_LOG'2_source/'
DEMISEC_LOG_Build=$DEMISEC_LOG'3_build/'
DEMISEC_LOG_Clean=$DEMISEC_LOG'4_clean/'
DEMISEC_LOG_Query=$DEMISEC_LOG'5_query/'
DEMISEC_LOG_Hash=$DEMISEC_LOG'6_hash/'
DEMISEC_LOG_Parallel=$DEMISEC_LOG'parallel/'

# ---------- #

# Possible return codes for future debugging
TIMEOUT_CODE=-1
SUCCESS_CODE=0
OMITTED_CODE=1
FAILURE_CODE_DOWNL=2
FAILURE_CODE_UNTAR=3
FAILURE_CODE_BUILD=4
FAILURE_CODE_CLEAN=5
FAILURE_CODE_QUERY=6
FAILURE_CODE_PRINT=7

# Extension of debug/temporary files
TGZ_EXTENSION='.tgz'
LOG_EXTENSION='.log'
OUT_EXTENSION='.csv'
TMP_EXTENSION='.tmp'
SHA_EXTENSION='.sha'
CMP_EXTENSION='.txt'
CQL_EXTENSION='.ql'

set +a

# Automatically export the following variables...
set -a

LOCATION_FS='/'
SNAPSHOT_FS=$LOCATION_FS'snapshot/'

# ---------- #

# List of all NPM packages' names
ALL_NPM_NAMES='NPM_package_names'

# ---------- #

# Storage: Snapshot of npm registry
GENIE_DS=$SNAPSHOT_FS'1_Registry/'
GENIE_DS_NPM=$GENIE_DS'NPM/'

# Storage: Source Code for each NPM's package
GENIE_CB=$SNAPSHOT_FS'2_CodeBase/'
GENIE_CB_NPM=$GENIE_CB'NPM/'

# Storage: CodeQL's generated DataBase
GENIE_DB=$SNAPSHOT_FS'3_DataBase/'
GENIE_DB_NPM=$GENIE_DB'NPM/'

# ---------- #

# Method: CodeQL's query results
GENIE_QUERY=$SNAPSHOT_FS'4_query/'
GENIE_QUERY_Output=$GENIE_QUERY'output/'

# Method: Applying matching via use of hash
GENIE_SHA=$SNAPSHOT_FS'5_hash/'
GENIE_SHA_Data=$GENIE_SHA'data/'
GENIE_SHA_Code=$GENIE_SHA'code/'
GENIE_SHA_Match=$GENIE_SHA'match/'

# ---------- #

# Log for future debugging
GENIE_LOG=$SNAPSHOT_FS'log/'
GENIE_LOG_Download=$GENIE_LOG'1_download/'
GENIE_LOG_Source=$GENIE_LOG'2_source/'
GENIE_LOG_Build=$GENIE_LOG'3_build/'
GENIE_LOG_Clean=$GENIE_LOG'4_clean/'
GENIE_LOG_Query=$GENIE_LOG'5_query/'
GENIE_LOG_Hash=$GENIE_LOG'6_hash/'
GENIE_LOG_Parallel=$GENIE_LOG'parallel/'

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

echo "Deleting content from project..."


<<doc
Delete content inside of @DeletePath.
doc
delete_Contents()
{
    DeletePath=$@

    echo "Trying to remove $DeletePath"
    rm -R $DeletePath
}

<<doc
Delete snapshot.
doc
delete_DS()
{
    delete_Contents $GENIE_DS_NPM
    delete_Contents $GENIE_DS
}

<<doc
Delete codebases.
doc
delete_CB()
{
    delete_Contents $GENIE_CB_NPM
    delete_Contents $GENIE_CB
}

<<doc
Delete databases.
doc
delete_DB()
{
    delete_Contents $GENIE_DB_NPM
    delete_Contents $GENIE_DB
}

<<doc
Delete query results.
doc
delete_CQL()
{
    delete_Contents $GENIE_QUERY_Output
    delete_Contents $GENIE_QUERY
}

<<doc
Delete hash results.
doc
delete_HASH()
{
    delete_Contents $GENIE_SHA_Data
    delete_Contents $GENIE_SHA_Code
    delete_Contents $GENIE_SHA_Match
    delete_Contents $GENIE_SHA
}

<<doc
Delete LOGs.
doc
delete_LOG()
{
    delete_Contents $GENIE_LOG_Download
    delete_Contents $GENIE_LOG_Source
    delete_Contents $GENIE_LOG_Build
    delete_Contents $GENIE_LOG_Clean
    delete_Contents $GENIE_LOG_Query
    delete_Contents $GENIE_LOG_Hash
    delete_Contents $GENIE_LOG_Parallel
    delete_Contents $GENIE_LOG
}


MODULE_NAME='Delete'
PS3="$PROGRAM_NAME | $MODULE_NAME > "

echo "Select what do you want to delete..."
select delete in 'Help' 'Done' 'DS' 'CB' 'DB' 'CQL' 'HASH' 'LOG'; do
    case $delete in
        Help ) REPLY='';;
        Done ) echo "Going back!"; break;;
        DS   ) delete_DS;;
        CB   ) delete_CB;;
        DB   ) delete_DB;;
        CQL  ) delete_CQL;;
        HASH ) delete_HASH;;
        LOG  ) delete_LOG;;
        *    ) echo "Unknown action > $REPLY";;
    esac
done

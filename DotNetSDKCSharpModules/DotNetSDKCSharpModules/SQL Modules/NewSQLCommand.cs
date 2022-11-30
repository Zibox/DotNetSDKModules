using System.Management.Automation;
using System.Data.SqlClient;
using System.Data.Common;
using System.Collections;

namespace DotNetSDKCSharpModules
{
    [Cmdlet(VerbsCommon.New, "SqlCommand")]
    [OutputType(typeof(Dictionary<string, object>))]
    public class NewSqlCommand : Cmdlet
    {
        [Parameter(Mandatory = true, 
            Position = 0, 
            ParameterSetName = "All",
            HelpMessage = "SqlConnection object from New-SQLConnection",
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            ValueFromRemainingArguments = true)]
        [Parameter(Mandatory = true, 
            Position = 0, 
            ParameterSetName = "Select",
            HelpMessage = "SqlConnection object from New-SQLConnection",
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            ValueFromRemainingArguments = true)]
        public SqlConnection SqlConnection { get; set; }

        [Parameter(Mandatory = true, 
            Position = 1,
            HelpMessage = "Used to specify the query. Use ; to merge multiple strings together as 1 query.",
            ParameterSetName = "All")]
        [Parameter(Mandatory = true,
            Position = 1,
            HelpMessage = "Used to specify the query. Use ; to merge multiple strings together as 1 query.",
            ParameterSetName = "Select")]
        public String Query { get; set; }

        [Parameter(Mandatory = false,
            Position = 2,
            HelpMessage = "Required when performing a select query",
            ParameterSetName = "All")]
        [Parameter(Mandatory = true,
            HelpMessage = "Required when performing a select query",
            Position = 2,
            ParameterSetName = "Select")]
        public SwitchParameter SelectQuery;

        [Parameter(Mandatory = false,
            Position = 3,
            HelpMessage = "Required when performing a select query, provide the columns of the database you are selecting",
            ParameterSetName = "All")]
        [Parameter(Mandatory = true, 
            Position = 3,
            HelpMessage = "Required when performing a select query, provide the columns of the database you are selecting",
            ParameterSetName = "Select")]
        public Array Columns { get; set; }
        protected override void BeginProcessing()
        {
            if (SqlConnection.State.ToString() == "Closed")
            {
                return;
            }
        }
        protected override void ProcessRecord()
        {
            SqlCommand sqlCommandObject = new(Query, SqlConnection);
            if (SelectQuery.IsPresent)
            {
                DbDataReader reader = sqlCommandObject.ExecuteReader();
                ArrayList returnObject = new ArrayList();
                while (reader.Read())
                {
                    IDictionary<string, object> tempObject =
                        new Dictionary<string, object>();
                    foreach (string column in Columns)
                    {
                        tempObject.Add(column, reader.GetValue(reader.GetOrdinal(column)));
                    }
                    returnObject.Add(tempObject);
                }
                reader.Close();
                sqlCommandObject.Dispose();
                WriteObject(returnObject);
                return;
            }
            else
            {
                sqlCommandObject.ExecuteNonQuery();
                sqlCommandObject.Dispose();
                return;
            }
        }
    }
}
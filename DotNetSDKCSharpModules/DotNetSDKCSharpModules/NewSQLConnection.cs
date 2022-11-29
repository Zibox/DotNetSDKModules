using System.Management.Automation;
using System.Data.SqlClient;

namespace DotNetSDKCSharpModules
{
    [Cmdlet(VerbsCommon.New, "SqlConnection")]
    [OutputType(typeof(SqlConnection))]
    public class NewSQLConnectionCmdlet: PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string ConnectionString { get; set; }
        [Parameter(Mandatory = false, Position = 1)]
        public SwitchParameter Connect;

        protected override void BeginProcessing()
        {
            SqlConnection connectionObject = new(ConnectionString);
            if (Connect.IsPresent) {
                connectionObject.Open();
            }
            WriteObject(connectionObject);
        }
    }
}
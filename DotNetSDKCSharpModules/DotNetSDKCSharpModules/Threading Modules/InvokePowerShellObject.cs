using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;

namespace DotNetSDKCSharpModules.Threading_Modules
{
    [Cmdlet(VerbsLifecycle.Invoke , "PowerShellObject")]
    [OutputType(typeof(Dictionary<string, object>))]
    public class InvokePowershellObject : PSCmdlet
    {
        [Parameter(Mandatory = true,
            Position = 0,
            ParameterSetName = "All",
            HelpMessage = "Can use New-PowerShellObject to create these more easily, contains your scriptblocks/params/etc",
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            ValueFromRemainingArguments = true)]
        public PowerShell PowerShellObject { get; set; }
        [Parameter(Mandatory = false, 
                Position = 1,
            HelpMessage = "Changes between Invoke and BeginInvoke methods")]
        public SwitchParameter ASynchronous;

        protected override void ProcessRecord()
        {
            if (ASynchronous.IsPresent)
            {
                IDictionary<string, object> tempObject =
                    new Dictionary<string, object>();
                tempObject.Add("Runspace", PowerShellObject.BeginInvoke());
                tempObject.Add("Powershell", PowerShellObject);
                WriteObject(tempObject);
                return;
            }
            else
            {
                IDictionary<string, object> tempObject =
                    new Dictionary<string, object>();
                tempObject.Add("Runspace", PowerShellObject.Invoke());
                tempObject.Add("Powershell", PowerShellObject);
                WriteObject(tempObject);
                return;
            }
        }

    }
}

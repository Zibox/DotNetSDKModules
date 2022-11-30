using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Provider;
using System.Management.Automation.Runspaces;
using System.Text;
using System.Threading.Tasks;

namespace DotNetSDKCSharpModules
{
    [Cmdlet(VerbsCommon.New, "InitialSessionStateObject")]
    [OutputType(typeof(InitialSessionState))]
    public class InitialSessionStateObject : PSCmdlet
    {
        [Parameter(Mandatory = false,
            Position = 0)]
        [ValidateSet("MTA", "STA")]
        public String ApartmentState { get; set; }

        [Parameter(Mandatory = false,
            Position = 1)]
        [ValidateSet("ReuseThread", "UseCurrentThread", "UseNewThread")]
        public String ThreadOptions { get; set; }

        [Parameter(Mandatory = false,
            Position = 2)]
        public Array Functions { get; set; }
        [Parameter(Mandatory = false,
            Position = 3)]
        public Array Variables { get; set; }
        protected override void ProcessRecord()
        {
            InitialSessionState initSessionState = InitialSessionState.CreateDefault();
            switch (ApartmentState.ToUpper())
            {
                case null:
                    break;
                case "MTA":
                    initSessionState.ApartmentState = System.Threading.ApartmentState.MTA;
                    break;
                case "STA":
                    initSessionState.ApartmentState = System.Threading.ApartmentState.STA;
                    break;
            }
            switch (ThreadOptions.ToUpper())
            {
                case null:
                    initSessionState.ThreadOptions = PSThreadOptions.Default;
                    break;
                case "REUSETHREAD":
                    initSessionState.ThreadOptions = PSThreadOptions.ReuseThread;
                    break;
                case "USECURRENTTHREAD":
                    initSessionState.ThreadOptions = PSThreadOptions.UseCurrentThread;
                    break;
                case "USENEWTHREAD":
                    initSessionState.ThreadOptions = PSThreadOptions.UseNewThread;
                    break;
            }
            if (Functions != null)
            {

                foreach (string function in Functions)
                {
                    // not 100% if this will work, might need to look at session state? Mount Function:\ PSDrive?
                    string functionPath = "Function:\\" + function;
                    string[] scriptBlock = File.ReadAllLines(functionPath);
                    SessionStateFunctionEntry temp = new SessionStateFunctionEntry(functionPath, string.Join(' ',scriptBlock));
                    initSessionState.Commands.Add(temp);
                }
            }
            if (Variables != null)
            {
                foreach (string variable in Variables)
                {
                    // also not 100% sure but believe this should read from current scope session state, pull value.
                    PSVariableIntrinsics pSVar = SessionState.PSVariable;
                    SessionStateVariableEntry tempVarEntry = new SessionStateVariableEntry(variable, pSVar.GetValue(variable), null);
                    initSessionState.Variables.Add(tempVarEntry);
                }
            }
            WriteObject(initSessionState);
        }
    }
}
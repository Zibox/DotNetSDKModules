using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace DotNetSDKCSharpModules
{
    [Cmdlet(VerbsCommon.Get, "IPRange")]
    [OutputType(typeof(Object[]))]
    public class GetIPRangeCmdlet : Cmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        [ValidatePattern(@"^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}\/([8-9]|[1-2]\d|3[1-3])$")]
        public string Subnet { get; set; }
        protected override void BeginProcessing()
        {
            string ip = (Subnet.Split('/'))[0];
            string cidrTemp = (Subnet.Split('/'))[1];
            int cidr = Convert.ToInt32(cidrTemp);
            string[] ipSplit = ip.Split('.');

            string[] ipBinary = ipSplit.ForEach<string>()


        }
        protected override void ProcessRecord()
        {
            

            WriteObject(ip)

    }
    }


}

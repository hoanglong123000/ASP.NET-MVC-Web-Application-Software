//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace DBServer.Entities
{
    using System;
    using System.Collections.Generic;
    
    public partial class AppSetting
    {
        public int Id { get; set; }
        public string Tab { get; set; }
        public string Section { get; set; }
        public string Value { get; set; }
        public System.Guid UpdatedBy { get; set; }
        public System.DateTime UpdatedDate { get; set; }
        public string Note { get; set; }
    }
}

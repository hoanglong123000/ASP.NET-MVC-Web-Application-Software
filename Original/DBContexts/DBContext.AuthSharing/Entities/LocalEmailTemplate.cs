//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace DBContext.AuthSharing.Entities
{
    using System;
    using System.Collections.Generic;
    
    public partial class LocalEmailTemplate
    {
        public int Id { get; set; }
        public string Code { get; set; }
        public string Keyword { get; set; }
        public string Name { get; set; }
        public string Detail { get; set; }
        public string Attributes { get; set; }
        public string Subject { get; set; }
        public int Status { get; set; } 
        public System.DateTime UpdatedDate { get; set; }
        public Nullable<System.Guid> UpdatedBy { get; set; }
    }
}


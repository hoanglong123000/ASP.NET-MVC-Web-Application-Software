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
    
    public partial class FeatureGroup
    {
        public int Id { get; set; }
        public int GroupId { get; set; }
        public int FeatureId { get; set; }
        public bool AllowView { get; set; }
        public bool AllowUpdate { get; set; }
        public bool AllowDelete { get; set; }
        public bool AllowCreate { get; set; }
    }
}

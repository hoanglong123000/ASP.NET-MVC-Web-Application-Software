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
    
    public partial class LocalFeature
    {
        public int Id { get; set; }
        public string Code { get; set; }
        public string Name { get; set; }
        public string SidebarName { get; set; }
        public string Icon { get; set; }
        public string ProcessCode { get; set; }
        public Nullable<int> ParentId { get; set; }
        public bool HasApproval { get; set; }
        public bool HasView { get; set; }
        public bool HasAdd { get; set; }
        public bool HasEdit { get; set; }
        public bool HasDelete { get; set; }
        public string ViewAction { get; set; }
        public string RelateActions { get; set; }
        public double Priority { get; set; }
        public bool Visible { get; set; }
        public bool Sidebar { get; set; }
        public int Type { get; set; }
    }
}

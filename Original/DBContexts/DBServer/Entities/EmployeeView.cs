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
    
    public partial class EmployeeView
    {
        public System.Guid Id { get; set; }
        public string StaffCode { get; set; }
        public string FullName { get; set; }
        public string EmailCongTy { get; set; }
        public Nullable<int> JobPositionId { get; set; }
        public Nullable<int> OrganizationId { get; set; }
        public string Organizations { get; set; }
        public Nullable<System.DateTime> NgayVaoCongTy { get; set; }
        public Nullable<int> JobTitleId { get; set; }
        public Nullable<int> Priority { get; set; }
        public Nullable<int> GroupTitle { get; set; }
        public string Keyword { get; set; }
    }
}

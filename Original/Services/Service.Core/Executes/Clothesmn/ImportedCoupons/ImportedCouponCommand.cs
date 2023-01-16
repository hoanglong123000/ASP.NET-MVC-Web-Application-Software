﻿using System;
using System.Collections.Generic; 
using System.Linq;
using System.Text; 
using Service.Utility.Components;
using Service.Utility.Variables;
using DBServer.Entities;
using System.Data.Entity.Validation;
using Service.Education.Executes.Clothesmn.Clothes;
using Service.Education.Executes.Clothesmn.ImportedCoupons;

namespace Service.Education.Executes.Base
{
    public partial class EducationService
    {
        public CommandResult<ImportedCoupon> CreateImportedCoupon(ImportedCouponEditModel model)
        {
            CheckDbConnect();
            try
            {
                var d = new ImportedCoupon
                {
                    Id = model.Id,
                    CreatedDate = DateTime.Now,
                    UpdatedDate = DateTime.Now,
                    UpdatedBy = model.UpdatedBy,
                    CreatedBy = model.UpdatedBy,
                    Keyword = model.Note,
                    ImportedDate = DateTime.Now,
                    ProviderId = model.ProviderId,
                    Note = model.Note,
                    TotalPrice  = model.TotalPrice
                };
               
                
                Context.ImportedCoupons.Add(d);
                Context.SaveChanges();
                //DeleteCaching 
                return new CommandResult<ImportedCoupon>(d);
            }
            catch (DbEntityValidationException e)
            {
                StringBuilder sb = new StringBuilder();
                foreach (var eve in e.EntityValidationErrors)
                {
                    foreach (var ve in eve.ValidationErrors)
                    {
                        sb.AppendLine(string.Format("- Property: \"{0}\", Error: \"{1}\"",
                            ve.PropertyName,
                            ve.ErrorMessage));
                    }
                }
                return new CommandResult<ImportedCoupon>(sb.ToString());
            }
        }
        public CommandResult<ImportedCoupon> EditImportedCoupon(ImportedCouponEditModel model)
        {
            CheckDbConnect();
            var d = Context.ImportedCoupons.FirstOrDefault(x => x.Id == model.Id);
            if (d == null)
                return new CommandResult<ImportedCoupon>("No result!");

            var notes = new List<string>()
            {

            };

            d.UpdatedDate = DateTime.Now;
            d.UpdatedBy = model.UpdatedBy;
            d.CreatedBy = model.UpdatedBy;
            d.Keyword = model.Note;
            d.ImportedDate = DateTime.Now;
            d.ProviderId = model.ProviderId;
            d.Note = model.Note;
            d.TotalPrice = model.TotalPrice;

            if (model.Status == 1)
            {
                for (int i = 0; i < model.detailImportedReceipts.Count; i++)
                {
                    var valueid = model.detailImportedReceipts[i].ClothesId;
                    CheckDbConnect();
                    var a = Context.Clothes.FirstOrDefault(x => x.Id == valueid);
                    if (a == null)
                        return new CommandResult<ImportedCoupon>("No result!");
                    a.Amount -= model.detailImportedReceipts[i].Amount;
                }
            }

            Context.SaveChanges();


            // Update Detail Receipt Rows.
            var detailreceiptlst = model.detailImportedReceipts.ToList();
            for (int i = 0; i < detailreceiptlst.Count; i++)
            {
                // Add new detail receipt row.
                if (detailreceiptlst[i].Id == 0)
                {
                    var detailReceipt = new DetailImportedReceipt
                    {
                        Id = detailreceiptlst[i].Id,
                        Status = detailreceiptlst[i].Status,
                        UnitMeasure = detailreceiptlst[i].UnitMeasure,
                        Amount = detailreceiptlst[i].Amount,
                        Price = detailreceiptlst[i].Price,
                        FinalPrice = detailreceiptlst[i].FinalPrice,
                        ClothesId = detailreceiptlst[i].ClothesId,
                        CouponId = d.Id
                    };
                    Context.DetailImportedReceipts.Add(detailReceipt);
                    Context.SaveChanges();
                }
                else
                {
                    // Update detail receipt row
                    var detailJson = model.detailImportedReceipts[i].Id;
                    var detail = Context.DetailReceipts.FirstOrDefault(x => x.Id == detailJson);
                    if (detail == null)
                        return new CommandResult<ImportedCoupon>("No result!");
                    detail.Status = detailreceiptlst[i].Status;
                    detail.UnitMeasure = detailreceiptlst[i].UnitMeasure;
                    detail.ClothesId = detailreceiptlst[i].ClothesId;

                    detail.CouponId = d.Id;
                    detail.Price = detailreceiptlst[i].Price;
                    detail.FinalPrice = detailreceiptlst[i].FinalPrice;


                }
            }
            Context.SaveChanges();

            return new CommandResult<ImportedCoupon>(d);
        }

        public void DeleteImportedCouponByIds(List<int> ids, Guid userId)
        {
            CheckDbConnect();
            var arr = ids.Select(x => "" + x + "").ToList();
            var idStr = string.Join(",", arr);
            Context.Database.ExecuteSqlCommand(
                "update ImportedCoupons set Status = -1, UpdatedBy = '" + userId + "', UpdatedDate = getdate() " +
                "where Id in ('" + idStr + "')");
            Context.Database.ExecuteSqlCommand(

                "UPDATE DetailImportedReceipts set Status = -1 WHERE CouponId in ('" + idStr + "')"

              );
        }
       /* public bool UpdateBrandStatus(int id, int status)
        {
            CheckDbConnect();
            var m = Context.Students.FirstOrDefault(x => x.Id == id);
            if (m == null)
                return false;

            m.Status = status;
            Context.SaveChanges();
             
            return true;
        }*/
         
    }
}
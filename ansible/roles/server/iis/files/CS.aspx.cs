using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

public partial class _Default : System.Web.UI.Page 
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        String path = Server.MapPath("~/uploads/");
        string[] validFileTypes={"config","aspx","gif","png","jpg","jpeg","doc","docx","xls","xlsx"};
        string ext = System.IO.Path.GetExtension(FileUpload1.PostedFile.FileName);   
        bool isValidFile = false;
        for (int i = 0; i < validFileTypes.Length; i++)
        {
            if (ext == "." + validFileTypes[i] )
            {
                isValidFile = true;
                break;
            }
        }
        if (!isValidFile)
        {
            Label1.ForeColor = System.Drawing.Color.Red;
            Label1.Text = "Invalid File. Please try again";
        }
        else
        {
            try
            {
                FileUpload1.PostedFile.SaveAs(path 
                    + FileUpload1.FileName);
                    Label1.ForeColor = System.Drawing.Color.Green;     
                    Label1.Text = "File uploaded successfully.";
            }
            catch (Exception ex)
            {
                Label1.Text = "File could not be uploaded.";
            }
            
        }
    }
}
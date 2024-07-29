using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SQLFilestream
{
    public partial class frmInsertData_ClasicModel : Form
    {
        public frmInsertData_ClasicModel()
        {
            InitializeComponent();
        }

        private void btnBrowse_Click(object sender, EventArgs e)
        {
            DialogResult resutl = openFileDialog1.ShowDialog();
            if (resutl == System.Windows.Forms.DialogResult.OK)
            {
                txtFileName.Text = openFileDialog1.FileName;
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnSaveData_Click(object sender, EventArgs e)
        {
            if (txtComments.Text.Trim() == "")
            {
                MessageBox.Show("Please Enter Comments", "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                txtComments.Focus();
                return;
            }

            if (txtFileName.Text.Trim() == "")
            {
                MessageBox.Show("Please Enter FilePath", "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                btnBrowse.Focus();
                return;
            }
            InsertFile(txtFileName.Text.Trim());
        }

        private void InsertFile(string filePath)
        {
            try
            {
                FileInfo fileInfo = new FileInfo(filePath);
                FileStream fileStream = new FileStream(fileInfo.FullName, FileMode.Open, FileAccess.Read);
                BinaryReader binaryReader = new BinaryReader(fileStream);
                byte[] fileData = binaryReader.ReadBytes((int)fileStream.Length);
                binaryReader.Close();
                fileStream.Close();
                string cs = @"Data Source=MEHDI\SQL2019;Initial Catalog=FileStreamTestDB;Integrated Security=TRUE";
                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();
                    string sql = "INSERT INTO BLOB_Table(Comments,FName,FileData) VALUES (@comments,@fName,@fileData)";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.Add("@fileData", SqlDbType.Binary, fileData.Length).Value = fileData;
                    cmd.Parameters.Add("@comments", SqlDbType.NVarChar).Value = txtComments.Text.Trim();
                    cmd.Parameters.Add("@fName", SqlDbType.NVarChar).Value = fileInfo.Name;
                    cmd.ExecuteNonQuery();
                    con.Close();
                }
                MessageBox.Show("Insert Succeed", "Succeed", MessageBoxButtons.OK, MessageBoxIcon.Information);
                txtComments.Clear();
                txtFileName.Clear();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }
        }
    }
}

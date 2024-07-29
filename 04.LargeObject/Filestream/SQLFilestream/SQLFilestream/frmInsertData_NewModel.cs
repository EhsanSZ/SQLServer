using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;
using System.Windows.Forms;

namespace SQLFilestream
{
    public partial class frmInsertData_NewModel : Form
    {
        public frmInsertData_NewModel()
        {
            InitializeComponent();
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

        private void btnBrowse_Click(object sender, EventArgs e)
        {
            DialogResult resutl = openFileDialog1.ShowDialog();
            if (resutl == System.Windows.Forms.DialogResult.OK)
            {
                txtFileName.Text = openFileDialog1.FileName;
            }
        }

        private void InsertFile(string filePath)
        {
            try
            {
                string cs = @"Data Source=MEHDI\SQL2019;Initial Catalog=FileStreamTestDB;Integrated Security=TRUE";

                const string InsertTSql = @"INSERT INTO BLOB_Table(Comments,FName,FileData) VALUES (@comments,@fName,CAST('' As VARBINARY(Max)));
                        	      SELECT FileData.PathName() AS ServerFilePath, GET_FILESTREAM_TRANSACTION_CONTEXT() AS ServerTxn
	                              FROM BLOB_Table
	                              WHERE PkId = SCOPE_IDENTITY();";
                string serverPath;
                byte[] serverTxn;
                FileInfo fileInfo = new FileInfo(filePath);

                using (TransactionScope ts = new TransactionScope())
                {
                    using (SqlConnection conn = new SqlConnection(cs))
                    {
                        conn.Open();
                        using (SqlCommand cmd = new SqlCommand(InsertTSql, conn))
                        {
                            cmd.Parameters.Add("@comments", SqlDbType.NVarChar).Value = txtComments.Text.Trim();
                            cmd.Parameters.Add("@fName", SqlDbType.NVarChar).Value = fileInfo.Name;
                            using (SqlDataReader rdr = cmd.ExecuteReader())
                            {
                                rdr.Read();
                                serverPath = rdr["ServerFilePath"].ToString();
                                serverTxn = (byte[])rdr["ServerTxn"];
                                rdr.Close();
                            }
                        }
                        SavePhotoFile(filePath, serverPath, serverTxn);
                    }
                    ts.Complete();
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

        private void SavePhotoFile(string clientPath, string serverPath, byte[] serverTxn)
        {
            const int BlockSize = 1024 * 512;

            using (FileStream source =
              new FileStream(clientPath, FileMode.Open, FileAccess.Read))
            {
                using (SqlFileStream dest = new SqlFileStream(serverPath, serverTxn, FileAccess.Write))
                {
                    byte[] buffer = new byte[BlockSize];
                    int bytesRead;
                    while ((bytesRead = source.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        dest.Write(buffer, 0, bytesRead);
                        dest.Flush();
                    }
                    dest.Close();
                }
                source.Close();
            }
        }

    }
}

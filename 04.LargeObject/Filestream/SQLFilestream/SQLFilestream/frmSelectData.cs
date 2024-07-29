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
    public partial class frmSelectData : Form
    {
        public frmSelectData()
        {
            InitializeComponent();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnBrowse_Click(object sender, EventArgs e)
        {
            var result = folderBrowserDialog1.ShowDialog();
            if (result == System.Windows.Forms.DialogResult.OK)
            {
                txtFilePath.Text = folderBrowserDialog1.SelectedPath;
            }
        }

        private void btnLoadData_Click(object sender, EventArgs e)
        {
            if (txtPKID.Text.Trim() == "")
            {
                MessageBox.Show("Please Enter PKID", "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                txtPKID.Focus();
                return;
            }

            Int32 resultPKID = 0;
            Int32.TryParse(txtPKID.Text.Trim(), out resultPKID);
            if (resultPKID == 0)
            {
                MessageBox.Show("PKID Is Invalid", "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                txtPKID.Focus();
                return;
            }

            if (txtFilePath.Text.Trim() == "")
            {
                MessageBox.Show("Please Enter File Path", "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                txtFilePath.Focus();
                return;

            }
            LoadData(resultPKID, txtFilePath.Text.Trim());
        }

        private void LoadData(int pkID, string filePath)
        {
            try
            {
                byte[] serverTxn = null;
                string serverFilePath="";
                string cs = @"Data Source=MEHDI\SQL2019;Initial Catalog=FileStreamTestDB;Integrated Security=TRUE";
                string sqlCmd = @"
                        SELECT 
                            Comments,
                            FName,
                            FileData.PathName() AS ServerFilePath,
                            GET_FILESTREAM_TRANSACTION_CONTEXT() AS ServerTxn  
                        FROM BLOB_Table 
                        WHERE PKID=@PKID";
                using (TransactionScope ts = new TransactionScope())
                {
                    using (SqlConnection con = new SqlConnection(cs))
                    {
                        con.Open();
                        using (SqlCommand cmd = new SqlCommand(sqlCmd, con))
                        {
                            cmd.Parameters.Add("@PKID", SqlDbType.Int).Value = pkID;
                            using (SqlDataReader rdr = cmd.ExecuteReader())
                            {
                                rdr.Read();
                                if (rdr.HasRows)
                                {
                                    txtFileName.Text = filePath + @"\" + rdr["FName"].ToString();
                                    txtComments.Text = rdr["Comments"].ToString();
                                    serverFilePath = rdr["ServerFilePath"].ToString();
                                    serverTxn = (byte[])rdr["ServerTxn"];
                                }
                                else
                                {
                                    txtFileName.Clear();
                                    txtComments.Clear();
                                    MessageBox.Show("Record Not Found!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                                }
                                rdr.Close();
                            }
                        }
                        LoadFile(serverFilePath, txtFileName.Text, serverTxn);
                        ts.Complete();
                        MessageBox.Show("File Loaded", "Operation Complete", MessageBoxButtons.OK, MessageBoxIcon.Information);

                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }
        }

        private void LoadFile(string serverPath,string clientFileName, byte[] txnToken)
        {
            using (SqlFileStream sfs = new SqlFileStream(serverPath, txnToken, FileAccess.Read))
            {
                byte[] buffer = new byte[(int)sfs.Length];
                sfs.Read(buffer, 0, buffer.Length);
                using (var fs = new System.IO.FileStream(clientFileName, FileMode.Create, FileAccess.Write, FileShare.Write))
                {
                    fs.Write(buffer, 0, buffer.Length);
                    fs.Flush();
                }
            }
        }

    }
}

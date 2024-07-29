using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SQLFilestream
{
    public partial class frmMain : Form
    {
        public frmMain()
        {
            InitializeComponent();
        }

        private void btnInsertData_ClasicModel_Click(object sender, EventArgs e)
        {
            var frm = new frmInsertData_ClasicModel();
            frm.ShowDialog();
        }

        private void btnInsertData_NewModel_Click(object sender, EventArgs e)
        {
            var frm = new frmInsertData_NewModel();
            frm.ShowDialog();
        }

        private void btn_LoadData_Click(object sender, EventArgs e)
        {
            var frm = new frmSelectData();
            frm.ShowDialog();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}

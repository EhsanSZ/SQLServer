namespace SQLFilestream
{
    partial class frmMain
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.btnExit = new System.Windows.Forms.Button();
            this.btnInsertData_ClasicModel = new System.Windows.Forms.Button();
            this.btnInsertData_NewModel = new System.Windows.Forms.Button();
            this.btn_LoadData = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // btnExit
            // 
            this.btnExit.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnExit.Location = new System.Drawing.Point(38, 119);
            this.btnExit.Name = "btnExit";
            this.btnExit.Size = new System.Drawing.Size(189, 23);
            this.btnExit.TabIndex = 10;
            this.btnExit.Text = "خروج";
            this.btnExit.UseVisualStyleBackColor = true;
            this.btnExit.Click += new System.EventHandler(this.btnExit_Click);
            // 
            // btnInsertData_ClasicModel
            // 
            this.btnInsertData_ClasicModel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnInsertData_ClasicModel.Location = new System.Drawing.Point(38, 32);
            this.btnInsertData_ClasicModel.Name = "btnInsertData_ClasicModel";
            this.btnInsertData_ClasicModel.Size = new System.Drawing.Size(189, 23);
            this.btnInsertData_ClasicModel.TabIndex = 11;
            this.btnInsertData_ClasicModel.Text = "درج دیتا با روش کلاسیک";
            this.btnInsertData_ClasicModel.UseVisualStyleBackColor = true;
            this.btnInsertData_ClasicModel.Click += new System.EventHandler(this.btnInsertData_ClasicModel_Click);
            // 
            // btnInsertData_NewModel
            // 
            this.btnInsertData_NewModel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnInsertData_NewModel.Location = new System.Drawing.Point(38, 61);
            this.btnInsertData_NewModel.Name = "btnInsertData_NewModel";
            this.btnInsertData_NewModel.Size = new System.Drawing.Size(189, 23);
            this.btnInsertData_NewModel.TabIndex = 12;
            this.btnInsertData_NewModel.Text = "درج دیتا با روش جدید";
            this.btnInsertData_NewModel.UseVisualStyleBackColor = true;
            this.btnInsertData_NewModel.Click += new System.EventHandler(this.btnInsertData_NewModel_Click);
            // 
            // btn_LoadData
            // 
            this.btn_LoadData.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btn_LoadData.Location = new System.Drawing.Point(38, 90);
            this.btn_LoadData.Name = "btn_LoadData";
            this.btn_LoadData.Size = new System.Drawing.Size(189, 23);
            this.btn_LoadData.TabIndex = 13;
            this.btn_LoadData.Text = "لود دیتا";
            this.btn_LoadData.UseVisualStyleBackColor = true;
            this.btn_LoadData.Click += new System.EventHandler(this.btn_LoadData_Click);
            // 
            // frmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnExit;
            this.ClientSize = new System.Drawing.Size(308, 191);
            this.Controls.Add(this.btn_LoadData);
            this.Controls.Add(this.btnInsertData_NewModel);
            this.Controls.Add(this.btnInsertData_ClasicModel);
            this.Controls.Add(this.btnExit);
            this.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(178)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmMain";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Please Select ...";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnExit;
        private System.Windows.Forms.Button btnInsertData_ClasicModel;
        private System.Windows.Forms.Button btnInsertData_NewModel;
        private System.Windows.Forms.Button btn_LoadData;
    }
}
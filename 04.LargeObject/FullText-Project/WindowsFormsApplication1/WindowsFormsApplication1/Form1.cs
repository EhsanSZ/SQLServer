using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WindowsFormsApplication1
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }


        private void button1_Click(object sender, EventArgs e)
        {
            listBox1.Items.Clear();
            var source = textBox1.Text.Trim();

            var strArray = source.Split(' ');
            foreach (var str in strArray)
            {
                var items = Enumerable
                    .Range(0, str.Length)
                    .SelectMany(i => Enumerable.Range(2, str.Length - i - 1).Select(j => str.Substring(i, j)))
                    .Distinct()
                    .OrderBy(s => s.Length);
                foreach (var item in items)
                {
                    listBox1.Items.Add(item);
                }
            }
        }
    }
}

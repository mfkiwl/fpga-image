using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Emgu.CV;
using Emgu.CV.CvEnum;
using Emgu.CV.Structure;
using Emgu.Util;
using System.IO;
using AForge;
using AForge.Imaging;
using AForge.Imaging.Filters;
using AForge.Imaging.Textures;
using System.IO.Ports;


namespace cameracap
{

    public partial class Form1 : Form
    {

        SerialPort ComPort = new SerialPort();

        internal delegate void SerialDataReceivedEventHandlerDelegate(object sender, SerialDataReceivedEventArgs e);
        internal delegate void SerialPinChangedEventHandlerDelegate(object sender, SerialPinChangedEventArgs e);
        private SerialPinChangedEventHandler SerialPinChangedEventHandler1;
        //delegate void SetTextCallback(string text);
        delegate void SetTextCallback(int buffer_int);

        //string InputData = String.Empty;
        int stt_rs232 = 0;
        int[] bytes_rs232 = new int[9];

        int remmember_1 = 0;
        int remmember_2 = 0;
        bool enable_uart_re = false;

        //Mat frame = new Mat();
        //Mat grayFrame = new Mat();
        int statusImg = 0;
        Bitmap imgtosenduart;
        Bitmap imgtesttosenduart;

        private Capture _capture = null;
        private bool _captureInProgress;
        System.Drawing.Image imagetest;
        System.Drawing.Image image1;
        System.Drawing.Image image2;
        private static Bitmap img_send;
        private static List<string> data_total = new List<string>();
        //Image image3;
        public static List<string> Data_total
        {
            get
            {
                return data_total;
            }
            set
            {
                data_total = value;
            }
        }
        public static Bitmap Img_send   
        {
            get
            {
                return img_send;
            }
            set
            {
                img_send = value;
            }
        }
        public Form1()
        {
            InitializeComponent();
            SerialPinChangedEventHandler1 = new SerialPinChangedEventHandler(PinChanged);
            ComPort.DataReceived += new System.IO.Ports.SerialDataReceivedEventHandler(port_DataReceived_1);

            //InitializeComponent();
            //CvInvoke.UseOpenCL = false;
            //try
            //{
            //    _capture = new Capture();
            //    _capture.ImageGrabbed += ProcessFrame;
            //}
            //catch (NullReferenceException excpt)
            //{
            //    MessageBox.Show(excpt.Message);
            //}

        }

        private void ProcessFrame(object sender, EventArgs arg)
        {
        }

        private void flipHorizontalButton_Click(object sender, EventArgs e)
        {
            if (_capture != null) _capture.FlipHorizontal = !_capture.FlipHorizontal;
        }

        private void flipVerticalButton_Click(object sender, EventArgs e)
        {
            if (_capture != null) _capture.FlipVertical = !_capture.FlipVertical;
        }

        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
        }


        private void imToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Stream myStream = null;
            OpenFileDialog openFileDialog1 = new OpenFileDialog();

            openFileDialog1.InitialDirectory = @"D:\!desktop\luan_van\111coding\software\_smt_control_1\test file";
            openFileDialog1.Filter = "bmp files (*.bmp)|*.bmp|All files (*.*)|*.*";
            openFileDialog1.FilterIndex = 2;
            openFileDialog1.RestoreDirectory = true;

            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    if ((myStream = openFileDialog1.OpenFile()) != null)
                    {
                        using (myStream)
                        {


                            // Insert code to read the stream here.
                            
                            using (Form form_image1 = new Form())
                            {
                                image1 = System.Drawing.Image.FromStream(myStream);

                                form_image1.StartPosition = FormStartPosition.CenterScreen;
                                form_image1.Size = image1.Size;

                                PictureBox pb = new PictureBox();
                                pb.Dock = DockStyle.Fill;
                                pb.Image = image1;

                                form_image1.Controls.Add(pb);


                                form_image1.ShowDialog();
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: Could not read file from disk. Original error: " + ex.Message);
                }
            }
        }

        private void image2ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Stream myStream = null;
            OpenFileDialog openFileDialog1 = new OpenFileDialog();

            openFileDialog1.InitialDirectory = @"D:\!desktop\luan_van\111coding\software\_smt_control_1\test file";
            openFileDialog1.Filter = "bmp files (*.bmp)|*.bmp|All files (*.*)|*.*";
            openFileDialog1.FilterIndex = 2;
            openFileDialog1.RestoreDirectory = true;

            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    if ((myStream = openFileDialog1.OpenFile()) != null)
                    {
                        using (myStream)
                        {
                            // Insert code to read the stream here.

                            using (Form form_image2 = new Form())
                            {
                                image2 = System.Drawing.Image.FromStream(myStream);

                                form_image2.StartPosition = FormStartPosition.CenterScreen;
                                form_image2.Size = image2.Size;

                                PictureBox pb = new PictureBox();
                                pb.Dock = DockStyle.Fill;
                                pb.Image = image2;

                                form_image2.Controls.Add(pb);
                                form_image2.ShowDialog();
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error: Could not read file from disk. Original error: " + ex.Message);
                }
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (image1 != null && image2 != null)
            {
                if (image1.Width == image2.Width)
                {
                    if (image1.Height == image2.Height)
                    {
                        int x1 = image1.Width;
                        int y1 = image1.Height;
                        Bitmap image1_b = new Bitmap(image1);
                        Bitmap image2_b = new Bitmap(image2);
                        Bitmap image3_b = new Bitmap(x1,y1);
                        Bitmap image4_b = new Bitmap(x1, y1);
                        for (int i1=0; i1 < x1;i1++)
                        {
                            for (int j1 = 0; j1 < y1; j1++)
                            {
                                Color pixelColor1 = image1_b.GetPixel(i1, j1);
                                Color pixelColor2 = image2_b.GetPixel(i1, j1);
                                int diff_R = pixelColor1.R - pixelColor2.R;
                                int diff_B = pixelColor1.B - pixelColor2.B;
                                int diff_G = pixelColor1.G - pixelColor2.G;
                                diff_R = Math.Abs(diff_R);
                                diff_B = Math.Abs(diff_B);
                                diff_G = Math.Abs(diff_G);
                                diff_B = (diff_R + diff_B + diff_G) / 3;

                                Color newColor = Color.FromArgb(diff_B, diff_B, diff_B);
                                image3_b.SetPixel(i1, j1, newColor);
                            }
                        }
                        using (Form form_image3 = new Form())
                        {

                            form_image3.StartPosition = FormStartPosition.CenterScreen;
                            form_image3.Size = image3_b.Size;

                            PictureBox pb = new PictureBox();
                            pb.Dock = DockStyle.Fill;
                            pb.Image = image3_b;

                            form_image3.Controls.Add(pb);
                            form_image3.ShowDialog(); 
                        }
                        ////////anh nhi phan/////////////////////////
                        for (int i1 = 0; i1 < x1; i1++)
                        {
                            for (int j1 = 0; j1 < y1; j1++)
                            {
                                Color pixelColor1 = image3_b.GetPixel(i1, j1);
                                int diff_R = pixelColor1.R;
                                byte difer = (byte)diff_R;
                                if (difer < 27)
                                {
                                    diff_R = 0;
                                    //string stringtosend = diff_R.ToString();
                                    //textBox1.AppendText(stringtosend);
                                    //textBox1.AppendText("/n");
                                }
                                else
                                {
                                    diff_R = 255;
                                }
                                Color newColor = Color.FromArgb(diff_R, diff_R, diff_R);
                                image4_b.SetPixel(i1, j1, newColor);
                            }
                        }
                        using (Form form_image3 = new Form())
                        {

                            form_image3.StartPosition = FormStartPosition.CenterScreen;
                            form_image3.Size = image4_b.Size;

                            PictureBox pb = new PictureBox();
                            pb.Dock = DockStyle.Fill;
                            pb.Image = image4_b;

                            form_image3.Controls.Add(pb);
                            form_image3.ShowDialog();
                        }
                        ////////median///////////////////////////////////////
                        //// create filter
                        //Median filter = new Median();
                        //// apply the filter
                        //filter.ApplyInPlace(image4_b);
                        //using (Form form_image3 = new Form())
                        //{

                        //    form_image3.StartPosition = FormStartPosition.CenterScreen;
                        //    form_image3.Size = image4_b.Size;

                        //    PictureBox pb = new PictureBox();
                        //    pb.Dock = DockStyle.Fill;
                        //    pb.Image = image4_b;

                        //    form_image3.Controls.Add(pb);
                        //    form_image3.ShowDialog();
                        //}
                        ////////median/////////////////////////
                        Image<Rgb, byte> image5_b = new Image<Rgb, byte>(image4_b);
                        Image<Rgb, byte> mediansmooth = image5_b.SmoothMedian(9);
                        img_send = mediansmooth.ToBitmap();

                        using (Form form_image3 = new Form())
                        {

                            form_image3.StartPosition = FormStartPosition.CenterScreen;
                            form_image3.Size = mediansmooth.Size;

                            PictureBox pb = new PictureBox();
                            pb.Dock = DockStyle.Fill;
                            pb.Image = mediansmooth.ToBitmap();

                            form_image3.Controls.Add(pb);
                            form_image3.ShowDialog();
                        }
                        ////////Connected Component Labeling Algorithm/////////////////////////
                        Form frm_dis = new Form2();
                        frm_dis.ShowDialog();

                  


                    }
                }
            }

        }

        private void button2_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }


        private void port_DataReceived_1(object sender, SerialDataReceivedEventArgs e)
        {
            while (ComPort.BytesToRead > 0)
            {
                int bytes_rs = ComPort.ReadByte();
                this.BeginInvoke(new SetTextCallback(SetText), new object[] { bytes_rs });
            }

            //while (ComPort.BytesToRead > 0)
            //{

            //    bytes_rs[stt_rs232] = ComPort.ReadByte();
                
            //    stt_rs232++;
            //    if (stt_rs232 == 8)
            //    {
            //        this.BeginInvoke(new SetTextCallback(SetText), new object[] { bytes_rs });
            //        stt_rs232 = 0;
            //    }
            //}

            //if (stt_rs232 == 8)
            //{
            //    this.BeginInvoke(new SetTextCallback(SetText), new object[] { bytes_rs });
            //}
        }
        private void SetText(int buffer_int)
        {
            string s2 = buffer_int.ToString();
            //rtbIncoming.AppendText(s2);
            //rtbIncoming.AppendText("-");


            if ((remmember_1 == 255) && (remmember_2 == 255))
            {
                enable_uart_re = true;
                stt_rs232 = 0;
            }

            if (enable_uart_re == true)
            {
                if (stt_rs232 < 8)
                {
                    bytes_rs232[stt_rs232] = buffer_int;
                    stt_rs232++;
                }
                else
                {
                    bytes_rs232[stt_rs232] = buffer_int;
                    int toa_do_tam_x = bytes_rs232[0] + bytes_rs232[1] * 256;
                    int toa_do_tam_y = bytes_rs232[2] + bytes_rs232[3] * 256;

                    string s_toa_do_tam_x = toa_do_tam_x.ToString();
                    string s_toa_do_tam_y = toa_do_tam_y.ToString();

                    int canh_x = bytes_rs232[4] + bytes_rs232[5] * 256;
                    int canh_y = bytes_rs232[6] + bytes_rs232[7] * 256;

                    double radians = Math.Atan((double)canh_y / (double)canh_x);
                    double angle = radians * (180 / Math.PI);
                    angle = Math.Round(angle, 4);

                    string s_angle = angle.ToString();

                    string chieu_xoay_s;

                    //chieu_xoay_s = bytes_rs232[8].ToString();

                    if (bytes_rs232[8] == 1)
                    {
                        chieu_xoay_s = "LEFT";
                    }
                    else
                    {
                        chieu_xoay_s = "RIGHT";
                    }

                    label8.Text = s_toa_do_tam_x;
                    label9.Text = s_toa_do_tam_y;
                    label10.Text = s_angle;
                    label11.Text = chieu_xoay_s;

                    stt_rs232 = 0;
                    enable_uart_re = false;
                }
            }

            remmember_2 = remmember_1;
            remmember_1 = buffer_int;
        }
///////////////////////////////////////////////////////////////////////////////////////////////////////////
        //private void port_DataReceived_1(object sender, SerialDataReceivedEventArgs e)
        //{

        //    //if (!ComPort.IsOpen) return;
        //    // int bytes = ComPort.BytesToRead;
        //    int bytes_rs = ComPort.ReadByte();


        //    //InputData = ComPort.ReadExisting();
        //    //if (bytes_rs != null)
        //    //{
        //    this.BeginInvoke(new SetTextCallback(SetText), new object[] { bytes_rs });
        //    //}
        //}
        //private void SetText(int buffer)
        //{

        //    string s2 = buffer.ToString();


        //    //rtbIncoming.Clear();
        //    rtbIncoming.AppendText(s2);
        //    rtbIncoming.AppendText("-");

        //    //    //this.rtbIncoming.Text += text;
        //    //    byte[] uart_data_byte = Encoding.UTF8.GetBytes(text);
        //    //    BitArray b = new BitArray(uart_data_byte);


        //    //    var sb = new StringBuilder();

        //    //    for (int i = 0; i < b.Count; i++)
        //    //    {
        //    //        char c = b[i] ? '1' : '0';
        //    //        sb.Append(c);
        //    //    }

        //    //    string s2 = sb.ToString();

        //    //    rtbIncoming.Clear();
        //    //    rtbIncoming.AppendText(s2);
        //}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //private void port_DataReceived_1(object sender, SerialDataReceivedEventArgs e)
        //{
        //    InputData = ComPort.ReadExisting();
        //    if (InputData != String.Empty)
        //    {
        //        this.BeginInvoke(new SetTextCallback(SetText), new object[] { InputData });
        //    }
        //}
        //private void SetText(string text)
        //{
        //    byte[] uart_data_byte = Encoding.UTF8.GetBytes(text);

        //    BitArray b = new BitArray(uart_data_byte);


        //    var sb = new StringBuilder();

        //    for (int i = 0; i < b.Count; i++)
        //    {
        //        char c = b[i] ? '1' : '0';
        //        sb.Append(c);
        //    }

        //    string s2 = sb.ToString();

        //    rtbIncoming.Clear();
        //    rtbIncoming.AppendText(s2);
        //}

        internal void PinChanged(object sender, SerialPinChangedEventArgs e)
        {
            SerialPinChange SerialPinChange1 = 0;
            bool signalState = false;

            SerialPinChange1 = e.EventType;
            switch (SerialPinChange1)
            {
                case SerialPinChange.Break:
                    //MessageBox.Show("Break is Set");
                    break;
                case SerialPinChange.CDChanged:
                    signalState = ComPort.CtsHolding;
                    //  MessageBox.Show("CD = " + signalState.ToString());
                    break;
                case SerialPinChange.CtsChanged:
                    signalState = ComPort.CDHolding;
                    //MessageBox.Show("CTS = " + signalState.ToString());
                    break;
                case SerialPinChange.DsrChanged:
                    signalState = ComPort.DsrHolding;
                    // MessageBox.Show("DSR = " + signalState.ToString());
                    break;
                case SerialPinChange.Ring:
                    //MessageBox.Show("Ring Detected");
                    break;
            }
        }

        private void btnTest_Click(object sender, EventArgs e)
        {
            //SerialPinChangedEventHandler1 = new SerialPinChangedEventHandler(PinChanged);
            //ComPort.PinChanged += SerialPinChangedEventHandler1;
            //ComPort.Open();

            //ComPort.RtsEnable = true;
            //ComPort.DtrEnable = true;
            //btnTest.Enabled = false;

        }

        private void btnHello_Click(object sender, EventArgs e)
        {
            ComPort.Write("Hello World!");
        }



        private void button2_Click_1(object sender, EventArgs e)
        {
        }

        private void button3_Click(object sender, EventArgs e)
        {
            statusImg = 1;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            statusImg = 2;
        }

        private void button5_Click(object sender, EventArgs e)
        {
            statusImg = 0;
        }

        private void openToolStripMenuItem1_Click(object sender, EventArgs e)
        {
        }

        private void button6_Click(object sender, EventArgs e)
        {
        }

        private void splitContainer4_Panel2_Paint(object sender, PaintEventArgs e)
        {

        }

        private void btnGetSerialPorts_Click(object sender, EventArgs e)
        {
            string[] ArrayComPortsNames = null;
            int index = -1;
            string ComPortName = null;

            //Com Ports
            ArrayComPortsNames = SerialPort.GetPortNames();
            do
            {
                index += 1;
                cboPorts.Items.Add(ArrayComPortsNames[index]);


            } while (!((ArrayComPortsNames[index] == ComPortName) || (index == ArrayComPortsNames.GetUpperBound(0))));
            Array.Sort(ArrayComPortsNames);

            if (index == ArrayComPortsNames.GetUpperBound(0))
            {
                ComPortName = ArrayComPortsNames[0];
            }
            //get first item print in text
            cboPorts.Text = ArrayComPortsNames[0];
            //Baud Rate
            cboBaudRate.Items.Add(300);
            cboBaudRate.Items.Add(600);
            cboBaudRate.Items.Add(1200);
            cboBaudRate.Items.Add(2400);
            cboBaudRate.Items.Add(9600);
            cboBaudRate.Items.Add(14400);
            cboBaudRate.Items.Add(19200);
            cboBaudRate.Items.Add(38400);
            cboBaudRate.Items.Add(57600);
            cboBaudRate.Items.Add(115200);
            cboBaudRate.Items.ToString();
            //get first item print in text
            cboBaudRate.Text = cboBaudRate.Items[0].ToString();
            //Data Bits
            cboDataBits.Items.Add(7);
            cboDataBits.Items.Add(8);
            //get the first item print it in the text 
            cboDataBits.Text = cboDataBits.Items[0].ToString();

            //Stop Bits
            cboStopBits.Items.Add("One");
            cboStopBits.Items.Add("OnePointFive");
            cboStopBits.Items.Add("Two");
            //get the first item print in the text
            cboStopBits.Text = cboStopBits.Items[0].ToString();
            //Parity 
            cboParity.Items.Add("None");
            cboParity.Items.Add("Even");
            cboParity.Items.Add("Mark");
            cboParity.Items.Add("Odd");
            cboParity.Items.Add("Space");
            //get the first item print in the text
            cboParity.Text = cboParity.Items[0].ToString();
            //Handshake
            cboHandShaking.Items.Add("None");
            cboHandShaking.Items.Add("XOnXOff");
            cboHandShaking.Items.Add("RequestToSend");
            cboHandShaking.Items.Add("RequestToSendXOnXOff");
            //get the first item print it in the text 
            cboHandShaking.Text = cboHandShaking.Items[0].ToString();
        }

        private void btnPortState_Click(object sender, EventArgs e)
        {

            if (btnPortState.Text == "Connect")
            {
                btnPortState.Text = "Disconnect";
                ComPort.PortName = Convert.ToString(cboPorts.Text);
                ComPort.BaudRate = Convert.ToInt32(cboBaudRate.Text);
                ComPort.DataBits = Convert.ToInt16(cboDataBits.Text);
                ComPort.StopBits = (StopBits)Enum.Parse(typeof(StopBits), cboStopBits.Text);
                ComPort.Handshake = (Handshake)Enum.Parse(typeof(Handshake), cboHandShaking.Text);
                ComPort.Parity = (Parity)Enum.Parse(typeof(Parity), cboParity.Text);
                ComPort.Open();
            }
            else if (btnPortState.Text == "Disconnect")
            {
                btnPortState.Text = "Connect";
                ComPort.Close();

            }
        }

        private void button7_Click(object sender, EventArgs e)
        {
           
        }

        private void captureImageBox_Click(object sender, EventArgs e)
        {

        }

        private void button7_Click_1(object sender, EventArgs e)
        {
        }

        private void label10_Click(object sender, EventArgs e)
        {

        }

        private void label11_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void label8_Click(object sender, EventArgs e)
        {

        }

        private void splitContainer2_Panel2_Paint(object sender, PaintEventArgs e)
        {

        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }






    }
}

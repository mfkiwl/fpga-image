using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.Drawing.Imaging;
using System.Reflection;

using AForge;
using AForge.Imaging;
using AForge.Imaging.Filters;
using AForge.Math.Geometry;

namespace cameracap
{
    public partial class Form2 : Form
    {
        private Bitmap image = null;
        private int imageWidth, imageHeight;
        //private Control parent = null;

        private BlobCounter blobCounter = new BlobCounter();
        private Blob[] blobs;
        private int selectedBlobID;

        Dictionary<int, List<IntPoint>> leftEdges = new Dictionary<int, List<IntPoint>>();
        Dictionary<int, List<IntPoint>> rightEdges = new Dictionary<int, List<IntPoint>>();
        Dictionary<int, List<IntPoint>> topEdges = new Dictionary<int, List<IntPoint>>();
        Dictionary<int, List<IntPoint>> bottomEdges = new Dictionary<int, List<IntPoint>>();

        Dictionary<int, List<IntPoint>> hulls = new Dictionary<int, List<IntPoint>>();
        Dictionary<int, List<IntPoint>> quadrilaterals = new Dictionary<int, List<IntPoint>>();

        // Event to notify about selected blob
        //public event BlobSelectionHandler BlobSelected;

        // Blobs' highlight types enumeration
        public enum HightlightType
        {
            ConvexHull,
            LeftAndRightEdges,
            TopAndBottomEdges,
            Quadrilateral
        }

        private HightlightType highlighting = HightlightType.ConvexHull;
        private bool showRectangleAroundSelection = false;

        // Blobs' highlight type
        public HightlightType Highlighting
        {
            get { return highlighting; }
            set
            {
                highlighting = value;
                Invalidate();
            }
        }

        // Show rectangle around selection or not
        public bool ShowRectangleAroundSelection
        {
            get { return showRectangleAroundSelection; }
            set
            {
                showRectangleAroundSelection = value;
                Invalidate();
            }
        }
        public Form2()
        {
            InitializeComponent();
        }

        private void Form2_Load(object sender, EventArgs e)
        {
            Bitmap img_bitmap = Form1.Img_send;
            LoadDemo(img_bitmap);
        }
        private void LoadDemo(Bitmap embeddedFileName)
        {
            // load arrow bitmap
            Assembly assembly = this.GetType().Assembly;
            Bitmap image = embeddedFileName;
            ProcessImage(image);
        }

        // Process image
        private void ProcessImage(Bitmap bitmap)
        {
            leftEdges.Clear();
            rightEdges.Clear();
            topEdges.Clear();
            bottomEdges.Clear();
            hulls.Clear();
            quadrilaterals.Clear();

            selectedBlobID = 0;

            this.image = AForge.Imaging.Image.Clone(bitmap, PixelFormat.Format24bppRgb);
            imageWidth = this.image.Width;
            imageHeight = this.image.Height;

            blobCounter.ProcessImage(this.image);
            blobs = blobCounter.GetObjectsInformation();

            GrahamConvexHull grahamScan = new GrahamConvexHull();

            foreach (Blob blob in blobs)
            {
                List<IntPoint> leftEdge = new List<IntPoint>();
                List<IntPoint> rightEdge = new List<IntPoint>();
                List<IntPoint> topEdge = new List<IntPoint>();
                List<IntPoint> bottomEdge = new List<IntPoint>();

                // collect edge points
                blobCounter.GetBlobsLeftAndRightEdges(blob, out leftEdge, out rightEdge);
                blobCounter.GetBlobsTopAndBottomEdges(blob, out topEdge, out bottomEdge);

                leftEdges.Add(blob.ID, leftEdge);
                rightEdges.Add(blob.ID, rightEdge);
                topEdges.Add(blob.ID, topEdge);
                bottomEdges.Add(blob.ID, bottomEdge);

                // find convex hull
                List<IntPoint> edgePoints = new List<IntPoint>();
                edgePoints.AddRange(leftEdge);
                edgePoints.AddRange(rightEdge);

                List<IntPoint> hull = grahamScan.FindHull(edgePoints);
                hulls.Add(blob.ID, hull);

                List<IntPoint> quadrilateral = null;

                // find quadrilateral
                if (hull.Count < 4)
                {
                    quadrilateral = new List<IntPoint>(hull);
                }
                else
                {
                    quadrilateral = PointsCloud.FindQuadrilateralCorners(hull);
                }
                quadrilaterals.Add(blob.ID, quadrilateral);

                // shift all points for vizualization
                IntPoint shift = new IntPoint(1, 1);

                PointsCloud.Shift(leftEdge, shift);
                PointsCloud.Shift(rightEdge, shift);
                PointsCloud.Shift(topEdge, shift);
                PointsCloud.Shift(bottomEdge, shift);
                PointsCloud.Shift(hull, shift);
                PointsCloud.Shift(quadrilateral, shift);
            }


            UpdatePictureBoxPosition();
            Invalidate();

            //return blobs.Length;
        }


        // Size of main panel has changed
        private void splitContainer_Panel1_Resize(object sender, EventArgs e)
        {
            UpdatePictureBoxPosition();
        }

        // Update size and position of picture box control
        private void UpdatePictureBoxPosition()
        {
            int imageWidth=320;
            int imageHeight=240;

            if (image != null)
            {
                // get frame size
                imageWidth = image.Width;
                imageHeight = image.Height;
            }

            Rectangle rc = splitContainer.Panel1.ClientRectangle;

            pictureBox.SuspendLayout();
            pictureBox.Location = new System.Drawing.Point((rc.Width - imageWidth - 2) / 2, (rc.Height - imageHeight - 2) / 2);
            pictureBox.Size = new Size(imageWidth + 2, imageHeight + 2);
            pictureBox.ResumeLayout();
        }

        // Convert list of AForge.NET's IntPoint to array of .NET's Point
        private static System.Drawing.Point[] PointsListToArray( List<IntPoint> list )
        {
            System.Drawing.Point[] array = new System.Drawing.Point[list.Count];

            for ( int i = 0, n = list.Count; i < n; i++ )
            {
                array[i] = new System.Drawing.Point( list[i].X, list[i].Y );
            }

            return array;
        }
        // Draw object's edge
        private static void DrawEdge(Graphics g, Pen pen, List<IntPoint> edge)
        {
            System.Drawing.Point[] points = PointsListToArray(edge);

            if (points.Length > 1)
            {
                g.DrawLines(pen, points);
            }
            else
            {
                g.DrawLine(pen, points[0], points[0]);
            }
        }

        private void pictureBox_Paint(object sender, PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            Rectangle rect = this.pictureBox.ClientRectangle;

            //Pen borderPen = new Pen(Color.FromArgb(64, 64, 64), 1);
            Pen highlightPen = new Pen(Color.Red);
            Pen highlightPenBold = new Pen(Color.FromArgb(0, 255, 0), 3);
            Pen rectPen = new Pen(Color.Blue);

            // draw rectangle
            //g.DrawRectangle(borderPen, rect.X, rect.Y, rect.Width - 1, rect.Height - 1);

            if (image != null)
            {
                //g.DrawImage(image, rect.X + 1, rect.Y + 1, rect.Width - 2, rect.Height - 2);
                g.DrawImage(image, rect.X, rect.Y, image.Width, image.Height);

                foreach (Blob blob in blobs)
                {
                    Pen pen = (blob.ID == selectedBlobID) ? highlightPenBold : highlightPen;

                    if ((showRectangleAroundSelection) && (blob.ID == selectedBlobID))
                    {
                        g.DrawRectangle(rectPen, blob.Rectangle);
                    }

                    switch (highlighting)
                    {
                        case HightlightType.ConvexHull:
                            g.DrawPolygon(pen, PointsListToArray(hulls[blob.ID]));
                            break;
                        case HightlightType.LeftAndRightEdges:
                            DrawEdge(g, pen, leftEdges[blob.ID]);
                            DrawEdge(g, pen, rightEdges[blob.ID]);
                            break;
                        case HightlightType.TopAndBottomEdges:
                            DrawEdge(g, pen, topEdges[blob.ID]);
                            DrawEdge(g, pen, bottomEdges[blob.ID]);
                            break;
                        case HightlightType.Quadrilateral:
                            g.DrawPolygon(pen, PointsListToArray(quadrilaterals[blob.ID]));
                            break;
                    }
                }
            }
            else
            {
                g.FillRectangle(new SolidBrush(Color.FromArgb(128, 128, 128)),
                    rect.X + 1, rect.Y + 1, rect.Width - 2, rect.Height - 2);
            }
        }

        private void checkToolStripMenuItem_Click(object sender, EventArgs e)
        {
            /////////add up/////////////////////////////////////////////////
            string[] output_r = Form1.Data_total.ToArray();
            int output_r_len = output_r.Length / 7;
            string[] sting11 = new string[output_r_len];
            double[] x_pos1 = new double[output_r_len];
            double[] y_pos1 = new double[output_r_len];

            double[] x_pos2 = new double[blobs.Length];
            double[] y_pos2 = new double[blobs.Length];

            ///////////
            double[] x_pix2 = new double[blobs.Length];
            double[] y_pix2 = new double[blobs.Length];
            ////////////
            double[] pos2_t1 = new double[blobs.Length];
            double[] pos2_t2 = new double[blobs.Length];

            double[] distan = new double[blobs.Length];
            for (int ii = 0; ii < blobs.Length; ii++)
            {
                distan[ii] = 999999999;
            }

            for (int ii = 0; ii < blobs.Length; ii++)
            {
                x_pos2[ii] = blobs[ii].CenterOfGravity.X;
                y_pos2[ii] = blobs[ii].CenterOfGravity.Y;
                pos2_t1[ii] = blobs[ii].CenterOfGravity.X;
                pos2_t2[ii] = blobs[ii].CenterOfGravity.Y;

                x_pos2[ii] = (x_pos2[ii] - 93) * 13.9 / 1.4937;
                y_pos2[ii] = (y_pos2[ii] - 15) * 13.9 / 1.4937;
            }

            for (int ii_c = 0; ii_c < output_r_len; ii_c++)
            {
                x_pos1[ii_c] = Math.Abs(float.Parse(output_r[ii_c * 7 + 5]));
                y_pos1[ii_c] = Math.Abs(float.Parse(output_r[ii_c * 7 + 6]));
                sting11[ii_c] = output_r[ii_c * 7 + 0];
            }

            double[] x_pos22 = new double[blobs.Length];
            double[] y_pos22 = new double[blobs.Length];

            for (int ii_c = 0; ii_c < output_r_len; ii_c++ )
            {
                for (int jj_c = 0; jj_c < blobs.Length; jj_c++)
                {
                    double distan_x = x_pos1[ii_c] - x_pos2[jj_c];
                    double distan_y = y_pos1[ii_c] - y_pos2[jj_c];
                    double distanxy = Math.Sqrt(distan_x * distan_x + distan_y * distan_y);
                    if (distanxy < distan[ii_c])
                    {
                        distan[ii_c] = distanxy;
                        x_pos22[ii_c] = x_pos2[jj_c];
                        y_pos22[ii_c] = y_pos2[jj_c];
                        x_pix2[ii_c] = pos2_t1[jj_c];
                        y_pix2[ii_c] = pos2_t2[jj_c];
                    }
                }
            }

            dataGridView1.ColumnCount = 8;

            dataGridView1.Columns[0].Name = "Device";
            dataGridView1.Columns[1].Name = "X1";
            dataGridView1.Columns[2].Name = "Y1";
            dataGridView1.Columns[3].Name = "X2";
            dataGridView1.Columns[4].Name = "Y2";
            dataGridView1.Columns[5].Name = "PX2";
            dataGridView1.Columns[6].Name = "PY2";
            dataGridView1.Columns[7].Name = "Distance";

            int max_count = Math.Max(blobs.Length, output_r_len);
            for (int ii = 0; ii < max_count; ii++)
            {
                string[] row = new string[] { sting11[ii], x_pos1[ii].ToString(), y_pos1[ii].ToString(), x_pos22[ii].ToString(), y_pos22[ii].ToString(), x_pix2[ii].ToString(), y_pix2[ii].ToString(), distan[ii].ToString() };
                dataGridView1.Rows.Add(row);
            }
            /////////add down/////////////////////////////////////////////////

            ///////////add up/////////////////////////////////////////////////
            //string[] output_r = Form1.Data_total.ToArray();
            //int output_r_len = output_r.Length / 7;
            //string[] sting11 = new string[output_r_len];
            //double[] x_pos1 = new double[output_r_len];
            //double[] y_pos1 = new double[output_r_len];
            //double[] pos1_t1 = new double[output_r_len];
            //double[] pos1_t2 = new double[output_r_len];
            //double[] pos1_t3 = new double[output_r_len];

            //double[] x_pos2 = new double[blobs.Length];
            //double[] y_pos2 = new double[blobs.Length];
            /////////////
            //double[] x_pix2 = new double[blobs.Length];
            //double[] y_pix2 = new double[blobs.Length];
            //////////////
            //double[] pos2_t1 = new double[blobs.Length];
            //double[] pos2_t2 = new double[blobs.Length];
            //double[] pos2_t3 = new double[blobs.Length];
            //double[] pos2_t4 = new double[blobs.Length];

            //for (int ii = 0; ii < blobs.Length; ii++)
            //{
            //    /////////////
            //    x_pix2[ii] = blobs[ii].CenterOfGravity.X;
            //    y_pix2[ii] = blobs[ii].CenterOfGravity.Y;
            //    //////////
            //    x_pos2[ii] = blobs[ii].CenterOfGravity.X;
            //    y_pos2[ii] = blobs[ii].CenterOfGravity.Y;

            //    x_pos2[ii] = (x_pos2[ii] - 93) * 13.9 / 1.4937;
            //    y_pos2[ii] = (y_pos2[ii] - 15) * 13.9 / 1.4937;

            //    pos2_t1[ii] = x_pos2[ii] + (y_pos2[ii] - 1) * 5062;
            //    pos2_t2[ii] = x_pos2[ii] + (y_pos2[ii] - 1) * 5062;
            //    pos2_t3[ii] = x_pos2[ii] + (y_pos2[ii] - 1) * 5062;
            //    pos2_t4[ii] = x_pos2[ii] + (y_pos2[ii] - 1) * 5062;
            //}

            //int max_count = Math.Max(blobs.Length, output_r_len);

            //for (int ii_c = 0; ii_c < output_r_len; ii_c++)
            //{
            //    x_pos1[ii_c] = Math.Abs(float.Parse(output_r[ii_c * 7 + 5]));
            //    y_pos1[ii_c] = Math.Abs(float.Parse(output_r[ii_c * 7 + 6]));
            //    sting11[ii_c] = output_r[ii_c * 7 + 0];
            //    pos1_t1[ii_c] = x_pos1[ii_c] + (y_pos1[ii_c] - 1) * 5062;
            //    pos1_t2[ii_c] = x_pos1[ii_c] + (y_pos1[ii_c] - 1) * 5062;
            //    pos1_t3[ii_c] = x_pos1[ii_c] + (y_pos1[ii_c] - 1) * 5062;
            //}

            //Array.Sort(pos1_t1, x_pos1);
            //Array.Sort(pos1_t2, y_pos1);
            //Array.Sort(pos1_t3, sting11);
            //Array.Sort(pos2_t1, x_pos2);
            //Array.Sort(pos2_t2, y_pos2);
            ///////////////
            //Array.Sort(pos2_t3, x_pix2);
            //Array.Sort(pos2_t4, y_pix2);
            //////////////

            ////dataGridView1.ColumnCount = 6;
            //dataGridView1.ColumnCount = 8;

            //dataGridView1.Columns[0].Name = "Device";
            //dataGridView1.Columns[1].Name = "X1";
            //dataGridView1.Columns[2].Name = "Y1";
            //dataGridView1.Columns[3].Name = "X2";
            //dataGridView1.Columns[4].Name = "Y2";
            /////////////////
            //dataGridView1.Columns[5].Name = "PX2";
            //dataGridView1.Columns[6].Name = "PY2";
            //dataGridView1.Columns[7].Name = "Distance";
            //for (int ii = 0; ii < max_count; ii++)
            //{
            //    double distan_x = x_pos1[ii] - x_pos2[ii];
            //    double distan_y = y_pos1[ii] - y_pos2[ii];
            //    double distan = Math.Sqrt(distan_x * distan_x + distan_y * distan_y);
            //    string[] row = new string[] { sting11[ii], x_pos1[ii].ToString(), y_pos1[ii].ToString(), x_pos2[ii].ToString(), y_pos2[ii].ToString(), x_pix2[ii].ToString(), y_pix2[ii].ToString(), distan.ToString() };
            //    dataGridView1.Rows.Add(row);
            //}
            ///////////add down/////////////////////////////////////////////////
        }
    }

}

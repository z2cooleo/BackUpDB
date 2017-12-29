using System;
using System.Diagnostics;
using System.IO;
using System.Text;


namespace BackUpDB
{
    static class Work
    {
        private static int lineCount = 0;
        private static StringBuilder output = new StringBuilder();
        static public Boolean Backup(string pathToPgDump, string distPath, string userName, string password, string server, string database, string port, string format)
        {
            try
            {
                distPath = distPath + "\\" + DateTime.Now.Year + DateTime.Now.Month + DateTime.Now.Day + DateTime.Now.Hour + DateTime.Now.Minute + DateTime.Now.Second + ".dump";
                StreamWriter file = new StreamWriter(distPath);
                file.Close();
                Process process = new Process();
                process.StartInfo.FileName = pathToPgDump;
                process.StartInfo.RedirectStandardInput = false;
                process.StartInfo.RedirectStandardOutput = true;
                process.StartInfo.Arguments = string.Format(@"--dbname=postgres://{0}:{6}@{2}:{1}/{5} {3} --file={4} -v", userName, port, server, format, distPath, database, password);
                process.StartInfo.UseShellExecute = false;
                process.OutputDataReceived += new DataReceivedEventHandler((sender, e) =>
                {
                    // Prepend line numbers to each line of the output.
                    if (!String.IsNullOrEmpty(e.Data))
                    {
                        lineCount++;
                        output.Append("\n[" + lineCount + "]: " + e.Data);
                    }
                });
                process.Start();
                process.BeginOutputReadLine();
                process.WaitForExit();
                process.Close();
                return true;
            }
            catch (IOException ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
        }
    }
}

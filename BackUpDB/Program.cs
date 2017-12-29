using System;
using Newtonsoft.Json.Linq;
using System.IO;
using Newtonsoft.Json;
using System.Runtime.InteropServices;
using System.Collections.Generic;

namespace BackUpDB
{
    class Program
    {
        static void Main(string[] args)
        {
            Dictionary<string, string> settings = new Dictionary<string, string>();
            foreach (string i in args)
            {
                if (i.Contains("backUpCurrDB"))
                {
                    settings.Add("backUpCurrDB", "true");
                }
                else if (i.Contains("pathSettings"))
                {
                    var z = i.Split('=');
                    settings.Add("pathSettings", z[1]);
                }
                else if (i.Contains("backUpPrevDB"))
                {
                    settings.Add("backUpPrevDB", "true");
                }
            }
            if ((!settings.ContainsKey("backUpPrevDB") | !settings.ContainsKey("backUpCurrDB")) & !settings.ContainsKey("pathSettings"))
            {
                if (!settings.ContainsKey("pathSettings")) WriteToLog("Не указан файл настроек");
                if (!settings.ContainsKey("backUpPrevDB") & !settings.ContainsKey("backUpCurrDB")) WriteToLog("Не выбран режим работы");
                Environment.Exit(0);
            }
            else if(!File.Exists(settings["pathSettings"]))
            {
                WriteToLog("Резервное копирование не требуется или файла настроек не существует");
                Environment.Exit(0);
            }

            using (StreamReader file = File.OpenText(settings["pathSettings"]))
            {
                JsonTextReader reader = new JsonTextReader(file);
                JObject o2 = (JObject)JToken.ReadFrom(reader);
                String[] conVar = o2["prevDbConnString"].ToString().Split(' ');
                string conPort = conVar[0].Split('=')[1];
                string conHost = conVar[1].Split('=')[1];
                string conUser = conVar[2].Split('=')[1];
                string conPass = conVar[3].Split('=')[1];
                string conDb = conVar[4].Split('=')[1];
                String[] conCurrVar = o2["currDbConnString"].ToString().Split(' ');
                string conCurrPort = conCurrVar[0].Split('=')[1];
                string conCurrHost = conCurrVar[1].Split('=')[1];
                string conCurrUser = conCurrVar[2].Split('=')[1];
                string conCurrPass = conCurrVar[3].Split('=')[1];
                string conCurrDb = conCurrVar[4].Split('=')[1];
                string pg_dump = Environment.CurrentDirectory + @"\Dll\pg_dump.exe";
                String dbType = o2["prevDbType"].ToString();
                String dbCurrType = o2["currDbType"].ToString();
                String distPath = o2["whereLocateFolderBackUpDB"].ToString();
                String format = o2["PostgreCompress"].ToString();
                if (dbType == "pgsql")
                {
                    WriteToLog("Start BackUp");
                    Work.Backup(pg_dump, distPath, conUser, conPass, conHost, conDb, conPort, format);
                    WriteToLog("Finnish Backup");
                }
            }
            WriteToLog("Success!!!");
            try
            {
                if (settings.ContainsKey("backUpPrevDB"))
                {
                    File.Delete(settings["pathSettings"]);
                    WriteToLog("Config was deleted");
                }
            }
            catch (Exception ex)
            {
                WriteToLog(ex.ToString());
            }
            WriteToLog("\n\nPress \"Enter\" key to exit.");
       }
        static void WriteToLog(string z)
        {
            using (StreamWriter w = File.AppendText("BackUpDB.log"))
            {
                w.WriteLine(DateTime.Now +"  "+ z);
            }
        }
    }
}

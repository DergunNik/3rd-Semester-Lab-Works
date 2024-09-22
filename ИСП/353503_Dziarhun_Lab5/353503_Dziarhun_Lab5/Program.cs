using System.Xml.Linq;

namespace _353503_Dziarhun_Lab5;

using SerializerLib;
using Microsoft.Extensions.Configuration;
using _353505_Dziarhun_Lab5.Domain;

class Program
{
    static List<string> GetFileNames()
    {
        var conf = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("B:\\Projects_cs\\353503_Dziarhun_Lab5\\353503_Dziarhun_Lab5\\appsettings.json").Build();
        return new List<string>
        {
            conf.GetSection("AppSettings").GetSection("FileName1").Value,          
            conf.GetSection("AppSettings").GetSection("FileName2").Value,           
            conf.GetSection("AppSettings").GetSection("FileName3").Value          
        };
    }
    static void PrintProjectList(List<BuildingProject> pl)
    {
        Console.WriteLine("---------------------------------------------");
        foreach (var el in pl)
        {
            Console.WriteLine(el.Name + "; " + el.Budjet.ToString() + "; " + 
                              el.Foreman.Name + "; " + el.Foreman.Salary.ToString()); 
        }
        Console.WriteLine("---------------------------------------------");
    }

    static List<BuildingProject> GetBProjectsList()
    {
        return new List<BuildingProject>
        {
            new BuildingProject(123, "1", new Foreman("11", 12)),
            new BuildingProject(12300, "2", new Foreman("22", 12000)),
            new BuildingProject(999, "3", new Foreman("33", -12)),
            new BuildingProject(1, "4", new Foreman("44", -0)),
            new BuildingProject(-1356, "5", new Foreman("55", 1)),
            new BuildingProject(0, "6", new Foreman("66", 2))
        };
    }
    
    static void Main(string[] args)
    {
        var fileNames = GetFileNames();
        var col = GetBProjectsList();
        
        var serializer = new Serializer();
        serializer.SerializeByLINQ(col, fileNames[0]);
        serializer.SerializeXML(col, fileNames[1]);
        serializer.SerializeJSON(col, fileNames[2]);
        
        var fileCol = new List<List<BuildingProject>?>(3)
        {
            serializer.DeSerializeByLINQ(fileNames[0]) as List<BuildingProject>,
            serializer.DeSerializeXML(fileNames[1]) as List<BuildingProject>,
            serializer.DeSerializeJSON(fileNames[2]) as List<BuildingProject>
        };
        for (byte j = 0; j < fileCol.Count; ++j)
        {
            bool areEqual = true;
            PrintProjectList(fileCol[j]);
            for (byte i = 0; i < col.Count; ++i)
            {
                areEqual = areEqual && col[i].Equals(fileCol[j][i]);
            }
            Console.WriteLine($"fileCol[{j}] and col are" + 
                              (areEqual ? "" : "n't") +
                              " equal");
        }
    }
}
using System.Runtime.Serialization;
using System.Xml.Linq;
using System.Xml.Serialization;
using System.Text.Json;
using _353505_Dziarhun_Lab5.Domain;

namespace SerializerLib;

public class Serializer : ISerializer
{
    private void _deleteIfExists(string fileName)
    {
        if (File.Exists(fileName))
        {
            File.Delete(fileName);
        }
    }
    
    public IEnumerable<BuildingProject> DeSerializeByLINQ(string fileName)
    {
        var doc = XDocument.Load(fileName);
        var root = doc.Root;
        var projs = root.Elements("buildingProject").ToList();
        var buildingProjects = new List<BuildingProject>();
        foreach (var proj in projs)
        {
            var args = proj.Elements().ToList();
            buildingProjects.Add(new BuildingProject(
                int.Parse(args[0].Value),
                args[1].Value, 
                new Foreman(args[2].Element("name").Value, 
                    int.Parse(args[2].Element("salary").Value))));
        }

        return buildingProjects;
    }

    public IEnumerable<BuildingProject> DeSerializeXML(string fileName)
    {
        var serializer = new XmlSerializer(typeof(List<BuildingProject>));
        using var stream = File.OpenRead(fileName);
        return serializer.Deserialize(stream) as List<BuildingProject>;
    }

    public IEnumerable<BuildingProject> DeSerializeJSON(string fileName)
    {
        return JsonSerializer.Deserialize<List<BuildingProject>>(File.ReadAllText(fileName));
    }

    public void SerializeByLINQ(IEnumerable<BuildingProject> xxx, string fileName)
    {
        _deleteIfExists(fileName);

        var doc = new XDocument();
        var root = new XElement("BuildingProjects");
        foreach (var proj in xxx)
        {
            var foremanElem = new XElement("foreman",
                new XElement("name", proj.Foreman.Name),
                new XElement("salary", proj.Foreman.Salary));
            var projElem = new XElement("buildingProject",
                new XElement("budjet", proj.Budjet),
                new XElement("name", proj.Name));
            projElem.Add(foremanElem);
            root.Add(projElem);
        }
        doc.Add(root);
        doc.Save(fileName);
    }

    public void SerializeXML(IEnumerable<BuildingProject> xxx, string fileName)
    {
        _deleteIfExists(fileName);
        
        var serializer = new XmlSerializer(typeof(List<BuildingProject>));
        using var stream = File.Create(fileName);
        serializer.Serialize(stream, xxx);
    }

    public void SerializeJSON(IEnumerable<BuildingProject> xxx, string fileName)
    {
        _deleteIfExists(fileName);

        var jsonText = JsonSerializer.Serialize(xxx);
        using var stream = File.CreateText(fileName);
        stream.Write(jsonText);
    }
}
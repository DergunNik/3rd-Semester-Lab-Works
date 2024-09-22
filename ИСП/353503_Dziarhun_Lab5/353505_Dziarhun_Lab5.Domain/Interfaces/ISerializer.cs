namespace _353505_Dziarhun_Lab5.Domain;

public interface ISerializer
{
    IEnumerable<BuildingProject> DeSerializeByLINQ(string fileName);
    IEnumerable<BuildingProject> DeSerializeXML(string fileName);
    IEnumerable<BuildingProject> DeSerializeJSON(string fileName);
    void SerializeByLINQ(IEnumerable<BuildingProject> xxx, string fileName);
    void SerializeXML(IEnumerable<BuildingProject> xxx, string fileName);
    void SerializeJSON(IEnumerable<BuildingProject> xxx, string fileName);
}
using System.Text.Json;
using Main.Interfaces;

namespace FileServices;

public class FileService<T> : IFileService<T> where T : class
{
    public IEnumerable<T> ReadFile(string fileName)
    {
        return JsonSerializer.Deserialize<List<T>>(File.ReadAllText(fileName));
    }

    public void SaveData(IEnumerable<T> data, string fileName)
    {
        if (File.Exists(fileName))
        {
            File.Delete(fileName);
        }
        
        var jsonText = JsonSerializer.Serialize(data);
        using var stream = File.CreateText(fileName);
        stream.Write(jsonText);
    }
}
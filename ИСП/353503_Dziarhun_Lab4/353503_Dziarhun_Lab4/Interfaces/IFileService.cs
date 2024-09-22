namespace _353503_Dziarhun_Lab4.Interfaces;

public interface IFileService<T>
{
    IEnumerable<T> ReadFile(string fileName);
    void SaveData(IEnumerable<T> data, string fileName);
}
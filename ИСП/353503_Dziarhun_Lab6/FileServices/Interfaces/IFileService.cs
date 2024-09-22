namespace Main.Interfaces;

interface IFileService<T> where T : class
{
    IEnumerable<T> ReadFile(string fileName);
    void SaveData(IEnumerable<T> data, string fileName);
}

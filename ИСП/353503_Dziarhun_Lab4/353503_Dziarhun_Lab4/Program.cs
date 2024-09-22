using _353503_Dziarhun_Lab4.Entites;
using _353503_Dziarhun_Lab4.Services;

internal class Program
{
    private static void ManageFolder()
    {
        const string dirPath = "Dziarhun_Lab4";
        var random = new Random();

        if (Directory.Exists(dirPath))
        {
            foreach (var file in Directory.GetFiles(dirPath))
            {
                File.Delete(file);
                Console.WriteLine($"File {file} has been deleted.");
            }
        }
        else
        {
            Directory.CreateDirectory(dirPath);
        }
        var extensions = new string[4] {"txt", "rtf", "dat", "inf"};
        for (byte i = 0; i < 10; ++i)
        {
            var fileName = Path.GetRandomFileName();
            var extension = extensions[random.Next(extensions.Length)];
            var fullPath = Path.Combine(dirPath, Path.ChangeExtension(fileName, extension));
            using (File.Create(fullPath)) { }
        }
        
        foreach (var file in Directory.GetFiles(dirPath))
        {
            Console.WriteLine($"Файл: {Path.GetFileName(file)} имеет расширение {Path.GetExtension(file)}");
        }
    }

    private static List<Participant> CreateParticipantList()
    {
        var random = new Random();
        var list = new List<Participant>();
        for (byte i = 0; i < 5; ++i)
        {
            list.Add(new Participant(Path.GetRandomFileName(), random.Next(100), random.Next(1) == 1));
        }
        return list;
    }
    
    public static void Main(string[] args)
    {
        ManageFolder();
        var fs = new FileService();
        var list1 = CreateParticipantList();
        const string fileName1 = "1f";
        const string fileName2 = "2f";
        fs.SaveData(list1, fileName1);
        if (File.Exists(fileName2))
        {
            File.Delete(fileName2);
        }
        File.Move(fileName1, fileName2);
        var list2 = new List<Participant>();
        foreach (var participant in fs.ReadFile(fileName2))
        {
            list2.Add(participant);
        }
        list2.Sort(new MyCustomComparer());
        Console.WriteLine();
        foreach (var elem in list1)
        {
            Console.WriteLine(elem.Name);
        }
        Console.WriteLine();
        foreach (var elem in list2)
        {
            Console.WriteLine(elem.Name);
        }
        list2.Sort((a, b) => a.Pos - b.Pos);
        Console.WriteLine();
        foreach (var elem in list2)
        {
            Console.WriteLine(elem.Pos);
        }
    }
}
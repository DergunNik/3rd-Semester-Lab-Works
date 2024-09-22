using _353503_Dziarhun_Lab4.Entites;
using _353503_Dziarhun_Lab4.Interfaces;

namespace _353503_Dziarhun_Lab4.Services;

public class FileService : IFileService<Participant>
{
    public IEnumerable<Participant> ReadFile(string fileName)
    {
        using var stream = File.OpenRead(fileName);
        var binReader = new BinaryReader(stream);   
        while (stream.Position < stream.Length)
        {
            string name = "";
            int pos = 0;
            bool exp = false;
            try
            {
                name = binReader.ReadString();
                pos = binReader.ReadInt32();
                exp = binReader.ReadBoolean();
            }
            catch (EndOfStreamException ex)
            {
                Console.WriteLine($"Reached the end of the stream: {ex.Message}");
            }
            catch (IOException ex)
            {
                Console.WriteLine($"I/O error occurred: {ex.Message}");
            }
            catch (ObjectDisposedException ex)
            {
                Console.WriteLine($"Stream was closed unexpectedly: {ex.Message}");
            }

            yield return new Participant(name, pos, exp);
        }
    }


    public void SaveData(IEnumerable<Participant> data, string fileName)
    {
        try
        {
            if (File.Exists(fileName))
            {
                File.Delete(fileName);
            }
            using var stream = File.Create(fileName);
            var binWriter = new BinaryWriter(stream);
            foreach (var participant in data)
            {
                binWriter.Write(participant.Name);
                binWriter.Write(participant.Pos);
                binWriter.Write(participant.HasExperience);
            }
        }
        catch (IOException ex)
        {
            Console.WriteLine($"I/O error occurred: {ex.Message}");
        }
        catch (ObjectDisposedException ex)
        {
            Console.WriteLine($"Stream was closed unexpectedly: {ex.Message}");
        }
    }

}
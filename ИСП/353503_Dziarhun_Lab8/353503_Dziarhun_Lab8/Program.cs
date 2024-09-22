using System.Diagnostics;
using _353503_Dziarhun_Lab8.Entites;
using _353503_Dziarhun_Lab8.Services;

namespace _353503_Dziarhun_Lab8;

internal class Program
{
    static IEnumerable<Passenger> getPassengers()
    {
        var list = new List<Passenger>();
        var rand = new Random();
        int id = 0;
        for (int i = 0; i < 1000; ++i)
        {
            list.Add(new Passenger(++id, LoremNET.Lorem.Words(1), rand.Next(2) % 2 == 0));
        }
        return list;
    }
        
    static void startEndReport((string message, int id) args)
    {
        Console.WriteLine($"progress : Thread {args.id} : " + (args.message));
    }
    
    static async Task Main(string[] args)
    {
        Console.WriteLine($"Primary thread ID is {Thread.CurrentThread.ManagedThreadId}");
        const string fileName = "lab_data.txt";
        var progress = new Progress<(string message, int id)>(startEndReport);
        progress.ProgressChanged += (_, eArgs) =>
        {
            Console.WriteLine($"program: Thread {eArgs.id} : " + eArgs.message);
        };
        var streamService = new StreamService<Passenger>();
        var list = getPassengers();
        await using (var stream = new MemoryStream())
        {
            var writeTask = streamService.WriteToStreamAsync(stream, list, progress); 
            await Task.Delay(200);
            var copyTask = streamService.CopyFromStreamAsync(stream, fileName, progress);
            Console.WriteLine($"This thread ID is {Thread.CurrentThread.ManagedThreadId}");
            Console.WriteLine($"Tasks {writeTask.Id} and {copyTask.Id} are running");
            Task.WaitAll(writeTask, copyTask);
            var statTask = streamService.GetStatisticsAsync(fileName, passenger => passenger.HasLuggage);
            Console.WriteLine("Waiting for statistics");
            await statTask;
            Console.WriteLine($"Number of passengers with luggage is {statTask.Result}");
        }
    }
}
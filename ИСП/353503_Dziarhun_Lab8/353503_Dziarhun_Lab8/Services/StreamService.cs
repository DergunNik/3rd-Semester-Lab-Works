using System.Text.Json;

namespace _353503_Dziarhun_Lab8.Services;

public class StreamService<T>
{
    private readonly Semaphore _semaphor = new(1, 1);
    
    public async Task WriteToStreamAsync(Stream stream, IEnumerable<T> data, IProgress<(string, int)> progress)
    {
        progress.Report(("enter write method", Thread.CurrentThread.ManagedThreadId));
        _semaphor.WaitOne();
        progress.Report(("start writing to stream", Thread.CurrentThread.ManagedThreadId));
        await JsonSerializer.SerializeAsync(stream, data); 
        await Task.Delay(5000);
        progress.Report(("finished writing to stream", Thread.CurrentThread.ManagedThreadId));
        _semaphor.Release();
    }
    
    public async Task CopyFromStreamAsync(Stream stream, string filename, IProgress<(string, int)> progress)
    {
        progress.Report(("enter copy method", Thread.CurrentThread.ManagedThreadId));
        _semaphor.WaitOne();
        progress.Report(("start reading from stream", Thread.CurrentThread.ManagedThreadId));
        await using (var fileStream = File.Create(filename))
        {
            stream.Position = 0;
            await stream.CopyToAsync(fileStream);
        }
        progress.Report(("finished reading from stream", Thread.CurrentThread.ManagedThreadId));
        _semaphor.Release();
    }

    public async Task<int?> GetStatisticsAsync(string fileName, Func<T, bool> filter)
    {
        await using var stream = File.OpenRead(fileName);
        var data = await JsonSerializer.DeserializeAsync<IEnumerable<T>>(stream);
        return data?.AsParallel().Where(filter).Count();
    }
}
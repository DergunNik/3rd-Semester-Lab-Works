namespace _353503_Dziarhun_Lab7;

class Program
{
    static SinIntegral ManageSin(int maxThrdsNmbr)
    {
        var sin = new SinIntegral(maxThrdsNmbr);
        sin.CalculationCompleted += (sender, eventArgs) =>
        {
            Console.WriteLine(
                $"Поток {eventArgs.ThreadId}: Завершен с результатом: {eventArgs.Result}: За {eventArgs.Duration} тиков");
        };
        sin.CalculationProgress += (sender, eventArgs) =>
        {
            string progress = new string('=', (int)(eventArgs.ReadinessPercentage * 20));
            progress = progress + ">";
            Console.WriteLine($"Поток {eventArgs.ThreadId}: [{progress}] {eventArgs.ReadinessPercentage * 100}%");
        };
        return sin;
    }
    
    static void StartTwoThreads(SinIntegral sin)
    {
        var th1 = new Thread(sin.Calculate);
        var th2 = new Thread(sin.Calculate);
        th1.Priority = ThreadPriority.Highest;
        th2.Priority = ThreadPriority.Lowest;
        th1.Start();
        th2.Start();
    }

    static void StartNThreads(SinIntegral sin, byte n)
    {
        var threads = new List<Thread>();
        for (byte i = 0; i < n; ++i)
            threads.Add(new Thread(sin.Calculate));
        foreach (var thr in threads)
            thr.Start();
    }
    
    static void Main(string[] args)
    {
        var sin = ManageSin(3);
        StartTwoThreads(sin);
        Console.WriteLine();
        Console.WriteLine("-------------------------------------------------");
        Console.WriteLine();
        StartNThreads(sin, 5);
    }
}
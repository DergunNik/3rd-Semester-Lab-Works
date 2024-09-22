using System.Diagnostics;

namespace _353503_Dziarhun_Lab7;

public class SinIntegral(int maxThrdsNmbr)
{
    private const double _dx = 0.00000001;
    private const int _calcNumb = 100;
    private Semaphore _semaphor = new Semaphore(maxThrdsNmbr, maxThrdsNmbr);
    
    public class CalculationCompletedEventArgs(double result, long duration, int threadId) : EventArgs
    {
        public double Result { get; } = result;
        public long Duration { get; } = duration;
        public int ThreadId { get; } = threadId;
    }
    
    public class CalculationProgressEventArgs(float readinessPercentage, double currentSum, int threadId) : EventArgs
    {
        public float ReadinessPercentage { get; } = readinessPercentage;
        public double CurrentSum { get; } = currentSum;
        public int ThreadId { get; } = threadId;
    }
    
    public event EventHandler<CalculationCompletedEventArgs> CalculationCompleted;
    public event EventHandler<CalculationProgressEventArgs> CalculationProgress;

    public void Calculate()
    {
        _semaphor.WaitOne();
        var stopwatch = new Stopwatch();
        var threadId = Thread.CurrentThread.ManagedThreadId;
        stopwatch.Start();
        
        double sum = 0;
        double x = 0;
        while (x <= 1)
        {
            sum += Math.Sin(x) * _dx;
            for (int i = 0; i < _calcNumb; ++i)
            {
                var a = _calcNumb * sum;
            }

            if ((int)(x * 1e8) % 1000000 == 0) 
                CalculationProgress?.Invoke(this, new CalculationProgressEventArgs((float)x, sum, threadId));
            x += _dx;
        }
        stopwatch.Stop();
        CalculationCompleted?.Invoke(this, new CalculationCompletedEventArgs(sum, stopwatch.ElapsedTicks, threadId));
        _semaphor.Release();
    }
}
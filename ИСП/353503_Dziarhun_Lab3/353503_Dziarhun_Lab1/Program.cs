using _353503_Dziarhun_Lab1.Entities;

internal class Program
{
    static public void InitSys(InternetOperatorSystem sys)
    {
        Console.WriteLine(sys.CreateTariff("FirstT", 123, true));
        Console.WriteLine(sys.CreateTariff("SecondT", 1, false));
        Console.WriteLine(sys.CreateTariff("ThirdT", 1000, true));
        Console.WriteLine(sys.AddUser("FU"));
        Console.WriteLine(sys.AddUser("SU"));
        Console.WriteLine(sys.AddUser("TU"));
        sys.AddTraffic(1,1,132);
        sys.AddTraffic(2,1,13002);
        sys.AddTraffic(3,1,1);
        sys.AddTraffic(1,2,0);
        sys.AddTraffic(3,3,909);
        Console.WriteLine(sys.GetAllPayments());
        Console.WriteLine(sys.GetUserPayments(1));
        Console.WriteLine(sys.GetUserPayments(2));
        Console.WriteLine(sys.GetUserPayments(3));
        Console.WriteLine(sys.GetTariffPayments(1));
        Console.WriteLine(sys.GetTariffPayments(2));
        Console.WriteLine(sys.GetTariffPayments(3));
    }
    
    public static void Main(string[] args)
    {
        var sys = new InternetOperatorSystem();
        var journal = new Journal();
        sys.ListChangeEvent += journal.LogEvent;
        sys.TrafficEvent += (sender, eventArgs) =>
        {
            Console.WriteLine(eventArgs.UserId.ToString() + ": " +
                              eventArgs.TariffId.ToString() + ": " +
                              eventArgs.Value.ToString());  
        };
        InitSys(sys);
        journal.ShowLog();
        try
        {
            sys.GetUserPayments(99);
        }
        catch (ArgumentOutOfRangeException e)
        {
            Console.WriteLine(e.Message);
        }
        Console.WriteLine(sys.GetUsersWithTrafficPriceHigherThen(20000));
        foreach (var tariffNumber in sys.GetTariffUserNumberDictionary())
        {
            Console.WriteLine(tariffNumber);
        }
    }
}
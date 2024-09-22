namespace _353503_Dziarhun_Lab1.Contracts;

public interface IInternetOperator
{
    int CreateTariff(string name, ulong mbPrice, bool isMonthlyPaid);
    int AddUser(string name);
    void AddTraffic(int userId, int tariffId, ulong value);
    ulong GetAllPayments();
    ulong GetTariffPayments(int tariffId);
    int GetBestUser();
    
    event EventHandler<TrafficEventArgs> TrafficEvent;
    event EventHandler<ListChangeEventArgs> ListChangeEvent;
}   

public class TrafficEventArgs(int userId, int tariffId, ulong value) : EventArgs
{
    public int UserId { get; } = userId;
    public int TariffId { get; } = tariffId;
    public ulong Value { get; } = value;
}

public class ListChangeEventArgs(bool isUser, bool isNew, int id) : EventArgs
{
    public bool IsUserListChange { get; } = isUser;
    public bool IsNewListElement { get; } = isNew;
    public int Id { get; } = id;
}
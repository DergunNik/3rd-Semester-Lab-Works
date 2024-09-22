namespace _353503_Dziarhun_Lab1.Contracts;

public interface IInternetOperator
{
    uint CreateTariff(string name, ulong mbPrice, bool isMonthlyPaid);
    uint AddUser(string name);
    void AddTraffic(uint userId, uint tariffId, ulong value);
    ulong GetAllPayments();
    ulong GetTariffPayments(uint tariffId);
    uint GetBestUser();
    
    event EventHandler<TrafficEventArgs> TrafficEvent;
    event EventHandler<ListChangeEventArgs> ListChangeEvent;
}   

public class TrafficEventArgs(uint userId, uint tariffId, ulong value) : EventArgs
{
    public uint UserId { get; } = userId;
    public uint TariffId { get; } = tariffId;
    public ulong Value { get; } = value;
}

public class ListChangeEventArgs(bool isUser, bool isNew, uint id) : EventArgs
{
    public bool IsUserListChange { get; } = isUser;
    public bool IsNewListElement { get; } = isNew;
    public uint Id { get; } = id;
}
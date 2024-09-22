using System.Numerics;
namespace _353503_Dziarhun_Lab1.Entities;

public class User : IAdditionOperators<User, User, User>
{
    public int ID { get; }
    private string _name;
    public string Name 
    { 
        get => _name; 
        set => _name = value ??  throw new ArgumentNullException(nameof(value)); 
    }
    private List<(Tariff? Tariff, ulong Traffic)> _consumptions;
    public List<(Tariff? Tariff, ulong Traffic)> Consumptions => _consumptions;
    
    public User(int id, string name)
    {
        ID = id;
        Name = name ?? throw new ArgumentNullException(nameof(name));
        _consumptions = new List<(Tariff?, ulong)>();
    }
    
    public void AddTraffic(Tariff tariffRef, ulong value)
    {
        for (int i = 0; i < _consumptions.Count; ++i)
        {
            if (_consumptions[i].Tariff == tariffRef)
            {
                var temp = _consumptions[i];
                temp.Traffic += value;
                _consumptions[i] = temp;
                return;
            }
        }
        _consumptions.Add((tariffRef, value));
    }

    public void ClearTraffic()
    {
        _consumptions.Clear();
    }

    public ulong GetTrafficSum()
    {
        ulong trafficSum = 0;
        foreach (var traffic in _consumptions)
        {
            trafficSum += traffic.Traffic * traffic.Tariff.MbPrice;
        }
        return trafficSum;
    }

    public static User operator +(User left, User right)
    {
        if (left.ID == right.ID)
        {
            throw new InvalidOperationException("Cannot add users with the same IDs.");
        }
        var result = new User(0, "Sum");
        foreach (var consumption in left._consumptions)
        {
            result.AddTraffic(consumption.Tariff, consumption.Traffic);
        }
        foreach (var consumption in right._consumptions)
        {
            result.AddTraffic(consumption.Tariff, consumption.Traffic);
        }
        return result;
    }
}
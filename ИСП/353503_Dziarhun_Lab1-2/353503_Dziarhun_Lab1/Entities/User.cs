using System.Numerics;
using _353503_Dziarhun_Lab1.Collections;
namespace _353503_Dziarhun_Lab1.Entities;

public class User : IAdditionOperators<User, User, User>
{
    public uint ID { get; }
    private string _name;
    private ulong _trafficSum = 0;
    private bool _isTrafficModified = true;
    public string Name 
    { 
        get => _name; 
        set => _name = value ??  throw new ArgumentNullException(nameof(value)); 
    }
    private MyCustomCollection<(Tariff Tariff, ulong Traffic)> _consumptions;
    public MyCustomCollection<(Tariff Tariff, ulong Traffic)> Consumptions => _consumptions;

    private void _setSum(ulong newSum)
    {
        _trafficSum = newSum;
        _isTrafficModified = false;
    }

    public User(uint id, string name)
    {
        ID = id;
        Name = name ?? throw new ArgumentNullException(nameof(name));
        _consumptions = new MyCustomCollection<(Tariff, ulong)>();
    }
    
    public void AddTraffic(Tariff tariffRef, ulong value)
    {
        for (uint i = 0; i < _consumptions.Count; ++i)
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
        _isTrafficModified = true;
    }

    public void ClearTraffic()
    {
        _consumptions.Restart();
        _isTrafficModified = true;
    }

    public ulong GetTrafficSum()
    {
        if (_isTrafficModified)
        {
            _trafficSum = 0;
            foreach (var traffic in _consumptions)
            {
                _trafficSum += traffic.Traffic * traffic.Tariff.MbPrice;
            }
            _isTrafficModified = false;
        }
        return _trafficSum;
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

        ulong sum = left.GetTrafficSum();
        sum += right.GetTrafficSum();
        result._setSum(sum);
        return result;
    }
}
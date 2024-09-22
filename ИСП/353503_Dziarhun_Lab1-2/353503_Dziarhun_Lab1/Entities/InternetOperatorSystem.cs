using System.Runtime.Serialization;
using _353503_Dziarhun_Lab1.Collections;
using _353503_Dziarhun_Lab1.Contracts;

namespace _353503_Dziarhun_Lab1.Entities;

public class InternetOperatorSystem : IInternetOperator
{
    private MyCustomCollection<User> _users;
    private MyCustomCollection<Tariff> _tariffs;
    private uint _tariffsNumber;
    private uint _usersNumber;

    public InternetOperatorSystem()
    {
        _users = new MyCustomCollection<User>();
        _tariffs = new MyCustomCollection<Tariff>();
        _tariffsNumber = 0;
        _usersNumber = 0;
    }

    public uint CreateTariff(string name, ulong mbPrice, bool isMonthlyPaid)
    {
        _tariffs.Add(new Tariff(++_tariffsNumber, name, mbPrice, isMonthlyPaid));
        ListChangeEvent?.Invoke(this, new ListChangeEventArgs(false, true, _tariffsNumber));
        return _tariffsNumber;
    }

    public uint AddUser(string name)
    {
        _users.Add(new User(++_usersNumber, name));
        ListChangeEvent?.Invoke(this, new ListChangeEventArgs(true, true, _usersNumber));
        return _usersNumber;
    }

    public void AddTraffic(uint userId, uint tariffId, ulong value)
    {
        if (userId > _usersNumber || userId == 0)
        {
            throw new ArgumentException(null, nameof(userId));
        }

        var temp = _users[userId - 1];
        temp.AddTraffic(_tariffs[tariffId], value);
        _users[userId - 1] = temp;
        TrafficEvent?.Invoke(this, new TrafficEventArgs(userId, tariffId, value));
    }

    public ulong GetAllPayments()
    {
        User sumUser = new User(0, "Sum");
        foreach (var user in _users)
        {
            sumUser = sumUser + user;
        }
        return sumUser.GetTrafficSum();
    }

    public ulong GetTariffPayments(uint tariffId)
    {
        ulong sum = 0;
        foreach (var user in _users)
        {
            foreach (var traffic in user.Consumptions)
            {
                if (traffic.Tariff.ID == tariffId)
                {
                    sum += traffic.Traffic * traffic.Tariff.MbPrice;
                }
            }
        }
        return sum;
    }
    
    public ulong GetUserPayments(uint userId)
    {
        return _users[userId - 1].GetTrafficSum();
    }

    public uint GetBestUser()
    {
        ulong greatestSum = 0;
        uint bestUserId = 0;
        foreach (var user in _users)
        {
            if (user.GetTrafficSum() > greatestSum)
            {
                bestUserId = user.ID;
            }
        }

        return bestUserId;
    }

    uint GetUserId(string name)
    {
        foreach (var user in _users)
        {
            if (user.Name == name)
            {
                return user.ID;
            }
        }

        return 0;
    }

    uint GetTariffId(string name)
    {
        foreach (var tariff in _tariffs)
        {
            if (tariff.Name == name)
            {
                return tariff.ID;
            }
        }

        return 0;
    }
    
    public event EventHandler<TrafficEventArgs>? TrafficEvent;
    public event EventHandler<ListChangeEventArgs>? ListChangeEvent;
}
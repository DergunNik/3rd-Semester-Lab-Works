using System.Runtime.Serialization;
using _353503_Dziarhun_Lab1.Contracts;

namespace _353503_Dziarhun_Lab1.Entities;

public class InternetOperatorSystem : IInternetOperator
{
    private List<User> _users;
    private Dictionary<int, Tariff> _tariffs;
    private int _tariffsNumber;
    private int _usersNumber;

    public InternetOperatorSystem()
    {
        _users = new List<User>();
        _tariffs = new Dictionary<int, Tariff>();
        _tariffsNumber = 0;
        _usersNumber = 0;
    }

    public int CreateTariff(string name, ulong mbPrice, bool isMonthlyPaid)
    {
        ++_tariffsNumber;
        _tariffs.Add(_tariffsNumber, new Tariff(_tariffsNumber, name, mbPrice, isMonthlyPaid));
        ListChangeEvent?.Invoke(this, new ListChangeEventArgs(false, true, _tariffsNumber));
        return _tariffsNumber;
    }

    public int AddUser(string name)
    {
        _users.Add(new User(++_usersNumber, name));
        ListChangeEvent?.Invoke(this, new ListChangeEventArgs(true, true, _usersNumber));
        return _usersNumber;
    }

    public void AddTraffic(int userId, int tariffId, ulong value)
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

    public ulong GetTariffPayments(int tariffId)
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
    
    public ulong GetUserPayments(int userId)
    {
        return _users[userId - 1].GetTrafficSum();
    }

    public int GetBestUser()
    {
        ulong greatestSum = 0;
        int bestUserId = 0;
        foreach (var user in _users)
        {
            if (user.GetTrafficSum() > greatestSum)
            {
                bestUserId = user.ID;
            }
        }

        return bestUserId;
    }
    
    public string GetBestUserName()
    {
        return _users[GetBestUser() - 1].Name;
    }

    int GetUserId(string name)
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

    int GetTariffId(string name)
    {
        foreach (var keyTariff in _tariffs)
        {
            if (keyTariff.Value.Name == name)
            {
                return keyTariff.Value.ID;
            }
        }

        return 0;
    }

    public List<string> GetALlTariffNames()
    {
        var ret = new List<string>();
        foreach (var keyTariff in _tariffs)
        {
            ret.Add(keyTariff.Value.Name);
        }
        return ret;
    }
    
    public int GetUsersWithTrafficPriceHigherThen(ulong price)
    {
        return _users.Aggregate(0, (a, b) => a + (b.GetTrafficSum() > price ? 1 : 0));
    }

    public IEnumerable<(int, int)> GetTariffUserNumberDictionary()
    {
        return _users.SelectMany(a => a.Consumptions.Select(b => b.Tariff.ID))
                    .GroupBy(a => a)
                    .Select(a => (a.Key, a.Count()));
    }
    
    public event EventHandler<TrafficEventArgs>? TrafficEvent;
    public event EventHandler<ListChangeEventArgs>? ListChangeEvent;
}
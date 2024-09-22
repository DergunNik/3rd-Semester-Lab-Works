namespace _353503_Dziarhun_Lab1.Entities;

public class Tariff
{
    public bool IsMonthlyPaid { get; set; }
    public ulong MbPrice { get; set; }
    public uint ID { get; }
    private string _name;
    public string Name 
    { 
        get => _name; 
        set => _name = value ??  throw new ArgumentNullException(nameof(value)); 
    }

    public Tariff(uint id, string? name, ulong mbPrice, bool isMonthlyPaid)
    {
        ID = id;
        _name = name ?? throw new ArgumentNullException(nameof(name));
        MbPrice = mbPrice;
        IsMonthlyPaid = isMonthlyPaid;
    }
}
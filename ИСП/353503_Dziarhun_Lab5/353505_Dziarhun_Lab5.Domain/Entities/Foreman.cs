namespace _353505_Dziarhun_Lab5.Domain;

public class Foreman(string name, int salary) : IEquatable<Foreman>
{
    public Foreman() : this("", 0)
    {}
    public string Name { get; set; } = name;
    public int Salary { get; set; } = salary;
    
    public bool Equals(Foreman? other)
    {
        return  other != null && 
                Name == other.Name &&
                Salary == other.Salary;
    }
}
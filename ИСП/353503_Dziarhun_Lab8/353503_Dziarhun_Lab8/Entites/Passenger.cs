namespace _353503_Dziarhun_Lab8.Entites;

public class Passenger(int id, string name, bool hasLuggage)
{
    public int Id { get; set; } = id;
    public string Name { get; set; } = name;
    public bool HasLuggage { get; set; } = hasLuggage;
    
    public Passenger() : this(-1, "", false)
    {}
}
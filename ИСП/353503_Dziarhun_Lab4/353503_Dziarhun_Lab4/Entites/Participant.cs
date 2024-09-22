namespace _353503_Dziarhun_Lab4.Entites;

public class Participant(string name, Int32 pos, bool experience)
{
    public string Name { get; set; } = name;
    public int Pos { get; set; } = pos;
    public bool HasExperience { get; set; } = experience;
}

public class MyCustomComparer : IComparer<Participant>
{
    public int Compare(Participant? x, Participant? y)
    {
        if (x == null || y == null)
        {
            throw new ArgumentException("Arguments cannot be null");
        }

        return string.CompareOrdinal(x.Name, y.Name);
    }
}
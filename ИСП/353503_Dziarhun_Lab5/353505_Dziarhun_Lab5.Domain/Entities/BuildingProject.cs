namespace _353505_Dziarhun_Lab5.Domain;

public class BuildingProject(int budjet, string name, Foreman foreman) : IEquatable<BuildingProject>
{
    public BuildingProject() : this(0, "", new Foreman("", 0))
    { }
    public Foreman Foreman { get; set; } = foreman;
    public int Budjet { get; set;  } = budjet;
    public string Name { get; set; } = name;
    
    public bool Equals(BuildingProject? other)
    {
        return other != null &&
               Foreman.Equals(other.Foreman) &&
               Budjet == other.Budjet &&
               Name == other.Name;
    }
}
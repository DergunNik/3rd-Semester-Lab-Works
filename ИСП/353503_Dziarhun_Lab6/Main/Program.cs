using System.Diagnostics;
using System.Net.Mime;
using System.Reflection;

namespace Main;

class Program
{
    static List<Employee> GetBProjectsList()
    {
        return new List<Employee>
        {
            new Employee {IsBoss = true, Name = "1", Salary = 10},
            new Employee {IsBoss = true, Name = "2", Salary = 20},
            new Employee {IsBoss = true, Name = "3", Salary = 20},
            new Employee {IsBoss = false, Name = "4", Salary = 40},
            new Employee {IsBoss = false, Name = "5", Salary = 30},
            new Employee {IsBoss = false, Name = "6", Salary = 30}
        };
    }
    
    static void Main(string[] args)
    {
        var asm = Assembly.LoadFrom("FileServices.dll"); 
        var type = asm.GetType("FileServices.FileService`1").MakeGenericType(typeof(Employee));
        var service = Activator.CreateInstance(type);
        var toFileMethod = type.GetMethod("SaveData");
        var fromFileMethod = type.GetMethod("ReadFile");
        var list = GetBProjectsList();
        toFileMethod.Invoke(service, new object?[] {list, "1"});
        var fileList = fromFileMethod.Invoke(service, new object?[] { "1" }) as IEnumerable<Employee>;
        foreach (var elem in fileList)
        {
            Console.WriteLine(elem.Name + $"; {elem.IsBoss}; {elem.Salary}");
        }
    }
}
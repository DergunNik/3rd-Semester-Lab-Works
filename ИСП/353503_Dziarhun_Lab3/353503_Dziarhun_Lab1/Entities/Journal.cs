using _353503_Dziarhun_Lab1.Contracts;

namespace _353503_Dziarhun_Lab1.Entities;

public class Journal
{
    private struct ListChangeRecord(bool isUser, bool isNew, int id)
    {
        public bool IsUserListChange { get; } = isUser;
        public bool IsNewListElement { get; } = isNew;
        public int Id { get; } = id;
    }
    private List<ListChangeRecord> _records;

    public Journal()
    {
        _records = new List<ListChangeRecord>();
    }

    public void LogEvent(object? sender, ListChangeEventArgs args)
    {
        var record = new ListChangeRecord(args.IsUserListChange, args.IsNewListElement, args.Id);
        _records.Add(record);
    }

    public void ShowLog()
    {
        foreach (var record in _records)
        {
            Console.WriteLine((record.IsUserListChange? "User" : "Tariff") + 
                              (record.IsNewListElement ? " is added" : " is removed") +
                              $"; ID: {record.Id}");
        }
    }
}
namespace _353503_Dziarhun_Lab1.Interfaces;

public interface ICustomCollection<T>
{
    T this[uint index] { get; set; }
    void Reset();
    void Next();
    T Current();
    uint Count { get; }
    void Add(T item);
    void Remove(T item);
    T RemoveCurrent();
}
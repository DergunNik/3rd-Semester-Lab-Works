using System.Collections;
using _353503_Dziarhun_Lab1.Interfaces;

namespace _353503_Dziarhun_Lab1.Collections;

public class NonexistentObjectException<T>(string message) : Exception(message)
{
    public T? NonexistentObject { get; set; }
}

public class MyCustomCollection<T> : ICustomCollection<T>, IEnumerable<T>
{
    private uint size = 0;
    private uint pointer = 0;
    private Node? head = null;
    private Node? tail = null;
    
    protected class Node
    {
        public T Data { get; set; }
        public Node? NextNode;
        
        public Node(T data)
        {
            Data = data;
            NextNode = null;
        }
    }

    private Node FindNode(uint index)
    {
        if (index >= size)
        {
            throw new IndexOutOfRangeException();
        }

        var curNode = head;
        while (index > 0)
        {
            curNode = curNode!.NextNode;
            --index;
        }

        return curNode!;
    }
    
    public T this[uint index]
    {
        get => FindNode(index).Data;
        set => FindNode(index).Data = value;
    }

    public void Reset()
    {
        pointer = 0;
    }

    public void Next()
    {
        ++pointer;
    }

    public T Current()
    {
        return this[pointer];
    }

    public uint Count
    {
        get => size;
    }

    public void Add(T item)
    {
        if (size == 0)
        {
            head = new Node(item);
            tail = head;
        }
        else
        {
            tail!.NextNode = new Node(item);
            tail = tail.NextNode;
        }

        ++size;
    }

    public void Remove(T item)
    {
        if (size == 0)
        {
            return;
        }

        var curNode = head;
        Node? prevNode = null;
        while (curNode != null && !curNode.Data!.Equals(item))
        {
            prevNode = curNode;
            curNode = curNode.NextNode;
        }

        if (curNode != null && curNode.Data!.Equals(item))
        {
            if (prevNode != null)
            {
                prevNode.NextNode = curNode.NextNode;
            }
            else
            {
                head = curNode.NextNode;
            }

            if (curNode == tail)
            {
                tail = prevNode;
            }

            --size;
            return;
        }

        throw new NonexistentObjectException<T>("There is no such item in collection to delete") {NonexistentObject = item};
    }

    public T RemoveCurrent()
    {
        var curNode = FindNode(pointer);
        T data = curNode.Data;
        curNode = curNode.NextNode;
        --size;
        return data;
    }

    public void Restart()
    {
        size = 0;
        pointer = 0;
        head = null;
        tail = null;
    }
    
    public IEnumerator<T> GetEnumerator()
    {
        for (uint i = 0; i < size; ++i)
        {
            yield return this[i];
        } 
    }
    
    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }
}
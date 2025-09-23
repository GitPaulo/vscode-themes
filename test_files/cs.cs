// Single-line comment
/* Multi-line comment */
#nullable enable

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Demo.Core
{
    /// <summary>
    /// Example enum with flags
    /// </summary>
    [Flags]
    public enum FileAccessMode { None = 0, Read = 1, Write = 2, Execute = 4 }

    /// <summary>
    /// Simple immutable record
    /// </summary>
    public record Person(string FirstName, string LastName, int Age);

    /// <summary>
    /// Point struct demonstrating operator overloads
    /// </summary>
    public struct Point
    {
        public double X { get; set; }
        public double Y { get; set; }

        public static Point operator +(Point a, Point b) => new Point { X = a.X + b.X, Y = a.Y + b.Y };
        public override string ToString() => $"({X}, {Y})";
    }

    /// <summary>
    /// Interface with event and indexer
    /// </summary>
    public interface IRepository<T>
    {
        event EventHandler<T>? ItemAdded;
        T this[int index] { get; }
        void Add(T item);
        IEnumerable<T> Find(Func<T, bool> predicate);
    }

    /// <summary>
    /// Generic repository implementation
    /// </summary>
    public class Repository<T> : IRepository<T>, IEnumerable<T>
    {
        private readonly List<T> _items = new();
        public event EventHandler<T>? ItemAdded;

        public T this[int index] => _items[index];

        public void Add(T item)
        {
            _items.Add(item);
            ItemAdded?.Invoke(this, item);
        }

        public IEnumerable<T> Find(Func<T, bool> predicate) => _items.Where(predicate);

        public IEnumerator<T> GetEnumerator() => _items.GetEnumerator();
        IEnumerator IEnumerable.GetEnumerator() => GetEnumerator();
    }
}

namespace Demo.App
{
    using Demo.Core;

    public static class Utilities
    {
        /// <summary>
        /// Example of local functions and tuples
        /// </summary>
        public static (double min, double max) MinMax(IEnumerable<double> values)
        {
            if (values == null) throw new ArgumentNullException(nameof(values));
            double LocalMin(IEnumerable<double> v) => v.Min();
            double LocalMax(IEnumerable<double> v) => v.Max();
            return (LocalMin(values), LocalMax(values));
        }

        public static async Task<string> ReadFileAsync(string path)
        {
            using var reader = new StreamReader(path, Encoding.UTF8);
            return await reader.ReadToEndAsync().ConfigureAwait(false);
        }
    }

    public class Program
    {
        private static readonly string Greeting = "Hello World";

        public static async Task Main(string[] args)
        {
            // Primitive types and interpolated strings
            int count = 42;
            double pi = Math.PI;
            var list = new List<string> { "a", "b", "c" };

            foreach (var item in list)
            {
                Console.WriteLine($"{Greeting} {item} {count} {pi:F3}");
            }

            // Struct usage and operator overload
            Point p1 = new() { X = 1.5, Y = 2.5 };
            Point p2 = new() { X = -0.5, Y = 3.0 };
            Console.WriteLine($"Point Sum: {p1 + p2}");

            // Record and pattern matching
            var person = new Person("Alice", "Doe", 30);
            Console.WriteLine(person with { Age = 31 });

            string description = person.Age switch
            {
                < 18 => "Minor",
                >= 18 and < 65 => "Adult",
                _ => "Senior"
            };
            Console.WriteLine($"Category: {description}");

            // Events and repository
            var repo = new Repository<Person>();
            repo.ItemAdded += (s, e) => Console.WriteLine($"Added: {e.FirstName}");
            repo.Add(person);

            // LINQ and local function
            var (min, max) = Utilities.MinMax(new[] { 1.0, 5.5, -3.2, 9.9 });
            Console.WriteLine($"Range: {min} to {max}");

            // Async/await demo (reads this file itself if args provided)
            if (args.Length > 0)
            {
                try
                {
                    string content = await Utilities.ReadFileAsync(args[0]);
                    Console.WriteLine($"File length: {content.Length}");
                }
                catch (IOException ex)
                {
                    Console.Error.WriteLine($"I/O Error: {ex.Message}");
                }
            }

            // Nullable reference type example
            string? optional = null;
            Console.WriteLine(optional ?? "No value");
        }
    }
}

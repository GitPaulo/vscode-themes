// Single-line comment
/* Multi-line comment */
#nullable enable

using System;
using System.Collections.Generic;

namespace Demo
{
    public enum Color { Red, Green, Blue }

    public struct Point
    {
        public double X { get; set; }
        public double Y { get; set; }
    }

    public class Program
    {
        private static readonly string Greeting = "Hello World";

        public static void Main(string[] args)
        {
            int count = 42;
            double pi = Math.PI;
            var list = new List<string> { "a", "b" };

            foreach (var item in list)
            {
                Console.WriteLine($"{Greeting} {item} {count} {pi}");
            }

            Point p = new Point { X = 1.5, Y = 2.5 };
            Console.WriteLine($"Point: {p.X}, {p.Y}");
        }
    }
}

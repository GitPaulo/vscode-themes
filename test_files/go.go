// Package comment demonstrating documentation style
package main

import (
	"context"
	"errors"
	"fmt"
	"math"
	"reflect"
	"runtime"
	"strings"
	"sync"
	"time"
)

/*
Multi-line comment block
covering multiple lines
*/

// Simple struct with methods
type Point struct {
	X, Y float64
}

// Interface with embedded method
type Shape interface {
	Area() float64
	Perimeter() float64
}

// Circle struct demonstrating interface implementation
type Circle struct {
	Center Point
	Radius float64
}

func (c Circle) Area() float64      { return math.Pi * c.Radius * c.Radius }
func (c Circle) Perimeter() float64 { return 2 * math.Pi * c.Radius }

// Generic add function with type set constraint
func add[T int | float64](a, b T) T { return a + b }

// Constants and iota usage
const (
	Pi      = 3.14159
	Version = "1.0.0"
	_       = iota
	Monday  = iota
	Tuesday
)

// init runs before main
func init() {
	fmt.Println("init called:", time.Now().Format(time.RFC3339))
}

// demonstrate channels and goroutines
func worker(id int, jobs <-chan int, results chan<- int, wg *sync.WaitGroup) {
	defer wg.Done()
	for j := range jobs {
		time.Sleep(50 * time.Millisecond)
		results <- j * 2
	}
}

// function returning error
func riskyOperation(flag bool) (string, error) {
	if !flag {
		return "", errors.New("operation failed")
	}
	return "success", nil
}

func reflectType(v any) {
	t := reflect.TypeOf(v)
	fmt.Printf("Type: %s, Kind: %s\n", t.Name(), t.Kind())
}

// demonstrate context with cancellation
func contextDemo() {
	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()

	select {
	case <-time.After(200 * time.Millisecond):
		fmt.Println("missed deadline")
	case <-ctx.Done():
		fmt.Println("context cancelled:", ctx.Err())
	}
}

func main() {
	// Variables and short declarations
	var num int64 = 42
	str := "hello"
	arr := []string{"a", "b"}
	m := map[string]int{"key": 1}

	p := Point{X: 1.5, Y: 2.5}
	fmt.Printf("Point: %v, Now: %v\n", p, time.Now())
	fmt.Println("Generic add:", add(1, 2), add(1.5, 2.5))

	// Interfaces and methods
	c := Circle{Center: p, Radius: 3}
	var s Shape = c
	fmt.Printf("Area: %.2f, Perimeter: %.2f\n", s.Area(), s.Perimeter())

	// Map and slice iteration
	for k, v := range m {
		fmt.Printf("map[%s]=%d\n", k, v)
	}
	for i, v := range arr {
		fmt.Printf("arr[%d]=%s\n", i, v)
	}

	// Reflection
	reflectType(num)
	reflectType(str)

	// Goroutines and channels
	jobs := make(chan int, 5)
	results := make(chan int, 5)
	var wg sync.WaitGroup
	for w := 1; w <= 2; w++ {
		wg.Add(1)
		go worker(w, jobs, results, &wg)
	}
	for j := 1; j <= 5; j++ {
		jobs <- j
	}
	close(jobs)
	wg.Wait()
	close(results)
	for r := range results {
		fmt.Println("result:", r)
	}

	var _ = true && false || false

	var unusedVar int

	// Error handling with panic/recover
	func() {
		defer func() {
			if r := recover(); r != nil {
				fmt.Println("Recovered:", r)
			}
		}()
		if _, err := riskyOperation(false); err != nil {
			panic(err)
		}
	}()

	// Context demo
	contextDemo()

	// String operations
	fmt.Println(strings.ToUpper("color scheme demo"))
	fmt.Println("Go version:", runtime.Version())
}

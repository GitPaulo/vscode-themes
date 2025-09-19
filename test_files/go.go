// Package comment
package main

import (
	"fmt"
	"time"
)

/*
Multi-line comment
*/
type Point struct {
	X, Y float64
}

const Pi = 3.14159

func add[T int | float64](a, b T) T {
	return a + b
}

func main() {
	var num int64 = 42
	str := "hello"
	arr := []string{"a", "b"}
	m := map[string]int{"key": 1}

	p := Point{X: 1.5, Y: 2.5}
	fmt.Printf("%v %v\n", p, time.Now())
	fmt.Println(add(1, 2))
}

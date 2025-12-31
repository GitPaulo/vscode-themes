/*
 * Comprehensive C Test File
 * Tests all major language constructs for syntax highlighting
 */

// Include standard libraries
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Preprocessor macros
#define MAX_SIZE 100
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define DEBUG 1

#ifdef DEBUG
#define LOG(msg) printf("DEBUG: %s\n", msg)
#else
#define LOG(msg)
#endif

// Type definitions
typedef unsigned int uint;
typedef struct Point Point;
typedef enum
{
  RED,
  GREEN,
  BLUE
} Color;

// Enum declaration
enum Status
{
  SUCCESS = 0,
  ERROR = -1,
  PENDING = 1
};

// Struct declaration
struct Point
{
  int x;
  int y;
  char *label;
};

// Union declaration
union Data
{
  int i;
  float f;
  char str[20];
};

// Global variables
static int global_counter = 0;
const double PI = 3.14159265359;
volatile bool interrupt_flag = false;

// Function prototypes
int add(int a, int b);
void print_array(int *arr, size_t len);
char *string_concat(const char *s1, const char *s2);
static inline int square(int x);

// Inline function
static inline int square(int x)
{
  return x * x;
}

// Function with pointers
void swap(int *a, int *b)
{
  int temp = *a;
  *a = *b;
  *b = temp;
}

// Function with array
void print_array(int *arr, size_t len)
{
  printf("Array: [");
  for (size_t i = 0; i < len; i++)
  {
    printf("%d", arr[i]);
    if (i < len - 1)
      printf(", ");
  }
  printf("]\n");
}

// String manipulation
char *string_concat(const char *s1, const char *s2)
{
  size_t len1 = strlen(s1);
  size_t len2 = strlen(s2);
  char *result = (char *)malloc(len1 + len2 + 1);

  if (result == NULL)
  {
    return NULL;
  }

  strcpy(result, s1);
  strcat(result, s2);
  return result;
}

// Struct manipulation
Point *create_point(int x, int y, const char *label)
{
  Point *p = (Point *)malloc(sizeof(Point));
  p->x = x;
  p->y = y;
  p->label = strdup(label);
  return p;
}

void free_point(Point *p)
{
  if (p != NULL)
  {
    free(p->label);
    free(p);
  }
}

// Main function with various constructs
int main(int argc, char **argv)
{
  // Variable declarations
  int numbers[] = {1, 2, 3, 4, 5};
  float temperature = 98.6f;
  double large_num = 1.23e10;
  char letter = 'A';
  char *message = "Hello, World!";
  unsigned long hex_value = 0xDEADBEEF;
  bool is_valid = true;

  // Null pointer
  void *ptr = NULL;

  // Print basic info
  printf("Program: %s\n", argv[0]);
  printf("Arguments: %d\n", argc - 1);

  // Arithmetic operations
  int sum = 10 + 20;
  int diff = 50 - 15;
  int product = 7 * 8;
  int quotient = 100 / 4;
  int remainder = 17 % 5;

  // Bitwise operations
  int a = 0b1010; // Binary literal (if supported)
  int b = 0x0F;   // Hex literal
  int and_result = a & b;
  int or_result = a | b;
  int xor_result = a ^ b;
  int not_result = ~a;
  int left_shift = a << 2;
  int right_shift = a >> 1;

  // Comparison operators
  if (sum > diff)
  {
    printf("Sum is greater\n");
  }
  else if (sum == diff)
  {
    printf("Equal\n");
  }
  else
  {
    printf("Sum is less\n");
  }

  // Logical operators
  if (is_valid && temperature > 0.0)
  {
    LOG("Valid temperature reading");
  }

  if (!interrupt_flag || global_counter == 0)
  {
    printf("Normal operation\n");
  }

  // Switch statement
  Color color = GREEN;
  switch (color)
  {
  case RED:
    printf("Color is red\n");
    break;
  case GREEN:
    printf("Color is green\n");
    break;
  case BLUE:
    printf("Color is blue\n");
    break;
  default:
    printf("Unknown color\n");
  }

  // While loop
  int count = 0;
  while (count < 5)
  {
    printf("Count: %d\n", count);
    count++;
  }

  // Do-while loop
  int i = 0;
  do
  {
    printf("i = %d\n", i);
    i++;
  } while (i < 3);

  // For loop
  for (int j = 0; j < MAX_SIZE; j += 10)
  {
    if (j == 50)
      continue;
    printf("j = %d\n", j);
    if (j > 70)
      break;
  }

  // Array manipulation
  print_array(numbers, sizeof(numbers) / sizeof(numbers[0]));

  // Pointer manipulation
  int x = 42, y = 84;
  printf("Before swap: x=%d, y=%d\n", x, y);
  swap(&x, &y);
  printf("After swap: x=%d, y=%d\n", x, y);

  // Struct usage
  Point *origin = create_point(0, 0, "Origin");
  printf("Point: (%d, %d) - %s\n", origin->x, origin->y, origin->label);
  free_point(origin);

  // Union usage
  union Data data;
  data.i = 10;
  printf("data.i = %d\n", data.i);
  data.f = 220.5f;
  printf("data.f = %.2f\n", data.f);

  // String concatenation
  char *greeting = string_concat("Hello, ", "C Programming!");
  if (greeting != NULL)
  {
    printf("%s\n", greeting);
    free(greeting);
  }

  // Ternary operator
  int max_val = (x > y) ? x : y;
  printf("Max value: %d\n", max_val);

  // Increment/Decrement
  int pre_inc = ++x;
  int post_inc = y++;
  int pre_dec = --x;
  int post_dec = y--;

  // Goto statement (generally discouraged)
  goto skip_section;
  printf("This will be skipped\n");

skip_section:
  printf("Jumped here\n");

  // Return statement
  return EXIT_SUCCESS;
}

// Additional function with complex logic
int add(int a, int b)
{
  return a + b;
}

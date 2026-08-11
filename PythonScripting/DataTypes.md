# Data Types and Variables - L1

## Description
Basic programming constructs in Python — declaring variables of different
built-in data types and inspecting their types using the `type()` function.

## Concept Task
**4 built-in data types in Python:**
1. `str` — String (text data, e.g. `"Charan"`)
2. `int` — Integer (whole numbers, e.g. `26`)
3. `float` — Floating point (decimal numbers, e.g. `5.9`)
4. `bool` — Boolean (`True` / `False`)

## Hands-on Task
A Python script (`data_types.py`) that:
- Declares one variable each of type `str`, `int`, `float`, and `bool`
- Prints the value and type of each variable using `type()`

## How to Run
```bash
python3 data_types.py
```

## Sample Output
```
Variable: name
Value: Charan
Type: <class 'str'>

Variable: age
Value: 26
Type: <class 'int'>

Variable: height
Value: 5.9
Type: <class 'float'>

Variable: is_devops_learner
Value: True
Type: <class 'bool'>
```

## Files
## Code
 
```python
"""
Assignment: Data Types and Variables - L1
Task: Declare a string, integer, float, and boolean variable,
      then print their values and types using type().
"""
 
# 1. String variable
name = "Charan"
 
# 2. Integer variable
age = 26
 
# 3. Float variable
height = 5.9
 
# 4. Boolean variable
is_devops_learner = True
 
# Print each variable's value along with its type
print("Variable: name")
print("Value:", name)
print("Type:", type(name))
print()
 
print("Variable: age")
print("Value:", age)
print("Type:", type(age))
print()
 
print("Variable: height")
print("Value:", height)
print("Type:", type(height))
print()
 
print("Variable: is_devops_learner")
print("Value:", is_devops_learner)
print("Type:", type(is_devops_learner))
```
 

<img width="1917" height="1021" alt="Screenshot 2026-08-11 084856" src="https://github.com/user-attachments/assets/64649cee-f6b5-4881-8a4b-ae34b48e7d3a" />

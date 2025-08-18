# Ruby Style Guide

- Use 2 spaces for indentation
- Use snake_case for methods and variables
- Use CamelCase for classes and modules
- Prefer single quotes for strings unless interpolation is needed
- When a method takes more than 2 arguments, use an 'options' hash as the 2nd argument to hold all of the additional arguments after the first, most important argument for the method. This way we can easily add, insert, or omit arguments as we maintain our codebase.

**Good example:**

```ruby
def do_something(object, options = {})
  first_option = options[:first_option]
  second_option = options[:second_option]
end
```

**Bad example:**

```ruby
def do_something(object, first_option, second_option)
  ...
end
```

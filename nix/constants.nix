# Central project metadata for template users
# When copying this template, only change values in this file
{ pkgs, ... }:

{
  # Project name - used in multiple files
  name = "hello";

  # The main CLI message
  greeting = "hello world!";

  # Test bad formatting
  test = { foo = "bar"; baz = 123; };
}

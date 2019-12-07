# Shell Basic

## Command Substitution

You can extract information from the result of a command using command substitution.

- The backtick character (`)
- The $() format

## Match calculation

You can perform basic math calculations using $(()) format.

```bash
#!/bin/bash

var1=$(( 5 + 5 ))

var2=$(( $var1 * 2 ))
```

## if-then statement

The most basic stracture  of if-then statement is like this:

```bash
if command; then
    commands
fi

if command; then
    commands
else
    commands
fi

if condition1; then
    commands
elif condition2; then
    commands
else
    commands
fi
```

## Combine tests

You can combine multiple tests using AND(&&) or OR(||) command.

```bash
#!/bin/bash

dir=//home/ae
name="ae"

if [ -d $dir ] && [ -n $name ]; then
    echo $dir:$name
else
    echo "One test failed"
fi

if [ -d $dir ] || [ -n $name ]; then
    echo "Succes!"
else
    echo "Both tests failed!"
fi
```

## Numeric comparisons

You can perform a numeric comparison between twonumeric values using numeric comparison check like this:

- number1 -eq number2
- number1 -ge number2
- number1 -gt number2
- number1 -le number2
- number1 -lt number2
- number1 -ne number2

## String comparisons

You can compare strings with one of the following ways:

- string1 = string2
- string1 != string2
- string1 < string2
- string1 > string2
- -n string
- -z string

One tricky note about the `greater than and less than` for string comparisons,
the `MUST` be escaped with the `backslash`. (pipeline)

```bash
#!/bin/bash

v1=text1
v2=text2

if [ $v1 \> $2 ]; then
    echo "$v1 is greater than $v2"
else
    echo "$v1 is less than $v2"
fi
```

## File comparisons

You can compare and check for files using the following operators:

- -d file, is directory
- -e file, if exist
- -f file, is file
- -r file, readable
- file1 -nt file2, newer than
- file1 -ot file2, older than
- -O file, owner
- -G file, groupwether

## for loop

The for command enables you to perform a loop on a list of items.

```bash
#!/bin/bash

# iterating over simple values
for var in first second third; do
    echo " $var"
done

# c-style
for(( var=1; var <= 5; var++)); do
    echo "number is $var"
done

# iterating over complex values
for var in first "the second" "the third" "some thing other"; do
    echo "This is: $var"
done

# command substitution
IFS=$'\n'
for var in $(cat /etc/passwd); do
    echo $var
done

# iterating over directory files
for obj in /home/ae/*; do
    if [ -d "$obj" ]; then
        echo "$obj is a folder"
    elif [ -f "$obj" ]; then
        echo "$obj is a file"
    fi
done
```

## The field separator

By default, the following characters treated as fields:

- space
- tab
- newline

if your text includes any of these characters, the shell will assume it's a new field.

Well, you can change the internal field separator or IFS environment variable, like this:

`IFS=$'\n'`

```bash
#!/bin/bash

IFS=:
for var in $(tail -n 1 /etc/passwd); do
    echo $var
done
```

## while loop

The while loop checks for a condtion before every iteration.

```bash
#!bin/bash

number=10
while [ $number -gt 4 ]; do
    echo $number
    number=$(( $number - 1 ))
done
```

## Controlling the loop

Maybe after the loop starts you want to stop at a specific value,
there are two commands help us in this:

- break
- continue

## Read parameters

- $0, the script's name
- $1, the 1st parameter

Until the 9th parameter which is $9.

- $#, counting parameters
- $*, holds all the parameters as `one value`
- $@, holds all the parameters as `separator values`

The `shift` command moves every parameter variable to the left.
Careful when using shift command, the shifted parameter is gone and cannot be revocered.

## scripting options

Options are single letters with a dash before it.

## separate options from parameters

Sometimes you need to use options and parameters in the same script.
You have to separate them.

The double dash (--) is used to end the option list.

```bash
#!/bin/bash

while [ -n "$1" ]; do
    case "$1" in
        -a) echo "-a option" ;;
        -b) echo "-b option" ;;
        --)
            shift //options end
            break
            ;;
        *) echo "Option $1 not recognized" ;;
    esac
    shift
done

echo "Parameters:"
for param in $@; do
    echo "    $param"
done
```

## Getting user input using the read command

The read command reads input from standard input or from a file descriptor
and stores it in a variable.

```bash
#!/bin/bash

read -t 5 -p "Please input var1 and var2 in 5 seconds: " var1 var2
echo "$var1:$var2"

read -s -p "Reading password: " pass
echo "$pass"

# read file
while read line; do
  echo $line
done </etc/passwd
```

## Standard file descriptors

Echo process can have 9 file descriptors opened at the same time.

The file descriptors 0,1,2 are kept for the bash shell usage:

- 0, STDIN
- 1, STDOUT
- 2, STDERR

## Redirect

There are two ways for outpt redirection:

- temporarily redirection
- permanently redirection

Temporarily redirection:

- command <file
- 1> file, 1>> file
- 2> file, 2>> file

Permanent redirection:

- exec 0< file
- exec 1> file
- exec 2> file

Custom redirection:

```bash
#!/bin/bash

exec 3> file

echo "This line appears on the screen"

echo "This line stored on myfile" >&3
```

Close file descriptor:

- exec 3>&-

# PACKER (luar)

This project contains a set of tools for linking and packaging
Lua scripts into embedded binaries, which can run even if Lua
is not installed.

## Hot to use

### build stubs

This tool uses "stub.c" which is an executable compiled with lua embedded,
it is able to find the script concatenated at the end of it using a special
mark and then executes it.

to generate the executables type:

    make

it will generate two executables, for linux and windows

### linker

The Linker is a tool that takes a script and modules passed to it
and turns them into a single thing.

I created the linker to solve a problem with the scripts embedded
in packer binaries, they would still be dependent on the Lua Path
and could result in an error. So what I did was create a tool that
brings everything together in a single file and makes some modifications
so that it can work in both the embedded environment and the normal
Lua environment.

With this, the programs do not need to be written specifically to
run in the binary embedded environment and also do not require the
programmer to add additional code to generate compatibility between
the two environments.

To know how to use linker you can type `linker help` on terminal

But a example can be founded in: examples/

To prepare the linked script in example use:

    lua linker.lua -o linked_script.lua \
        examples/program.lua \
        examples/tlib.lua    \
        examples/module1.lua \
        examples/module2.lua \
        examples/module3.lua

The linker will prepare a file with all modules and the main script
all in one. So you can execute the script without depends on Lua path
system.

To see how it's working, you can test it in two ways:

Conventional way:

    cd examples
    lua program.lua m

Linked way:

    cd ..
    lua linked_script.lua m

### Packer

To test the packer I recommend that you use the script
that was linked in the previous section.

    lua packer.lua linked_script.lua

This will generate two executables `linked_script` and `linked_script.exe`

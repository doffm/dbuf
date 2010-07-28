
# Introduction

dbuf is a language that describes dbus messages and interfaces. The language is very
simple, and is closely linked to D-Bus. Its basic types are those D-Bus uses, its
constructs generally match D-Bus features. The elements of the languages not present
in core D-Bus protocols have been chosen to help describe them.

The general syntax of the language is based on the 'C' family. In this respect it is
similar to 'C', Java, CORBA IDL or C#. The syntax for importing modules is a simplified
version of that used in C#.

# Interfaces & Namespaces

D-Bus objects implement interfaces. These are a description of what messages the
object is willing to accept, and how it will reply. To describe a interface in dbuf
use the `interface` keyword.

        interface org.dbuf.AnInterface {
                method FooBar {
                        int16 first;
                }
        }

The source code above, when translated to D-Bus XML would appear as:

        <interface name="org.dbuf.AnInterface">
                <method name="FooBar">
                        <arg name="first", type="n"/>
                </method>
        </interface>

dbuf can also use namespaces, which are very similar to namespaces in C# and C++.
The interface above could also be placed within a namespace to obtain the same
D-Bus name.

        namespace org.dbuf {
                interface AnInterface {
                        method FooBar {
                                int16 first;
                        }
                }
        }

This would be translated to the same XML as before. It is possible to nest namespaces
but it is not possible to place a namespace within an interface, or to nest interfaces.
Namespaces do not map to a D-Bus interface.

# Methods, Signals and Properties

Methods may only be placed within interface declarations as they form part of the interface.
In the preceding example regarding interfaces you may have noticed the rather strange
syntax for declaring a method. Methods are not declared as they would be in 'C' or
CORBA IDL, but in a manner more similar to a 'C' structure. This is because D-Bus is
a message passing system, that can have multiple return values as well as inputs.

        namespace org.dbuf
                interface AnInterface {
                        method FooBar {
                                int16 first;
                        } reply {
                                int16 rfirst;
                                int16 rsecond;
                        }
                }
        }

Here you can see how the return type, or reply message, is specified. This simple example
would be far more cumbersome in CORBA IDL

        int16 FooBar (in int16 first, out int16 rsecond);

Event thogh `rsecond` is a reply value it would be places in the 'input' parameters with the
`out` modifiers.

## Signals

Signals are declared in a manner very similar to methods.

        interface org.dbuf.AnInterface {
                signal ASignal {
                        int16 first;
                        int16 second;
                }
        }

It is not possible to add a `reply` clause to a signal, as they have no return parameters.

## Properties

        interface org.dbuf.AnInterface {
                read property int16 AReadableProperty;
                read property int16 AWriteableProperty;
                readwrite property int16 AReadableWriteableProperty;
                property int16 AnotherReadableWriteableProperty;
        }

Properties are declared using the `property` keyword. They can also use the modifiers `read`,
`write` and `readwrite`. These match the 'direction' strings in D-Bus XML. A property without
modifiers is assumed to be `readwrite`.

# Basic Types

So far the examples have shown the use of only one type; `int16`. dbuf can use all of
the basic D-Bus types. These are:

        boolean
        double
        string
        object
        signature
        variant
        byte
        int16
        uint16
        int32
        uint32
        int64
        uint64

## Arrays

In addition to the basic types it is also possible to construct arrays of types.

        interface org.dbuf.Test {
                method AMethod {
                        int32[][] arrayOf;
                }
        }

This would be translated into the following D-Bus XML:

        <interface name="org.dbuf.Test">
                <method name="AMethod">
                        <arg name="arrayOf", type="aai"/>
                </method>
        </interface>

Note that the signature is indicating an array of arrays of int32.

## Dictionaries

The `dict` type is used to represent an array of the D-Bus type, dict-entry.

        interface org.dbuf.Test {
                method AMethod {
                        dict <int32, int32> dictOf;
                }
        }

Dictionaries must have a type for both the key and value. The type for the
key is specifed first between the angle brackets, followed by the type
of the values.

# Compound Types

## Struct

        namespace org.dbuf.test {
                struct AStruct {
                        int16 foo;
                        int32 bar;
                }
        }

Structs declare a new type in dbuf. This type may then be used elsewhere
in multiple locations. For example, say you regularly use rectangles
in your interface, you could create a rectangle struct to use in multiple
messages and interfaces.

        namespace org.dbuf.test {
                struct Rectangle {
                        int32 x;
                        int32 y;
                        uint32 a;
                        uint32 b;
                }

                interface RProp {
                        method setRect {
                                Rectangle r;
                        }

                        method getRect reply {
                                Rectangle r;
                        }
                }

## Enumerations

Enumerations are not part of D-Bus but are included in dbuf as they
are used regularly in all languages and serve to describe interfaces
very well. As no enumerations exist in D-Bus it is neccessary to provide
a D-Bus type that will be used to pass the enumeration.

        namespace org.dbuf.test {
                enum <int16> AnEnum {
                        ONE = 1,
                        TWO,
                        THREE,
                        FOUR,
                }
        }

Enumerations also declare a type within dbuf.

## Typedefs

Sometimes it is neccessary to provide a synonym for an existing type
to better describe an interface. For this it is possible to use the `typedef`
declaration in dbuf.

        namespace org.dbuf.test {
                typedef int16 State;
                typedef State[] StateSet;
        }

Type declarations are allowed in both namespaces and interfaces.

# Importing types

It is possible to use types declared in other namespaces or interfaces by
importing them using the `using` keyword.

        namespace org.dbuf.test {
                typedef int16 State;

                interface AnInterface {
                        using org.dbuf.test;
                        method setState {
                                State state;
                        }
                }
        }

There are two forms of the `using` keyword.

        using <namespace or interface>;

This imports all the types declared in the namespace or interface. It does
not import the sub-namespaces or interfaces. They must be imported separately
and explicity.

        using <type> = <identifier>;

This makes the named type available as a simple identifer.

The dbuf source includes many examples in the `test/data/` directory. This includes
the translation of a large and complex D-Bus interface, the AT-SPI accessibility protocol.

To translate between dbuf and D-Bus XML use the tool `dbuftodbusxml`. This accepts multiple
dbuf files and can output all the found interfaces or only the ones that are specified.

        > dbuftodbusxml -i org.dbuf.test testone.dbuf testtwo.dbuf

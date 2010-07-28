testxml = \
"""
group testxml;

pass (st) ::=
<<
<st>
>>

idl (body) ::=
<<
\<idl>
        <body; separator="\n">
\</idl\>
>>

namespace (name, body) ::=
<<
\<namespace name="<name>"\>
        <body; separator="\n">
\</namespace\>
>>

interface (name, body) ::=
<<
\<interface name="<name>"\>
        <body; separator="\n">
\</interface\>
>>

using (name) ::=
<<
\<using name="<name>"/\>
>>

alias (name, id) ::=
<<
\<alias name="<name>" id="<id>"/\>
>>

/* Messages templates */
/* ----------------------------------------------------------------------------------- */

method (id, in, out, throw) ::=
<<
\<method name="<id>"\>
        <if (in)>
        \<in\>
                <in; separator="\n">
        \</in\>
        <endif>
        <if (out)>
        \<out\>
                <out; separator="\n">
        \</out\>
        <endif>
        <if (throw)>
        \<throws\>
                <throw:{\<error name="<it>"/\>}; separator="\n">
        \</throws\>
        <endif>
\</method\>
>>

signal (id, member) ::=
<<
\<signal name="<id>"\>
        <member; separator="\n">
\</signal\>
>>

error (id, member) ::=
<<
\<error name="<id>"\>
        <member; separator="\n">
\</error\>
>>

property (id, type, modifier) ::=
<<
\<property name="<id>"<if(modifier)> modifier="<modifier>"<endif>\>
        <type>
\</property\>
>>

/* Type templates */
/* ----------------------------------------------------------------------------------- */

primitiveTypeMap ::= [
        "byte":"byte",
        "boolean":"boolean",
        "int16":"int16",
        "uint16":"uint16",
        "int32":"int32",
        "uint32":"uint32",
        "int64":"int64",
        "uint64":"uint64",
        "double":"double",
        "string":"string",
        "object":"object",
        "signature":"signature",
        "variant":"variant",
        default:"null"
]

primitive (type) ::=
<<
\<basic type="<primitiveTypeMap.(type)>"/\>
>>

compound (id) ::=
<<
\<compound name="<id>"/\>
>>

array (type) ::=
<<
\<array\>
        <type>
\</array\>
>>

dict (primitive, type) ::=
<<
\<dict\>
        \<key\>
                \<basic type="<primitiveTypeMap.(primitive)>"/\>
        \</key\>
        \<value\>
                <type>
        \</value\>
\</dict\>
>>

typedef (id, type) ::=
<<
\<typedef name="<id>"\>
        <type>
\</typedef\>
>>

/* Structs & Emumerations */
/* ----------------------------------------------------------------------------------- */

enum (type, id, member) ::=
<<
\<enum name="<id>" type="<type>"\>
        <member; separator="\n">
\</enum\>
>>

constant (id, integer) ::=
<<
\<member name="<id>"<if (integer)> constant="<integer>"<endif>/\>
>>


struct (id, member) ::=
<<
\<struct name="<id>"\>
        <member; separator="\n">
\</struct\>
>>

member (id, type) ::=
<<
\<member name="<id>"\>
        <type>
\</member\>
>>

/* Names & Identifiers */
/* ----------------------------------------------------------------------------------- */
"""

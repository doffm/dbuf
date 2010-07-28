dbusxml = \
"""
group dbusxml;

pass (st) ::=
<<
<st>
>>

dbusxml (interfaces) ::=
<<
\<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object Introspection 1.0//EN"
         "http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd"\>
\<node name="/"\>
        <interfaces; separator="\n\n">
\</node\>
>>

interface (name, body) ::=
<<
\<interface name="<name>"\>
        <body; separator="\n">
\</interface\>
>>

method (id, in, out) ::=
<<
\<method name="<id>"\>
        <in; separator="\n">
        <if (out)>
        <out; separator="\n">
        <endif>
\</method\>
>>

signal (id, member) ::=
<<
\<signal name="<id>"\>
        <member; separator="\n">
\</signal\>
>>

property (id, signature, modifier) ::=
<<
<if (modifier)>
\<property name="<id>" type="<signature>" access="<modifier>"/\>
<else>
\<property name="<id>" type="<signature>" access="readwrite"/\>
<endif>
>>

inmember (id, type) ::=
<<
\<arg name="<id>" type="<type>" direction="in"/\>
>>

outmember (id, type) ::=
<<
\<arg name="<id>" type="<type>" direction="out"/\>
>>

signalmember (id, type) ::=
<<
\<arg name="<id>" type="<type>"/\>
>>
"""

signature = \
"""
group signature;

pass (st) ::=
<<
<st>
>>

primitiveTypeMap ::= [
        "byte":"y",
        "boolean":"b",
        "int16":"n",
        "uint16":"q",
        "int32":"i",
        "uint32":"u",
        "int64":"x",
        "uint64":"t",
        "double":"d",
        "string":"s",
        "object":"o",
        "signature":"g",
        "variant":"v",

        default:""
]
"""

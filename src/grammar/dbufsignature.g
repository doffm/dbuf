tree grammar dbufsignature;

options {
        language = Python;
        tokenVocab = dbuf;
        ASTLabelType = DbufTree;
        output = template;
}

@header {
        import sys
}

signature                               : ( s=type
                                          | s=member
                                          | s=enumDeclaration
                                          | s=structDeclaration
                                          | s=propertyDeclaration
                                          | s=typedef
                                          ) -> pass (st={$s.st})
                                        ;

/* Types */
/* ----------------------------------------------------------------------------------- */

primitiveType                           : integerType
                                        | 'boolean'
                                        | 'double'
                                        | 'string'
                                        | 'object'
                                        | 'signature'
                                        | 'variant'
                                        ;

integerType                             : 'byte'
                                        | 'int16'
                                        | 'uint16'
                                        | 'int32'
                                        | 'uint32'
                                        | 'int64'
                                        | 'uint64'
                                        ;

/* If the type is a primitive type or array the conversion is trivial.
 * If the type is a compound one it needs looking up in the symbol
 * table and itself converting into a signature.
 */
type                                    : ^(TYPE primitiveType)
                                          -> template (type={$primitiveType.text}) "<primitiveTypeMap.(type)>"
                                        | ^(TYPE typeID)
                                          -> pass (st={$typeID.st})
                                        | ^(TYPE ^(ARRAY t=type))
                                          -> template (type={$t.st}) "a<type>"
                                        | ^(TYPE ^(DICT p=primitiveType t=type))
                                          -> template (primitive={$p.text}, type={$t.st}) "a{<primitiveTypeMap.(primitive)><type>}"
                                        ;

typedef                                 : ^(TYPEDEF ID type)
                                          -> pass (st={$type.st})
                                        ;

/* Structs & Enumerations */
/* ----------------------------------------------------------------------------------- */

enumConstant                            : ^(ID INTEGER?)
                                          -> template () ""
                                        ;

enumDeclaration                         : ^(ENUM integerType ID e+=enumConstant+)
                                          -> template (type={$integerType.text}) "<primitiveTypeMap.(type)>"
                                        ;

member                                  : ^(ID type)
                                          -> pass (st={$type.st})
                                        ;

structDeclaration                       : ^(STRUCT ID m+=member+)
                                          -> template (member={$m}) "(<member; separator=\"\">)"
                                        ;

propertyModifier                        : 'read' | 'write' | 'readwrite'
                                        ;

propertyDeclaration                     : ^(PROPERTY ID type propertyModifier?)
                                          -> pass (st={$type.st})
                                        ;

/* Names & Identifiers */
/* ------------------------------------------------------------------------------------ */

typeID                                  : ^(TYPEID ID+)
                                          -> pass (st={$TYPEID.symbol.signature})
                                        ;

/* END -------------------------------------------------------------------------------- */

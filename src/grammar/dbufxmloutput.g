tree grammar dbufxmloutput;

options {
        language = Python;
        tokenVocab = dbuf;
        ASTLabelType = DbufTree;
        output = template;
}

@header {
        import sys
}

interfaceDeclaration                    : ^(INTERFACE n=qualifiedID b+=interfaceBodyDeclarations*)
                                          -> interface (name={$INTERFACE.fqn}, body={$b})
                                        ;

interfaceBodyDeclarations               : methodDeclaration    -> pass (st={$methodDeclaration.st})
                                        | signalDeclaration    -> pass (st={$signalDeclaration.st})
                                        | propertyDeclaration  -> pass (st={$propertyDeclaration.st})
                                        | structDeclaration
                                        | enumDeclaration
                                        | errorDeclaration
                                        | usingDirective
                                        | typedef
                                        ;

usingDirective                          : ^(USING n=qualifiedID)
                                        | ^(ALIAS n=qualifiedID i=ID)
                                        ;

/* Messages */
/* ----------------------------------------------------------------------------------- */

methodDeclaration                       : ^(METHOD ID
                                                  (^(IN i+=member+))?
                                                  (^(OUT o+=outmember+))?
                                                  (^(THROWS t+=qualifiedID+))?
                                           )
                                          -> method (id={$ID.text}, in={$i}, out={$o})
                                        ;

signalDeclaration                       : ^(SIGNAL ID m+=signalmember+)
                                          -> signal (id={$ID.text}, member={$m})
                                        ;

errorDeclaration                        : ^(ERROR ID m+=member+)
                                        ;

propertyModifier                        : 'read' | 'write' | 'readwrite'
                                        ;

propertyDeclaration                     : ^(PROPERTY ID type propertyModifier?)
                                          -> property (id={$ID.text}, signature={$type.tree.signature}, modifier={$propertyModifier.text})
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

type returns [signature]
@after {
        $type.tree = $m
}
                                          : ^(m=TYPE primitiveType)
                                          | ^(m=TYPE typeID)
                                          | ^(m=TYPE ^(DICT p=primitiveType t=type))
                                          | ^(m=TYPE ^(ARRAY t=type))
                                        ;

typedef                                 : ^(TYPEDEF ID type)
                                        ;

/* Structs & Enumerations */
/* ----------------------------------------------------------------------------------- */

enumConstant                            : ^(ID INTEGER?)
                                        ;

enumDeclaration                         : ^(ENUM integerType ID e+=enumConstant+)
                                        ;

member                                  : ^(ID type)
                                          -> inmember (id={$ID.text}, type={$type.tree.signature})
                                        ;

outmember                               : ^(ID type)
                                          -> outmember (id={$ID.text}, type={$type.tree.signature})
                                        ;

signalmember                            : ^(ID type)
                                          -> signalmember (id={$ID.text}, type={$type.tree.signature})
                                        ;

structDeclaration                       : ^(STRUCT ID m+=member+)
                                        ;

/* Names & Identifiers */
/* ------------------------------------------------------------------------------------ */

qualifiedID                             : ^(QUALIFIED ID+)
                                        ;

typeID                                  : ^(TYPEID ID+)
                                        ;
/* END -------------------------------------------------------------------------------- */

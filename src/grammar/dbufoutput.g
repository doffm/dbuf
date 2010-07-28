tree grammar dbufoutput;

options {
        language = Python;
        tokenVocab = dbuf;
        ASTLabelType = DbufTree;
        output = template;
}

@header {
        import sys
}

idl                                     : b+=idlBodyDeclarations+
                                          -> idl (body={$b})
                                        ;

idlBodyDeclarations                     : interfaceDeclaration -> pass (st={$interfaceDeclaration.st})
                                        | namespaceDeclaration -> pass (st={$namespaceDeclaration.st})
                                        | usingDirective       -> pass (st={$usingDirective.st})
                                        ;

namespaceDeclaration                    : ^(NAMESPACE n=qualifiedID b+=namespaceBodyDeclarations*)
                                          -> namespace (name={$n.text}, body={$b})
                                        ;

namespaceBodyDeclarations               : namespaceDeclaration -> pass (st={$namespaceDeclaration.st})
                                        | interfaceDeclaration -> pass (st={$interfaceDeclaration.st})
                                        | structDeclaration    -> pass (st={$structDeclaration.st})
                                        | enumDeclaration      -> pass (st={$enumDeclaration.st})
                                        | errorDeclaration     -> pass (st={$errorDeclaration.st})
                                        | usingDirective       -> pass (st={$usingDirective.st})
                                        | typedef              -> pass (st={$typedef.st})
                                        ;

interfaceDeclaration                    : ^(INTERFACE n=qualifiedID b+=interfaceBodyDeclarations*)
                                          -> interface (name={$n.text}, body={$b})
                                        ;

interfaceBodyDeclarations               : structDeclaration    -> pass (st={$structDeclaration.st})
                                        | enumDeclaration      -> pass (st={$enumDeclaration.st})
                                        | methodDeclaration    -> pass (st={$methodDeclaration.st})
                                        | signalDeclaration    -> pass (st={$signalDeclaration.st})
                                        | errorDeclaration     -> pass (st={$errorDeclaration.st})
                                        | propertyDeclaration  -> pass (st={$propertyDeclaration.st})
                                        | usingDirective       -> pass (st={$usingDirective.st})
                                        | typedef              -> pass (st={$typedef.st})
                                        ;

usingDirective                          : ^(USING n=qualifiedID) -> using (name={$n.text})
                                        | ^(ALIAS n=qualifiedID i=ID) -> alias (name={$n.st}, id={$i.text})
                                        ;

/* Messages */
/* ----------------------------------------------------------------------------------- */

methodDeclaration                       : ^(METHOD ID
                                                  (^(IN i+=member+))?
                                                  (^(OUT o+=member+))?
                                                  (^(THROWS t+=qualifiedID+))?
                                           )
                                          -> method (id={$ID.text}, in={$i}, out={$o}, throw={$t})
                                        ;

signalDeclaration                       : ^(SIGNAL ID m+=member+)
                                          -> signal (id={$ID.text}, member={$m})
                                        ;

errorDeclaration                        : ^(ERROR ID m+=member+)
                                          -> error (id={$ID.text}, member={$m})
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

type                                    : ^(m=TYPE typeID)                         -> compound (id={$typeID.st})
                                        | ^(m=TYPE primitiveType)                  -> primitive (type={$primitiveType.text})
                                        | ^(m=TYPE ^(ARRAY t=type))                -> array (type={$t.st})
                                        | ^(m=TYPE ^(DICT p=primitiveType t=type)) -> dict (primitive={$p.text}, type={$t.st})
                                        ;

typedef                                 : ^(TYPEDEF ID type) -> typedef (id={$ID.text}, type={$type.st})
                                        ;

/* Structs & Enumerations */
/* ----------------------------------------------------------------------------------- */

enumConstant                            : ^(ID INTEGER?)
                                          -> constant (id={$ID.text}, integer={$INTEGER})
                                        ;

enumDeclaration                         : ^(ENUM integerType ID e+=enumConstant+)
                                          -> enum (type={$integerType.text}, id={$ID.text}, member={$e})
                                        ;

member                                  : ^(ID type)
                                          -> member (id={$ID.text}, type={$type.st})
                                        ;

structDeclaration                       : ^(STRUCT ID m+=member+)
                                          -> struct (id={$ID.text}, member={$m})
                                        ;

propertyModifier                        : 'read' | 'write' | 'readwrite'
                                        ;

propertyDeclaration                     : ^(PROPERTY ID type propertyModifier?)
                                          -> property (id={$ID.text}, type={$type.st}, modifier={$propertyModifier.text})
                                        ;

/* Names & Identifiers */
/* ------------------------------------------------------------------------------------ */

qualifiedID                             : ^(QUALIFIED ID+)
                                          -> template (id={$QUALIFIED.joined}) "<id>"
                                        ;

typeID                                  : ^(TYPEID ID+)
                                          -> template (id={$TYPEID.canonical}) "<id>"
                                        ;
/* END -------------------------------------------------------------------------------- */

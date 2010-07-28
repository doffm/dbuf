tree grammar dbuflink;

options {
        language = Python;
        tokenVocab = dbuf;
        ASTLabelType = DbufTree;
        output = template;
}

@header {
        from util import *
        from symbols import *
        from node import DbufTree
}

idl[allSymbols]
scope {
        symbols;
        namespace;
        directive;
}
@init {
        $idl::symbols   = $idl.allSymbols

        $idl::namespace = ScopedString ()
        $idl::directive = ScopedList ()
}
                                        : b+=idlBodyDeclarations+
                                        ;

idlBodyDeclarations                     : interfaceDeclaration
                                        | namespaceDeclaration
                                        | usingDirective
                                        ;

namespaceDeclaration
@init  {$idl::directive.push();}
@after {$idl::directive.pop();$idl::namespace.pop()}
                                        : ^(NAMESPACE qualifiedID {$idl::namespace.push ($qualifiedID.joined)}
                                            b+=namespaceBodyDeclarations*)
                                        ;

namespaceBodyDeclarations               : namespaceDeclaration
                                        | interfaceDeclaration
                                        | structDeclaration
                                        | enumDeclaration
                                        | errorDeclaration
                                        | usingDirective
                                        | typedef
                                        ;

interfaceDeclaration
@init  {$idl::directive.push();}
@after {$idl::directive.pop();$idl::namespace.pop()}
                                        : ^(INTERFACE qualifiedID {$idl::namespace.push ($qualifiedID.joined)}
                                            b+=interfaceBodyDeclarations*)
                                        ;

interfaceBodyDeclarations               : structDeclaration
                                        | enumDeclaration
                                        | methodDeclaration
                                        | signalDeclaration
                                        | errorDeclaration
                                        | propertyDeclaration
                                        | usingDirective
                                        | typedef
                                        ;

usingDirective                          : ^(USING qualifiedID)
                                          {
                                            $idl::directive.append ($qualifiedID.joined)
                                          }
                                        | ^(ALIAS qualifiedID ID)
                                        ;

/* Messages */
/* ----------------------------------------------------------------------------------- */

methodDeclaration                       : ^(METHOD ID
                                                  (^(IN i+=member+))?
                                                  (^(OUT o+=member+))?
                                                  (^(THROWS t+=qualifiedID+))?
                                           )
                                        ;

signalDeclaration                       : ^(SIGNAL ID m+=member+)
                                        ;

errorDeclaration                        : ^(ERROR ID m+=member+)
                                        ;

propertyModifier                        : 'read' | 'write' | 'readwrite'
                                        ;

propertyDeclaration                     : ^(PROPERTY ID type propertyModifier?)
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

type                                    : ^(TYPE typeID)
                                        | ^(TYPE primitiveType)
                                        | ^(TYPE ^(ARRAY type))
                                        | ^(TYPE ^(DICT primitiveType type))
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
                                        ;

structDeclaration                       : ^(STRUCT ID m+=member+)
                                        ;

/* Names & Identifiers */
/* ------------------------------------------------------------------------------------ */

qualifiedID returns [joined]            :^(QUALIFIED ID+)
                                          {$qualifiedID.joined = $QUALIFIED.joined}
                                        ;

typeID                                  : ^(TYPEID ID+)
                                          {
                                            $TYPEID.symbol = $idl::symbols.resolve ($TYPEID,
                                                                                    $idl::directive,
                                                                                    $idl::namespace,
                                                                                    $TYPEID.canonical)
                                          }
                                        ;

/* END -------------------------------------------------------------------------------- */

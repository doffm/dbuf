grammar dbuf;

options {
        language = Python;
        output = AST;
        ASTLabelType = DbufTree;
}

tokens
{
        NAMESPACE = 'namespace';
        INTERFACE = 'interface';

        USING     = 'using' ;

        STRUCT    = 'struct'  ;
        ENUM      = 'enum'    ;
        AS        = 'as'      ;

        METHOD    = 'method'  ;
        REPLY     = 'reply'   ;
        THROWS    = 'throws'  ;
        SIGNAL    = 'signal'  ;
        ERROR     = 'error'   ;
        PROPERTY  = 'property';
        DICT      = 'dict'    ;
        TYPEDEF   = 'typedef' ;

        /* Imaginary token for the using alias directive */
        ALIAS;

        /* Imaginary tokens for gathering method & reply fields and the throws spec */
        IN;
        OUT;

        /* Imaginary token for holding a qualified identifier */
        QUALIFIED;

        /* Imaginary token representing either a primitive or complext type. */
        TYPE;

        /* Imaginary token for holding a type identifier */
        TYPEID;

        /* Imaginary token specifying an array type */
        ARRAY;
}

@header {
        import string

        from util import *
        from symbols import *
        from node import DbufTree
}

@members {
        parsingErrors = False;

        def setSourceFile (self, sourcefile):
                self.sourcefile = sourcefile

        def getErrorMessage (self, *args, **kwargs):
                self.parsingErrors = True;
                msg = BaseRecognizer.getErrorMessage (self, *args, **kwargs)
                return ("In file " + self.sourcefile + ": " + msg)
}

/* Namespaces & Interfaces */
/* ----------------------------------------------------------------------------------- */

idl [tokenStream] returns [definedSymbols]
scope {
        defined;
        namespace;
        alias;
        tokens;
}
@init {
        $idl::defined    = SymbolStash ()

        $idl::namespace  = ScopedString ()
        $idl::alias      = ScopedDict ()

        $idl::tokens     = $idl.tokenStream
}
                                        : idlBodyDeclarations+
                                          {$idl.definedSymbols = $idl::defined}
                                        ;

idlBodyDeclarations                     : interfaceDeclaration
                                        | namespaceDeclaration
                                        | usingDirective
                                        ;

namespaceDeclaration
@init  {$idl::alias.push();}
@after {$idl::alias.pop (); $idl::namespace.pop()}
                                        : NAMESPACE qualifiedID {$idl::namespace.push ($qualifiedID.tree.joined)}
                                          '{'
                                                namespaceBodyDeclarations*
                                          '}'
                                          -> ^(NAMESPACE qualifiedID namespaceBodyDeclarations*)
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
@init  {$idl::alias.push();}
@after {
        $idl::alias.pop (); $idl::namespace.pop();

        $interfaceDeclaration.tree.tokens = $idl::tokens
        $idl::defined.define ($idl::namespace, $q.tree.joined, $interfaceDeclaration.tree)
}
                                        : INTERFACE q=qualifiedID {$idl::namespace.push ($qualifiedID.tree.joined)}
                                          '{'
                                               interfaceBodyDeclarations*
                                          '}'
                                          -> ^(INTERFACE qualifiedID interfaceBodyDeclarations*)
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

usingDirective                          : USING n=qualifiedID ';'
                                          -> ^(USING qualifiedID)
                                        | u=USING ID '=' qualifiedID ';'
                                          {$idl::alias[$ID.text] = $qualifiedID.tree.joined}
                                          -> ^(ALIAS[$u, 'using'] qualifiedID ID)
                                        ;

/* Messages */
/* ----------------------------------------------------------------------------------- */

methodDeclaration
@after {
        $methodDeclaration.tree.tokens = $idl::tokens
        $idl::defined.define ($idl::namespace, $i.text, $methodDeclaration.tree)
}
                                        : METHOD i=ID
                                          ('{'
                                              m=memberList
                                          '}')?
                                          (REPLY
                                          '{'
                                              r=memberList
                                          '}')?
                                          (THROWS t='(' qualifiedID (',' qualifiedID)* ','?')')?
                                          ';'?
                                          -> ^(METHOD ID
                                                  ^(IN[$m.start, 'in'] $m)?
                                                  ^(OUT[$r.start, 'out'] $r)?
                                                  ^(THROWS[$t, 'throws'] qualifiedID*)?
                                              )
                                        ;

signalDeclaration
@after {
        $signalDeclaration.tree.tokens = $idl::tokens
        $idl::defined.define ($idl::namespace, $i.text, $signalDeclaration.tree)
}
                                        : SIGNAL i=ID
                                          '{'
                                              memberList
                                          '}' ';'?
                                          -> ^(SIGNAL ID memberList)
                                        ;

errorDeclaration
@after {
        $errorDeclaration.tree.tokens = $idl::tokens
        $idl::defined.define ($idl::namespace, $i.text, $errorDeclaration.tree)
}
                                        : ERROR i=ID
                                          '{'
                                              memberList
                                          '}' ';'?
                                          -> ^(ERROR ID memberList)
                                        ;

propertyModifier                        : 'read' | 'write' | 'readwrite'
                                        ;

propertyDeclaration                     : propertyModifier? PROPERTY type ID ';'?
                                          -> ^(PROPERTY ID type propertyModifier?)
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

/*
   This rather convoluted grammar rule is to aid the AST rewrite.
   The AST rewrite rule references the previous rule AST which
   must be created using a rewrite rule on the basic type.

   int16[][] a -> a (array (array int16))
 */
type
@after
{
        $type.tree.tokens = $idl::tokens
}
                                        : ( p=primitiveType -> ^(TYPE[$p.start, "type"] primitiveType)
                                          | d=dict          -> ^(TYPE[$d.start, "type"] dict)
                                          | t=typeID        -> ^(TYPE[$t.start, "type"] typeID)
                                          ) {$type.tree.tokens = $idl::tokens}
                                          (a=array -> ^(TYPE[$a.start, "type"] ^(array $type)))*
                                        ;

array                                   : w='[' ']'
                                          -> ARRAY[$w, 'array']
                                        ;

dict                                    : DICT '<' primitiveType ',' type '>'
                                          -> ^(DICT primitiveType type)
                                        ;

typedef
@after {
        $typedef.tree.tokens = $idl::tokens
        $idl::defined.define ($idl::namespace, $i.text, $typedef.tree)
}
                                        : TYPEDEF type i=ID ';'
                                          -> ^(TYPEDEF ID type)
                                        ;

/* Structs & Enumerations */
/* ----------------------------------------------------------------------------------- */

enumConstant                            : ID ('=' INTEGER)?
                                          -> ^(ID INTEGER?)
                                        ;

enumDeclaration
@after {
        $enumDeclaration.tree.tokens = $idl::tokens
        $idl::defined.define ($idl::namespace, $i.text, $enumDeclaration.tree)
}
                                        : ENUM '<' integerType '>' i=ID
                                          '{'
                                               enumConstant (',' enumConstant)* ','?
                                          '}' ';'?
                                          -> ^(ENUM integerType ID enumConstant+)
                                        ;

member                                  : type ID
                                          -> ^(ID type)
                                        ;

memberList                              : (member ';'!)+
                                        ;

structDeclaration
@after {
        $structDeclaration.tree.tokens = $idl::tokens
        $idl::defined.define ($idl::namespace, $i.text, $structDeclaration.tree)
}
                                        : STRUCT i=ID
                                          '{'
                                              memberList
                                          '}' ';'?
                                          -> ^(STRUCT ID memberList)
                                        ;

/* Names & Identifiers */
/* ------------------------------------------------------------------------------------ */

/*
 * Syntactially these are the same, but they appear to have enough differences
 * in use that it made sense to separate them as to provide each with a
 * different AST node.
 */

qualifiedID
@after {
        $qualifiedID.tree.joined = makeJoined ($f, $r)
}
                                        : f=ID ('.' r+=ID)*
                                          -> ^(QUALIFIED[$f, "qualified"] ID+)
                                        ;

typeID
@after {
        $typeID.tree.canonical = makeCanonical ($idl::alias, $f, $r)
}
                                        : f=ID ('.' r+=ID)*
                                          -> ^(TYPEID[$f, "typeid"] ID+)
                                        ;

/* Lexer rules */
/* ------------------------------------------------------------------------------------ */

fragment LETTER                         : 'A'..'Z'
                                        | 'a'..'z'
                                        | '_'
                                        ;

fragment DIGIT                          : '0'..'9' ;

/* Non-greedy is default for the '.' character */
COMMENT                                 : '/*' .* '*/' {$channel = HIDDEN} ;

LINE_COMMENT                            : '//' ~('\n' | '\r')* ('\r\n' | '\r' | '\n')
                                          {$channel = HIDDEN}
                                        ;

ID                                      : LETTER (LETTER | DIGIT)* ;

INTEGER                                 : DIGIT+ ;

WHITESPACE                              : ( '\t' | ' ' | '\r' | '\n'| '\u000C' )+ {$channel = HIDDEN} ;

/* END -------------------------------------------------------------------------------- */

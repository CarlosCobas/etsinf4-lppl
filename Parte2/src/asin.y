%{
    #include <stdio.h>
    #include "libtds.h"
    #include "header.h"
%}

%union {
    char* ident;
    int cent;
    int type;
//    EXP exp;
}


%token OPSUMA_ OPRESTA_ OPMULT_ OPDIV_ OPMOD_ OPAND_ OPOR_ OPNOT_ OPINCREMENTO_ OPDECREMENTO_
%token COMPMAYOR_ COMPMENOR_ COMPMAYORIG_ COMPMENORIG_ OPIGUAL_ OPNOTIGUAL_
%token IGUAL_   MASIGUAL_   MENOSIGUAL_ PORIGUAL_   DIVIGUAL_
%token WHILE_   DO_   IF_   ELSEIF_     ELSE_
%token <cent> INT_     BOOL_
%token READ_    PRINT_
%token <cent> CTE_
%token <ident> ID_
%token TRUE_   FALSE_
%token LLAVE1_  LLAVE2_ PARENTESIS1_ PARENTESIS2_ CORCHETE1_ CORCHETE2_ SEMICOLON_

%type <cent> tipo_simple
%type <cent> operador_asignacion operador_logico operador_igualdad operador_relacional
%type <cent> operador_aditivo operador_multiplicativo operador_unario operador_incremento

%type <exp> expresion expresion_logica expresion_igualdad expresion_relacional
%type <exp> expresion_aditiva expresion_multiplicativa expresion_unaria expresion_sufija

%%

programa
    : LLAVE1_ secuencia_sentencias LLAVE2_
    ;

secuencia_sentencias
    : sentencia
    | secuencia_sentencias sentencia
    ;

sentencia
    : declaracion
    | instruccion
    ;

declaracion
    : tipo_simple ID_ SEMICOLON_
        { if (!insertarTDS($2, $1, dvar, -1))
            yyerror("Identificador repetido");
        else
            dvar += TALLA_TIPO_SIMPLE; }
    | tipo_simple ID_ CORCHETE1_ CTE_ CORCHETE2_ SEMICOLON_
        { int numelem = $4; int ref;
        if (numelem <= 0) {
            yyerror("Talla inapropiada del array");
            numelem = 0;
        }
        ref = insertaTDArray($1, numelem);
        if (!insertarTDS($2, T_ARRAY, dvar, ref))
            yyerror("Identificador repetido");
        else
            dvar += numelem * TALLA_TIPO_SIMPLE; }
    ;

tipo_simple
    : INT_  { $$ = T_ENTERO; }
    | BOOL_ { $$ = T_LOGICO; }
    ;

instruccion
    : LLAVE1_ lista_instrucciones LLAVE2_
    | instruccion_entrada_salida
    | instruccion_expresion
    | instruccion_seleccion
    | instruccion_iteracion
    ;

lista_instrucciones
    : lista_instrucciones instruccion
    | /* instruccion vacia */
    ;

instruccion_expresion
    : expresion SEMICOLON_
    | SEMICOLON_
    ;

instruccion_entrada_salida
    : READ_  PARENTESIS1_ ID_       PARENTESIS2_ SEMICOLON_
    | PRINT_ PARENTESIS1_ expresion PARENTESIS2_ SEMICOLON_
    ;

instruccion_seleccion
    : IF_ PARENTESIS1_ expresion PARENTESIS2_ instruccion resto_if
        { if ($3.tipo != T_LOGICO) yyerror("La expresion debe ser booleana"); }
    ;

resto_if
    : ELSEIF_ PARENTESIS1_ expresion PARENTESIS2_ instruccion resto_if
        { if ($3.tipo != T_LOGICO) yyerror("La expresion debe ser booleana"); }
    | ELSE_ instruccion
    ;

instruccion_iteracion
    : WHILE_ PARENTESIS1_ expresion PARENTESIS2_ instruccion
        { if ($3.tipo != T_LOGICO) yyerror("La expresion debe ser booleana"); }
    | DO_ instruccion WHILE_ PARENTESIS1_ expresion PARENTESIS2_
        { if ($5.tipo != T_LOGICO) yyerror("La expresion debe ser booleana"); }
    ;

expresion
    : expresion_logica { $$.tipo = $1.tipo; }
    | ID_ operador_asignacion expresion
        { $$.tipo = T_ERROR;
        // TODO: elegir si guardar el valor (teniendo en cuenta que si hay
        //  acceso a variables el valor es desconocido) o ignorarlo (no habra
        //  informacion para indice de vectores)
        if ($3.tipo != T_ERROR) {
            SIMB simb = obtenerTDS($1);
            if (simb.tipo == T_ERROR) {
                yyerror("Variable no declarada");
            } else if (simb.tipo == T_ARRAY) {
                yyerror("Acceso incorrecto a array");
            } else if (simb.tipo != $3.tipo) {
                yyerror("Tipos no coinciden");
            } else {
                $$.tipo = simb.tipo;
            }
        } }
    | ID_ CORCHETE1_ expresion CORCHETE2_ operador_asignacion expresion
        { $$.tipo = T_ERROR;
        if ($3 != T_ERROR && $6 != T_ERROR) {
            SIMB simb = obtenerTDS($1);
            if (simb.tipo == T_ERROR) {
                yyerror("Variable no declarada");
            } else if (simb.tipo != T_ARRAY) {
                yyerror("El identificador no corresponde a un array");
            } else if ($3.tipo != T_ENTERO) {
                yyerror("El indice debe ser un entero");
            } else {
                DIM dim = obtenerInfoArray(simb.ref);
                if (dim.telem != $6.tipo) {
                    yyerror("Tipos no coinciden");
//                } else if ($3.valor < 0 || $3.valor >= dim.nelem) {
//                    yyerror("Indice invalido");
                } else {
                    $$.tipo = dim.telem;
                }
            }
        } }
    ;

expresion_logica
    : expresion_igualdad { $$.tipo = $1.tipo; }
    | expresion_logica operador_logico expresion_igualdad
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo)
                yyerror("Tipos no coinciden");
            else if ($1.tipo != T_LOGICO)
                yyerror("Operacion logica invalida para no booleanos");
            else
                $$.tipo = T_LOGICO;
        } }
    ;

expresion_igualdad
    : expresion_relacional { $$.tipo = $1.tipo; }
    | expresion_igualdad operador_igualdad expresion_relacional
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo)
                yyerror("Tipos no coinciden");
            else if ($1.tipo == T_ARRAY)
                yyerror("Tipo array incorrecto");
            else
                $$.tipo = T_LOGICO;
        } }
    ;

expresion_relacional
    : expresion_aditiva { $$.tipo = $1.tipo; }
    | expresion_relacional operador_relacional expresion_aditiva
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo)
                yyerror("Tipos no coinciden");
            else if ($1.tipo != T_ENTERO)
                yyerror("Operacion relacional invalida para no enteros");
            else
                $$.tipo = T_LOGICO;
        } }
    ;

expresion_aditiva
    : expresion_multiplicativa { $$.tipo = $1.tipo; }
    | expresion_aditiva operador_aditivo expresion_multiplicativa
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo)
                yyerror("Tipos no coinciden");
            else if ($1.tipo != T_ENTERO)
                yyerror("Operacion aditiva invalida para no enteros");
            else
                $$.tipo = T_ENTERO;
        } }
    ;

expresion_multiplicativa
    : expresion_unaria { $$.tipo = $1.tipo; }
    | expresion_multiplicativa operador_multiplicativo expresion_unaria
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo)
                yyerror("Tipos no coinciden");
            else if ($1.tipo != T_ENTERO)
                yyerror("Operacion multiplicativa invalida para no enteros");
            else
                $$.tipo = T_ENTERO;
        } }
    ;

expresion_unaria
    : expresion_sufija { $$.tipo = $1.tipo; }
    | operador_unario expresion_unaria
        { $$.tipo = T_ERROR;
        if ($2.tipo == T_ENTERO) {
            if ($1 == OP_NOT)
                yyerror("Operacion invalida en entero");
            else
                $$.tipo = T_ENTERO;
        } else if ($2.tipo == T_LOGICO) {
            if ($1 != OP_NOT)
                yyerror("Operacion invalida en booleano");
            else
                $$.tipo = T_LOGICO;
        } }
    | operador_incremento ID_
        { SIMB simb = obtenerTDS($1);
        $$.tipo = T_ERROR;
        if (simb.tipo == T_ERROR)
            yyerror("Variable no declarada");
        else if (simb.tipo == T_ARRAY)
            yyerror("Acceso a array sin indice");
        else
            $$.tipo = simb.tipo; }
    ;

expresion_sufija
    : PARENTESIS1_ expresion PARENTESIS2_ { $$.tipo = $2.tipo; }
    | ID_ operador_incremento
        { SIMB simb = obtenerTDS($1);
        $$.tipo = T_ERROR;
        if (simb.tipo == T_ERROR)
            yyerror("Variable no declarada");
        else if (simb.tipo == T_ARRAY)
            yyerror("Acceso a array sin indice");
        else
            $$.tipo = simb.tipo; }
    | ID_ CORCHETE1_ expresion CORCHETE2_
        { SIMB simb = obtenerTDS($1);
        $$.tipo = T_ERROR;
        if (simb.tipo == T_ERROR)
            yyerror("Variable no declarada");
        else if (simb.tipo != T_ARRAY)
            yyerror("Esta variable no es un array");
        else {
            DIM dim = obtenerInfoArray(simb.ref);
            $$.tipo = dim.telem;
        } }
    | ID_
        { SIMB simb = obtenerTDS($1);
        $$.tipo = T_ERROR;
        if (simb.tipo == T_ERROR)
            yyerror("Variable no declarada");
        else if (simb.tipo == T_ARRAY)
            yyerror("Acceso a array sin indice");
        else
            $$.tipo = simb.tipo; }
    | CTE_   { $$.tipo = T_ENTERO; }
    | TRUE_  { $$.tipo = T_LOGICO; }
    | FALSE_ { $$.tipo = T_LOGICO; }
    ;

operador_asignacion
    : IGUAL_      { $$ = OP_ASIG;       }
    | MASIGUAL_   { $$ = OP_ASIG_SUMA;  }
    | MENOSIGUAL_ { $$ = OP_ASIG_RESTA; }
    | PORIGUAL_   { $$ = OP_ASIG_MULT;  }
    | DIVIGUAL_   { $$ = OP_ASIG_DIV;   }
    ;

operador_logico
    : OPAND_ { $$ = OP_AND; }
    | OPOR_  { $$ = OP_OR;  }
    ;

operador_igualdad
    : OPIGUAL_    { $$ = OP_IGUAL;    }
    | OPNOTIGUAL_ { $$ = OP_NOTIGUAL; }
    ;

operador_relacional
    : COMPMAYOR_   { $$ = OP_MAYOR;   }
    | COMPMENOR_   { $$ = OP_MENOR;   }
    | COMPMAYORIG_ { $$ = OP_MAYORIG; }
    | COMPMENORIG_ { $$ = OP_MENORIG; }
    ;

operador_aditivo
    : OPSUMA_  { $$ = OP_SUMA;  }
    | OPRESTA_ { $$ = OP_RESTA; }
    ;

operador_multiplicativo
    : OPMULT_ { $$ = OP_MULT; }
    | OPDIV_  { $$ = OP_DIV;  }
    | OPMOD_  { $$ = OP_MOD;  }
    ;

operador_unario
    : OPSUMA_  { $$ = OP_MAS;   }
    | OPRESTA_ { $$ = OP_MENOS; }
    | OPNOT_   { $$ = OP_NOT;   }
    ;

operador_incremento
    : OPINCREMENTO_ { $$ = OP_INC; }
    | OPDECREMENTO_ { $$ = OP_DEC; }
    ;

%%


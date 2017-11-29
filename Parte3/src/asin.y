%{
    #include <stdio.h>
    #include "libtds.h"
    #include "header.h"
    #include "libgci.h"
%}

%union {
    char* ident;
    int cent;
    EXP exp;
    IF_ELSE_INSTR ifelse_instr;
    WHILE_INSTR while_instr;
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

%type <ifelse_instr> instruccion_seleccion resto_if
%type <while_instr> instruccion_iteracion

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
            yyerror(E_REPEATED_DECLARATION);
        else
            dvar += TALLA_TIPO_SIMPLE; }
    | tipo_simple ID_ CORCHETE1_ CTE_ CORCHETE2_ SEMICOLON_
        { int numelem = $4; int ref;
        if (numelem <= 0) {
            yyerror(E_ARRAY_SIZE_INVALID);
            numelem = 0;
        }
        ref = insertaTDArray($1, numelem);
        if (!insertarTDS($2, T_ARRAY, dvar, ref))
            yyerror(E_REPEATED_DECLARATION);
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
        { SIMB simb = obtenerTDS($3);
        if (simb.tipo == T_ERROR) {
            yyerror(E_UNDECLARED);
        } else if (simb.tipo != T_ENTERO) {
            yyerror("read espera una variable entera");
        }

        emite(EREAD, crArgNul(), crArgNul(), crArgPos(simb.desp)); }
    | PRINT_ PARENTESIS1_ expresion PARENTESIS2_ SEMICOLON_
        { if ($3.tipo != T_ENTERO) {
            yyerror("print espera una variable entera");
        }

        emite(EWRITE, crArgNul(), crArgNul(), crArgPos($3.pos)); }
    ;

instruccion_seleccion
    : IF_ PARENTESIS1_ expresion PARENTESIS2_
        { if ($3.tipo != T_ERROR && $3.tipo != T_LOGICO) yyerror(E_IF_LOGICAL);
        $<ifelse_instr>$.etqElse = creaLans(si);
        emite(EIGUAL, crArgPos($3.pos), crArgEnt(FALSE), crArgEtq($<ifelse_instr>$.etqElse)); }
        instruccion
        { $<ifelse_instr>$.etqEnd = creaLans(si);
        emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<ifelse_instr>$.etqEnd));
        completaLans($<ifelse_instr>$.etqElse, crArgEtq(si)); }
        resto_if { completaLans($$.etqEnd, crArgEtq(si)); }
    ;

resto_if
    : ELSEIF_ PARENTESIS1_ expresion PARENTESIS2_
        { if ($3.tipo != T_ERROR && $3.tipo != T_LOGICO) yyerror(E_IF_LOGICAL);
        $<ifelse_instr>$.etqElse = creaLans(si);
        emite(EIGUAL, crArgPos($3.pos), crArgEnt(FALSE), crArgEtq($<ifelse_instr>$.etqElse)); }
        instruccion
        { $<ifelse_instr>$.etqEnd = creaLans(si);
        emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<ifelse_instr>$.etqEnd));
        completaLans($<ifelse_instr>$.etqElse, crArgEtq(si)); }
        resto_if { completaLans($<ifelse_instr>$.etqEnd, crArgEtq(si)); }
    | ELSE_ instruccion { $$.etqEnd = 0; $$.etqElse = 0; }
    ;

instruccion_iteracion
    : WHILE_ PARENTESIS1_ expresion PARENTESIS2_
        { if ($3.tipo != T_ERROR && $3.tipo != T_LOGICO)
            yyerror(E_WHILE_LOGICAL);
        $<while_instr>$.etqBegin = si;
        $<while_instr>$.etqEnd = creaLans(si);
        emite(EIGUAL, crArgPos($3.pos), crArgEnt(FALSE), crArgEtq($<while_instr>$.etqEnd)); }
        instruccion
        { emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($$.etqBegin));
        completaLans($$.etqEnd, crArgEtq(si)); }
    | DO_ { $<while_instr>$.etqBegin = si; }
        instruccion WHILE_ PARENTESIS1_ expresion PARENTESIS2_
        { if ($<exp>5.tipo != T_ERROR && $<exp>5.tipo != T_LOGICO)
            yyerror(E_WHILE_LOGICAL);
        emite(EIGUAL, crArgPos($<exp>5.pos), crArgEnt(TRUE), crArgEtq($$.etqBegin)); }
    ;

expresion
    : expresion_logica { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.valid = $1.valid; $$.pos = $1.pos; }
    | ID_ operador_asignacion expresion
        { $$.tipo = T_ERROR;
        SIMB simb;
		simb = obtenerTDS($1);
        if ($3.tipo != T_ERROR) {
            if (simb.tipo == T_ERROR) {
                yyerror(E_UNDECLARED);
            } else if (simb.tipo == T_ARRAY) {
                yyerror(E_ARRAY_WO_INDEX);
            } else if (simb.tipo != $3.tipo) {
                yyerror(E_TYPES_ASIGNACION);
            } else {
                $$.tipo = simb.tipo;
                $$.valid = FALSE;
            }
        }

        $$.pos = creaVarTemp(); 
        emite($2, crArgPos(simb.desp), crArgPos($3.pos), crArgPos($$.pos)); 
		emite(EASIG, crArgPos($$.pos),crArgNul(),crArgPos(simb.desp));


		}
    | ID_ CORCHETE1_ expresion CORCHETE2_ operador_asignacion expresion
        { $$.tipo = T_ERROR;
        SIMB simb;
		simb = obtenerTDS($1);
        if ($3.tipo != T_ERROR && $6.tipo != T_ERROR) {
            if (simb.tipo == T_ERROR) {
                yyerror(E_UNDECLARED);
            } else if (simb.tipo != T_ARRAY) {
                yyerror(E_VAR_WITH_INDEX);
            } else if ($3.tipo != T_ENTERO) {
                yyerror(E_ARRAY_INDEX_TYPE);
            } else {
                DIM dim = obtenerInfoArray(simb.ref);
                if (dim.telem != $6.tipo) {
                    yyerror(E_TYPES_ASIGNACION);
                } else if ($3.valid == TRUE && ($3.valor < 0 || $3.valor >= dim.nelem)) {
                    yyerror(E_ARRAY_INDEX_INVALID);
                } else {
                    $$.tipo = dim.telem;
                    $$.valid = FALSE;
                }
            }
        }

		$$.pos = creaVarTemp(); 
		emite(EASIG, crArgPos(simb.desp), crArgPos($3.pos), crArgPos($$.pos)); 
        emite(EVA, crArgPos(simb.desp), crArgPos($3.pos), crArgPos($$.pos)); }
    ;

expresion_logica
    : expresion_igualdad { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.valid = $1.valid; $$.pos = $1.pos; }
    | expresion_logica operador_logico expresion_igualdad
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo) {
                yyerror(E_TYPES_LOGICA);
            } else if ($1.tipo != T_LOGICO) {
                yyerror("Operacion logica invalida para no booleanos");
            } else {
                $$.tipo = T_LOGICO;
                if ($1.valid == TRUE && $3.valid == TRUE) {
                    if ($2 == OP_AND) {
                        $$.valor = FALSE;
                        if ($1.valor == TRUE)
                            if ($3.valor == TRUE)
                                $$.valor = TRUE;
                    } else if ($2 == OP_OR) {
                        $$.valor = TRUE;
                        if ($1.valor == FALSE)
                            if ($3.valor == FALSE)
                                $$.valor = FALSE;
                    }
                    $$.valid = TRUE;
                } else $$.valid = FALSE;
            }
        }

        $$.pos = creaVarTemp();
        int overrideValue;
 		overrideValue= $2 == OP_AND ? FALSE : TRUE;
        emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos($$.pos));
        emite(EIGUAL, crArgPos($1.pos), crArgEnt(overrideValue), crArgEtq(si + 2));
        emite(EASIG, crArgEnt(overrideValue), crArgNul(), crArgPos($$.pos)); }
    ;

expresion_igualdad
    : expresion_relacional { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.valid = $1.valid; $$.pos = $1.pos; }
    | expresion_igualdad operador_igualdad expresion_relacional
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo) {
                yyerror("Tipos no coinciden en operacion de igualdad");
            } else if ($1.tipo == T_ARRAY) {
                yyerror("Operacion de igualdad no existe para arrays");
            } else {
                $$.tipo = T_LOGICO;
                if ($1.valid == TRUE && $3.valid == TRUE) {
                    if ($2 == EIGUAL)
                        $$.valor = $1.valor == $3.valor ? TRUE : FALSE;
                    else if ($2 == EDIST)
                        $$.valor = $1.valor != $3.valor ? TRUE : FALSE;
                    $$.valid = TRUE;
                } else $$.valid = FALSE;
            }
        }

        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt(TRUE), crArgNul(), crArgPos($$.pos));
        emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si + 2));
        emite(EASIG, crArgEnt(FALSE), crArgNul(), crArgPos($$.pos)); }
    ;

expresion_relacional
    : expresion_aditiva { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.valid = $1.valid; $$.pos = $1.pos; }
    | expresion_relacional operador_relacional expresion_aditiva
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo) {
                yyerror("Tipos no coinciden en operacion relacional");
            } else if ($1.tipo == T_LOGICO) {
                yyerror("Operacion relacional solo acepta argumentos enteros");
            } else {
                $$.tipo = T_LOGICO;
                if ($1.valid == TRUE && $3.valid == TRUE) {
                    if ($2 == EMAY)
                        $$.valor = $1.valor > $3.valor ? TRUE : FALSE;
                    else if ($2 == EMEN)
                        $$.valor = $1.valor < $3.valor ? TRUE : FALSE;
                    else if ($2 == EMAYEQ)
                        $$.valor = $1.valor >= $3.valor ? TRUE : FALSE;
                    else if ($2 == EMENEQ)
                        $$.valor = $1.valor <= $3.valor ? TRUE : FALSE;
                    $$.valid = TRUE;
                } else $$.valid = FALSE;
            }
        }

        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt(TRUE), crArgNul(), crArgPos($$.pos));
        emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si + 2));
        emite(EASIG, crArgEnt(FALSE), crArgNul(), crArgPos($$.pos)); }
    ;

expresion_aditiva
    : expresion_multiplicativa { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.valid = $1.valid; $$.pos = $1.pos; }
    | expresion_aditiva operador_aditivo expresion_multiplicativa
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo) {
                yyerror("Tipos no coinciden en operacion aditiva");
            } else if ($1.tipo != T_ENTERO) {
                yyerror("Operacion aditiva solo acepta argumentos enteros");
            } else {
                $$.tipo = T_ENTERO;
                if ($1.valid == TRUE && $3.valid == TRUE) {
                    if ($2 == ESUM)
                        $$.valor = $1.valor + $3.valor;
                    else if ($2 == EDIF)
                        $$.valor = $1.valor - $3.valor;
                    $$.valid = TRUE;
                } else $$.valid = FALSE;
            }
        }

        $$.pos = creaVarTemp();
        emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos)); }
    ;

expresion_multiplicativa
    : expresion_unaria { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.valid = $1.valid; $$.pos = $1.pos; }
    | expresion_multiplicativa operador_multiplicativo expresion_unaria
        { $$.tipo = T_ERROR;
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR) {
            if ($1.tipo != $3.tipo) {
                yyerror("Tipos no coinciden en operacion multiplicativa");
            } else if ($1.tipo != T_ENTERO) {
                yyerror("Operacion multiplicativa solo acepta argumentos enteros");
            } else {
                $$.tipo = T_ENTERO;
                if ($1.valid == TRUE && $3.valid == TRUE) {
                    if ($2 == EMULT)
                        $$.valor = $1.valor * $3.valor;
                    else if ($2 == EDIVI) {
                        if ($3.valor == 0) {
                            $$.tipo = T_ERROR;
                            yyerror("Division entre 0");
                        } else {
                            $$.valor = $1.valor / $3.valor;
                        }
                    } else if ($2 == RESTO) {
                        if ($3.valor == 0) {
                            $$.tipo = T_ERROR;
                            yyerror("Modulo entre 0");
                        } else {
                            $$.valor = $1.valor % $3.valor;
                        }
                    }
                    $$.valid = TRUE;
                } else $$.valid = FALSE;
            }
        }

        $$.pos = creaVarTemp();
        emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos)); }
    ;

expresion_unaria
    : expresion_sufija { $$.tipo = $1.tipo; $$.valor = $1.valor; $$.valid = $1.valid; $$.pos = $1.pos; }
    | operador_unario expresion_unaria
        { $$.tipo = T_ERROR;
        $$.valid = $2.valid;
        if ($2.tipo != T_ERROR) {
            if ($2.tipo == T_ENTERO) {
                if ($1 == OP_NOT) {
                    yyerror("Operacion \"!\" invalida en expresion entera");
                } else if ($2.valid == TRUE) {
                    $$.tipo = T_ENTERO;
                    if ($1 == ESUM) {
                        $$.valor = $2.valor;
                    } else if ($1 == EDIF) {
                        $$.valor = - $2.valor;
                    }
                }
            } else if ($2.tipo == T_LOGICO) {
                if ($1 == OP_NOT) {
                    $$.tipo = T_LOGICO;
                    if ($2.valid == TRUE) {
                        if ($2.valor == TRUE)
                            $$.valor = FALSE;
                        else
                            $$.valor = TRUE;
                    }
                } else {
                    yyerror("Operacion entera invalida en expresion logica");
                }
            }
        }

        $$.pos = creaVarTemp();
        if ($1 == OP_NOT) {
            emite(EDIF, crArgEnt(1), crArgPos($2.pos), crArgPos($$.pos));
        } else {
            emite($1  , crArgEnt(0), crArgPos($2.pos), crArgPos($$.pos));
        } }
    | operador_incremento ID_
        { SIMB simb = obtenerTDS($2);
        $$.tipo = T_ERROR;
        if (simb.tipo == T_ERROR)
            yyerror(E_UNDECLARED);
        else if (simb.tipo == T_ARRAY)
            yyerror(E_ARRAY_WO_INDEX);
        else
            $$.tipo = simb.tipo;
        $$.valid = FALSE;

        $$.pos = creaVarTemp();
        /* Primero se incrementa/decrementa y luego se copia a $$.pos */
        emite($1,    crArgPos(simb.desp), crArgEnt(1), crArgPos(simb.desp));
        emite(EASIG, crArgPos(simb.desp), crArgNul(),  crArgPos($$.pos));
        }
    ;

expresion_sufija
    : PARENTESIS1_ expresion PARENTESIS2_ { $$.tipo = $2.tipo; $$.valor = $2.valor; $$.valid = $2.valid; $$.pos = $2.pos; }
    | ID_ operador_incremento
        { SIMB simb = obtenerTDS($1);
        $$.tipo = T_ERROR;
        $$.valid = FALSE;
        if (simb.tipo == T_ERROR)
            yyerror(E_UNDECLARED);
        else if (simb.tipo == T_ARRAY)
            yyerror(E_ARRAY_WO_INDEX);
        else
            $$.tipo = simb.tipo;

        $$.pos = creaVarTemp();
        /* Primero se copia el valor a $$.pos y luego se incrementa */
        emite(EASIG, crArgPos($$.pos), crArgNul(), crArgPos($$.pos));
        emite($2, crArgPos(simb.desp), crArgEnt(1), crArgPos(simb.desp)); }
    | ID_ CORCHETE1_ expresion CORCHETE2_
        { SIMB simb = obtenerTDS($1);
        $$.tipo = T_ERROR;
        $$.valid = FALSE;
        if (simb.tipo == T_ERROR)
            yyerror(E_UNDECLARED);
        else if (simb.tipo != T_ARRAY)
            yyerror(E_VAR_WITH_INDEX);
        else if ($3.tipo != T_ENTERO)
            yyerror(E_ARRAY_INDEX_TYPE);
        else {
            DIM dim = obtenerInfoArray(simb.ref);
            if ($3.valid == TRUE && ($3.valor < 0 || $3.valor >= dim.nelem)) {
                yyerror(E_ARRAY_INDEX_INVALID);
            } else {
                $$.tipo = dim.telem;
            }
        }

        $$.pos = creaVarTemp();
        emite(EAV, crArgPos(simb.desp), crArgPos($3.pos), crArgPos($$.pos)); }
    | ID_
        { SIMB simb = obtenerTDS($1);
        $$.tipo = T_ERROR;
        $$.valid = FALSE;
        if (simb.tipo == T_ERROR)
            yyerror(E_UNDECLARED);
        else if (simb.tipo == T_ARRAY)
            yyerror(E_ARRAY_WO_INDEX);
        else
            $$.tipo = simb.tipo;

        $$.pos = simb.desp; }
    | CTE_
        { $$.valor = $<cent>1;
        $$.tipo = T_ENTERO;
        $$.valid = TRUE;
        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt($$.valor), crArgNul(), crArgPos($$.pos)); }
    | TRUE_
        { $$.valor = TRUE;
        $$.tipo = T_LOGICO;
        $$.valid = TRUE;
        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt($$.valor), crArgNul(), crArgPos($$.pos)); }
    | FALSE_
        {$$.valor = FALSE;
        $$.tipo = T_LOGICO;
        $$.valid = TRUE;
        $$.pos = creaVarTemp();
        emite(EASIG, crArgEnt($$.valor), crArgNul(), crArgPos($$.pos)); }
    ;

operador_asignacion
    : IGUAL_      { $$ = EASIG; }
    | MASIGUAL_   { $$ = ESUM;  }
    | MENOSIGUAL_ { $$ = EDIF;  }
    | PORIGUAL_   { $$ = EMULT; }
    | DIVIGUAL_   { $$ = EDIVI; }
    ;

operador_logico
    : OPAND_ { $$ = OP_AND; }
    | OPOR_  { $$ = OP_OR;  }
    ;

operador_igualdad
    : OPIGUAL_    { $$ = EIGUAL; }
    | OPNOTIGUAL_ { $$ = EDIST;  }
    ;

operador_relacional
    : COMPMAYOR_   { $$ = EMAY;   }
    | COMPMENOR_   { $$ = EMEN;   }
    | COMPMAYORIG_ { $$ = EMAYEQ; }
    | COMPMENORIG_ { $$ = EMENEQ; }
    ;

operador_aditivo
    : OPSUMA_  { $$ = ESUM; }
    | OPRESTA_ { $$ = EDIF; }
    ;

operador_multiplicativo
    : OPMULT_ { $$ = EMULT; }
    | OPDIV_  { $$ = EDIVI; }
    | OPMOD_  { $$ = RESTO; }
    ;

operador_unario
    : OPSUMA_  { $$ = ESUM;   }
    | OPRESTA_ { $$ = EDIF;   }
    | OPNOT_   { $$ = OP_NOT; }
    ;

operador_incremento
    : OPINCREMENTO_ { $$ = ESUM; }
    | OPDECREMENTO_ { $$ = EDIF; }
    ;
%%


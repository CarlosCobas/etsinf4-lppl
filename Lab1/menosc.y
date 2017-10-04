%{
    #include <stdio.h>
    extern int yylineno;
    extern FILE *yyfile; // TODO: check
%}

%token OPSUMA_  OPRESTA_    OPMULT_     OPDIV_      OPMOD_
%token CMAYOR_  CMENOR_     CMAYORIG_   CMENORIG_   CIGUAL_     CDESIGUAL_
%token BOOLAND_ BOOLOR_     BOOLNOT_
%token IGUAL_   MASIGUAL_   MENOSIGUAL_ PORIGUAL_   DIVIGUAL_
%token WHILE_   IF_         ELSEIF_     ELSE_       DO_
%token INT_     BOOL_
%token READ_    PRINT_
%token CTE_     ID_     TRUE_   FALSE_
%token LLAVE1_  LLAVE2_ BRACK1_ BRACK2_ SQUARE1_ SQUARE2_ SEMIC_
%token EPSILON_

%%

programa: LLAVE1_ secuencia_sentencias LLAVE2_;
secuencia_sentencias: sentencia
                    | secuencia_sentencias sentencia;
sentencia: declaracion
         | instruccion;
declaracion: tipo_simple ID_ SEMIC_
           | tipo_simple ID_ SQUARE1_ CTE_ SQUARE2_ SEMIC_;
tipo_simple: INT_
           | BOOL_;
instruccion: LLAVE1_ lista_instrucciones LLAVE2_
           | instruccion_entrada_salida
           | instruccion_expresion
           | instruccion_seleccion
           | instruccion_iteracion;
lista_instrucciones: lista_instrucciones instruccion
                   | EPSILON_;
instruccion_expresion: expresion SEMIC_
                     | SEMIC_;
instruccion_entrada_salida: READ_  BRACK1_ ID_       BRACK2_ SEMIC_
                          | PRINT_ BRACK1_ expresion BRACK2_ SEMIC_;
instruccion_seleccion: IF_ BRACK1_ expresion BRACK2_ instruccion resto_if;
resto_if: ELSEIF_ BRACK1_ expresion BRACK2_ instruccion resto_if
        | ELSE_ instruccion;
instruccion_iteracion: WHILE_ BRACK1_ expresion BRACK2_ instruccion
                     | DO_ instruccion WHILE_ BRACK1_ expresion BRACK2_;
expresion: expresion_logica
         | ID_                             operador_asignacion expresion
         | ID_ SQUARE1_ expresion SQUARE2_ operador_asignacion expresion;
expresion_logica: expresion_igualdad
                | expresion_logica operador_logico expresion_igualdad;
expresion_igualdad: expresion_relacional
                  | expresion_igualdad operador_igualdad expresion_relacional;
expresion_relacional: expresion_aditiva
                    | expresion_relacional operador_relacional expresion_aditiva;
expresion_aditiva: expresion_multiplicativa
                 | expresion_aditiva operador_aditivo expresion_multiplicativa;
expresion_multiplicativa: expresion_unaria
                        | expresion_multiplicativa operador_multiplicativo expresion_unaria;
expresion_unaria: expresion_sufija
                | operador_unario expresion_unaria
                | operador_incremento ID_;
expresion_sufija: BRACK1_ expresion BRACK2_
                | ID_ operador_incremento
                | ID_ SQUARE1_ expresion SQUARE2_
                | ID_
                | CTE_
                | TRUE_
                | FALSE_;

operador_asignacion: IGUAL_
                   | MASIGUAL_
                   | MENOSIGUAL_
                   | PORIGUAL_
                   | DIVIGUAL_;
operador_logico: BOOLAND_
               | BOOLOR_;
operador_igualdad: CIGUAL_
                 | CDESIGUAL_;
operador_relacional: CMAYOR_
                   | CMENOR_
                   | CMAYORIG_
                   | CMENORIG_;
operador_aditivo: OPSUMA_
                | OPRESTA_ CTE_;
operador_multiplicativo: OPMULT_
                       | OPDIV_
                       | OPMOD_;
operador_unario: OPSUMA_
               | OPRESTA_
               | BOOLNOT_;
operador_incremento: OPINCREMENTO_
                   | OPDECREMENTO_;


%%

main ()
{
    yyparse();
}

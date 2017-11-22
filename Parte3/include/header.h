/*****************************************************************************/
/**   Ejemplo de un posible fichero de cabeceras ("header.h") donde situar  **/
/** las definiciones de constantes, variables y estructuras para MenosC.18  **/
/** Los alumos deberan adaptarlo al desarrollo de su propio compilador.     **/
/*****************************************************************************/
#ifndef _HEADER_H
#define _HEADER_H

/****************************************************** Constantes generales */
#define TRUE  1
#define FALSE 0
#define TALLA_TIPO_SIMPLE 1
/***************************************************** Constantes operadores */
/* Operador Logico*/
#define OP_AND 0
#define OP_OR  1
/* Operador unario */
#define OP_NOT   2
/************************************************************ Error messages */
/* Variables */
#define E_UNDECLARED            "La variable no ha sido declarada"
#define E_REPEATED_DECLARATION  "La variable no puede ser declarada dos veces"
#define E_ARRAY_SIZE_INVALID    "La talla del array no es valida"
#define E_ARRAY_INDEX_INVALID   "El indice es invalido"
#define E_ARRAY_INDEX_TYPE      "El indice debe ser entero"
#define E_ARRAY_WO_INDEX        "El array solo puede ser accedido con indices"
#define E_VAR_WITH_INDEX        "La variable no es un array, no puede ser accedida con indices"

/* Estructuras de control y loops */
#define E_IF_LOGICAL            "La expresion del if debe ser logica"
#define E_WHILE_LOGICAL         "La expresion del while debe ser logica"

/* Tipos */
#define E_TYPES_ASIGNACION      "Tipos no coinciden en asignacion a variable"
#define E_TYPES_LOGICA          "Tipos no coinciden en operacion logica"
#define E_TYPE_MISMATCH         "Los tipos no coinciden"

/******************************************** Struct para analisis semantico */
typedef struct exp {
    int valor;
    int tipo;
    int valid;
    int pos;
} EXP;

typedef struct ifelse_instr {
    int etqElse;
    int etqEnd;
} IF_ELSE_INSTR;

typedef struct while_instr {
    int etqBegin;
    int etqEnd;
} WHILE_INSTR;
/************************************* Variables externas definidas en el AL */
extern FILE *yyin;
extern int   yylineno;
extern char *yytext;
/********************* Variables externas definidas en el Programa Principal */
extern int verbosidad;              /* Flag para saber si se desea una traza */
extern int numErrores;              /* Contador del numero de errores        */

/************************ Variables externas definidas en Programa Principal */
extern int verTDS;               /* Flag para saber si se desea imprimir TDS */
/***************************** Variables externas definidas en las librerias */
extern int dvar;                     /* Contador del desplazamiento relativo */

#endif  /* _HEADER_H */
/*****************************************************************************/

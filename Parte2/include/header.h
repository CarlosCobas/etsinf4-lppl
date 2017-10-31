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
/* Operador Asignacion */
#define OP_ASIG       0
#define OP_ASIG_SUMA  1
#define OP_ASIG_RESTA 2
#define OP_ASIG_MULT  3
#define OP_ASIG_DIV   4
/* Operador Logico*/
#define OP_AND 0
#define OP_OR  1
/* Operador igualdad */
#define OP_IGUAL    0
#define OP_NOTIGUAL 1
/* Operador relacional */
#define OP_MAYOR   0
#define OP_MAYORIG 1
#define OP_MENOR   2
#define OP_MENORIG 3
/* Operador aditivo */
#define OP_SUMA  0
#define OP_RESTA 1
/* Operador multiplicativo */
#define OP_MULT 0
#define OP_DIV  1
#define OP_MOD  2
/* Operador unario */
#define OP_MAS   0
#define OP_MENOS 1
#define OP_NOT   2
/* Operador incremento */
#define OP_INC 0
#define OP_DEC 1

/************************************************ Struct para las expresions */
struct exp {
    int valor;
    int tipo;
} EXP;
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

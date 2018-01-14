# Prácticas: Lenguajes de programación y procesamiento de lenguajes
Requiere `flex`, `bison`, `make` y `gcc`

## MenosC: especificación del lenguaje
### Especificación léxica
* Los identificadores son cadenas de letras (incluyendo `_`) y dígitos, que comienzan siempre por una letra. Debe distinguirse entre mayúsculas y minúsculas.
* Las palabras reservadas se deben escribir en minúscula.
* Todas las constantes numéricas deben considerarse enteras.
* El signo `+` (ó `-`) de las constantes numéricas se tratará como un símbolo léxico independiente.
* Los espacios en blanco, retornos de línea y tabuladores deben ignorarse.
* Los comentarios deben ir precedidos por la doble barra (`//`) y terminar con el fin de la línea. Los comentarios no se pueden anidar.

### Especificación sintáctica
Ver [especificación](Parte1/src/asin.y) y [equivalencia de símbolos](Parte1/src/alex.l)

### Especificación semántica
* El compilador solo trabaja con constantes enteras. Si el analizador léxico encuentra una constante real en el programa se debe devolver su valor entero truncado.
* Todas las variables deben declararse antes de ser utilizadas.
* La talla de los tipos simples, `int` y `bool`, debe definirse, por medio de la constante `TALLA_TIPO_SIMPLE=1`, en el fichero `include/header.h`.
* El tipo lógico `bool` se representa numéricamente como un entero: con el valor 0 para el caso `falso` y 1 para el caso `verdad`.
* No existe conversión de tipos entre `int` y `bool`.
* El operador módulo `%` realiza el resto de una división entera; por tanto, los dos argumentos deben ser enteros.
* Los índices de los vectores van de `0` a `cte-1`, siendo `cte` el número de elementos definido en su declaración. El número de elementos de un vector debe ser un entero positivo.
* No es necesario comprobar los índices de los vectores en tiempo de ejecución.
* Las expresiones de las instrucciones `if-elseif-else`, `while` y `do-while` deben ser de tipo lógico.
* En cualquier otro caso, las restricciones semánticas por defecto serán las propias del lenguaje ANSI C.

## Secciones del proyecto:
* Parte1: analizador léxico y sintáctico
* Parte2: analizador semántico
* Parte3: generador de código intermedio

**Nota**: Las partes 2 y 3 no funcionan con versión de `gcc` superior a 5.

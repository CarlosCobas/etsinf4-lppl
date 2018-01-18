// Ejemplo sencillo de manipulacion de vectores.
// Devuelve la cuenta inversa de 9 a 0 (inclusive)
{ int a[10]; int i;

  i = 0;
  loop a[i] = i; until (i > 8) step i++;

  i = 9;
  loop print(a[i]); until (i <= 0) step i--;
}

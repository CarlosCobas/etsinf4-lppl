%{
#include <stdio.h>
#include "header.h"
%}

%option yylineno

delimitador     [ \t\n]+
comentario      \/\/.*
letra           [a-zA-Z]
digito          [0-9]
constante       {digito}+(\.{digito}+)?
identificador   {letra}({letra}|{digito}|_)*

%%

{delimitador}   {  }
{comentario}    {  }

"read"          { return READ_;         }
"print"         { return PRINT_;        }
"if"            { return IF_;           }
"else"          { return ELSE_;         }
"elseif"        { return ELSEIF_;       }
"while"         { return WHILE_;        }
"do"            { return DO_;           }
"int"           { return INT_;          }
"bool"          { return BOOL_;         }
"true"          { return TRUE_;         }
"false"         { return FALSE_;        }

"=="            { return OPIGUAL_;      }
"!="            { return OPNOTIGUAL_;   }
"+="            { return MASIGUAL_;     }
"-="            { return MENOSIGUAL_;   }
"*="            { return PORIGUAL_;     }
"/="            { return DIVIGUAL_;     }
"++"            { return OPINCREMENTO_; }
"--"            { return OPDECREMENTO_; }
"&&"            { return OPAND_;        }
"||"            { return OPOR_;         }
"="             { return IGUAL_;        }
"+"             { return OPSUMA_;       }
"-"             { return OPRESTA_;      }
"*"             { return OPMULT_;       }
"/"             { return OPDIV_;        }
"%"             { return OPMOD_;        }
"!"             { return OPNOT_;        }
"("             { return PARENTESIS1_;  }
")"             { return PARENTESIS2_;  }
"{"             { return LLAVE1_;       }
"}"             { return LLAVE2_;       }
"["             { return CORCHETE1_;    }
"]"             { return CORCHETE2_;    }
";"             { return SEMICOLON_;    }

{constante}     { return CTE_;          }
{identificador} { return ID_;           }
.               { printf("Error!\n");   }

%%


%{
//fichier LEX
#include "table_symbole.h"
#include "analy_sem.tab.h"
#include <stdio.h>
#include <stdbool.h>


%}

/* ensemble lettre */

lettre [a-z]      


%%


 /* mot cle */
"programme"  {   etat=programme; return Programme;                    } 
"debut"      {     etat=debut;      return Debut;                     }
"fin"        {                      return Fin;                       }
"const"  {     etat=constante;  return Constante ;                }
"var"        {     etat=var;        return Var;                       }
"si"         {                      return Si;                        } 
"alors"      {                      return Alors;                     }
"sinon"      {                      return Sinon;                     }
"fsi"        {                      return Fsi;                       } 



"ent"        {  
                       yylval.mot = malloc(sizeof(word_list)); // mot et un pointeur vers char   (char *mot) alloue espace 
                       strcpy(yylval.mot,yytext);              // copier avec strcpy et tout sela pour eviter erreur de segmentation
                                                              return Ent;      }


"Bool"       { 
                       yylval.mot = malloc(sizeof(word_list)); // Même principe que ent est dans tout les autrs 
                       strcpy(yylval.mot,yytext);
                                       			       return Boolean;  }


 /* *yytext retourne chaine selon la règle = , +....etc*/


 /* Operation */
"+"         return *yytext;
":="        return affect;  
"="         return *yytext;


 /* Seprateur */
","         return *yytext;
":"         return *yytext;
";"         return *yytext;                                


 /* Constante  */
"Vrai"      {          yylval.mot = malloc(sizeof(word_list));
                       strcpy(yylval.mot,yytext);
                       
                       						   return Vrai;   }


"Faux"      {          yylval.mot = malloc(sizeof(word_list));
                       strcpy(yylval.mot,yytext);
                       						   return Faux;  }

 /* identifition expréssion regulière */

{lettre}({lettre}|[0-9])* {  
                             if(etat != 3){ /* etat repraisante phase traitement dans cette*
                                               etat on va utiliser la table mais on vas pas inserer valeur 
                                               var c'est à la phase sémantique quand insert valeur
                                               */
                                  yylval.w=add_word(yytext); /* transmattre à w qui est 
                                                              définit %union dans yacc
                                                              addresse maillon qui contien yytext */
                                 }

                                                      return ident; }

 
 /* constante expréssion régulière */
[0-9]+          {      yylval.mot = malloc(sizeof(word_list));
                       strcpy(yylval.mot,yytext);
                                                       return Cste; }  


[^ \n\t]   ; 			        	     //igonrer espcae saut ligne tabulation



 



%%


// insertion :   le 1 element code source à insérer  c'est  le dernier dans la table des symboles
/* Remraque :
   la methode add_word  je l'es ramener d'un livre de l'internet  
   parcque le chaînage etait trés  difficile pour moi  j'ai passé plusieure jour sur ce problem (insertion & faire le chaînage)
   pareque j'avait erreur segmentation (dumped) ce code si-dessous m'aider 
   et je l'es adapter à ma structure de table symbole 
   juste je ne veut pas dire que ce code m'apprtient au jour de présentation pour éviter le plagiat et aussi il ma aussi  aider sur 
   idée de etat si je suis avant debut puis aprés debut dans le code source du fichier à analyser  
    
    référence code source  add_word adapter: https://linuxbbq.org/PDF/lexandyacc.pdf        page 11-12 
 */
struct identifiant * add_word( char *word)
{
      struct identifiant *wp;
      wp = (struct identifiant *) malloc(sizeof(struct identifiant));
      wp->suiv = word_list;

      wp->id_nom = (char *) malloc(strlen(word)+1);
      strcpy(wp->id_nom, word);
      word_list = wp;
      return word_list;  

}

int yywrap(){

return 1;
}


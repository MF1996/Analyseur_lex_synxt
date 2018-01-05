%{
//fichier YACC
#include "table_symbole.h"
#include "stdio.h"
#include "stdlib.h"
#include  "string.h" // biblothèque string pour utiliser strcpy , strcmp 
                     //  strcpy copier coller chaine 
                     //  strcmp comparer deux chaine
#include <stdbool.h> 

/* définit methode yylex et yyerror et 
Sa fin de ne pas avoir message erreur  yylex ..... on éxécutant gcc */
int yylex();
int yyerror(char *msg);

int cout=0; // compte nombre ident aprés 1 virgule exemple :  ident,ident,ident   cout=2   

                                                                 
struct identifiant *aff;                                   
struct identifiant *p,*ver; /*  pointeur qui va stocker 
                           addresse du maillon afin d'effectuer rechercher double déclration 
                       */

bool rep; // tester si var ou constante est redéfinie

char *point_arret; // point arrez de suppression type des variables double

struct identifiant  *insere_type_type_var(struct identifiant *id, char *type); // insrer type varibale

void insere_type_val_constante(struct identifiant *id,char *val);  // insrer type et valeur constante 

void mise_a_jour(struct identifiant *aff);

%}

//défnie structure pour YYSTYPE

%union{

        char *mot; // chaine carctère 

        struct identifiant *w; // w pointeur structure définit dans table_symbole.h
}


// Axiome 
%start S


/*  Mot cle */
%token  Programme  Debut Fin  Constante Var 
%token Si Alors Sinon Fsi 


%token  affect

/* Type et valeur telle que c'est token sont de
 type mot (chaine de carcatère définit dans %union) */
%token  <mot>Boolean
%token  <mot>Ent
%token  <mot>Faux
%token  <mot>Vrai

/*ident et Cste sont de type w,mot 
ou il sont aussi définit dans %union*/
%token  <w>  ident
%token  <mot> Cste 

/*On utilise %type pour les  non terminaux c-à-d la sorite de type & Num 
c'est un mot qui est définit dans %union */
%type <mot> Num
%type <mot> type



%%


S : Programme ident  ';' D  Debut Inst Fin   
  ;


D : C V 
  ;

C :  Constante Dec
   | 
   ; 

Dec : ident '=' Num ';' { insere_type_val_constante($1,$3);  } Dec
    
    | ident '=' Num     { insere_type_val_constante($1,$3);      point_arret=malloc(strlen($1->id_nom)+1);
                                                                 strcpy(point_arret,$1->id_nom); /*point arrer mise jour des que arriver à un  													   nom qui appartient au constante en arrete*/
                                           
                        }
    ;

V   : Var  Dev  

    |  
    ;

Dev : ident M  ':' type ';' { insere_type_type_var($1,$4); }  Dev  
    | ident  M ':' type { 


                              aff= insere_type_type_var($1,$4); /* insertion ce sais pour tout les variable même pour double déclration
                                                                  mais une mise à jour et fait pour ce cas */

                              mise_a_jour(aff); /* principe vérifier si existe variable en 
                                                   plus déclarer cette denière sont champ type seras
                                                   intialiser à NULL puis à la fin il affichage de la table 
                                                 */
                                

 }                           
    ;

type : Ent 
     | Boolean
     ;

Inst : Instr 
     | 
     ;

Instr : ident affect Exp I 
      | Si ident Alors Instr Sinon Instr Fsi  
      | Si ident Alors Instr Fsi 
      ;

I : ';' Instr 
  | 
  ;

/* Elimnation de la récursivité gauche*/
Exp : ident '+' Expression 
    | Cste  '+' Expression 
    ;

Expression : ident '+' Expression  
           | Cste  '+' Expression 
           | ident 
           | Cste  
            ;

M : ',' ident { save_list=$2; /*retourne addresse maillon à sav_list*/ cout++; /*compte nombre ident apres 1 virgule*/  } M   
  |
  ;


Num : Cste 
    | Vrai 
    | Faux 
    ;

%%


struct identifiant  *insere_type_type_var(struct identifiant *id, char *type){

                                       aff=save_list; // sauvgarder addresse à afin de la retourne comme sortie 
                                       
                                       id->type=type; /* initialise 1 identifiant 
                                                         le reste des id seront 
                                                         leur type seras
                                                         initialser dans while */ 


    
                                                     while(cout!=0){ // cas arret hériter le type à tout les identifiants cas variable
								
                                                                     save_list->type=type;                                                     
 								     save_list=save_list->suiv;
                                                                      
                                                                     cout--;// pour dire que element i sont type à êtais insérer 
                                                                    }                                               
return aff;
}


void insere_type_val_constante(struct identifiant *id,char *val){

                            	p=id ;      // sauvgarder adresse id 
                            	
                                 p=p->suiv; // passe suivant car en vas pas comparer element avec lui même
                         			
          while(p!=NULL){  
	                   if(strcmp(p->id_nom,id->id_nom)==0){  //constante existe deja 
                                      	
                                            		     rep=true; // rep =true oui il a une double déclaration
                                       
                                            		     break; // sort imidiatement 
                             		        	}
                          			             p=p->suiv; //sinon on passe au suivant 
                         }
                          
          if(!rep){
                    if(val[0]=='V'|| val[0]=='F')  // verifie si vrai ou faux afin inserer le type de la cosntante 
                                  {
                                       id->type=malloc(sizeof(word_list));  // allouer pour eviter erreur de segmentation
                                            
                                       strcpy(id->type,"Bool");             //copie Bool dans type
                                           
                                       id->val_bool=malloc(sizeof(word_list)); 
                                            
                                       strcpy(id->val_bool,val);  // copie la valeur val dans val_bool
                                   } 
                              
                      else         {      
                                     id->type=malloc(sizeof(word_list));  // cas entier alloue aussi pour éviter erreur de segmentation
                                  
                                     strcpy(id->type,"ent");              // copie ent dans type
                                     
                                     id->val_ent=atoi(val);        // insert la valeur en convertissent val type chaîne en entier grâce à atoi
                               
                                   } 
                               }


}

void mise_a_jour(struct identifiant *aff){
/* SUPPRIMER TYPE VARIABLE DOUBLE*/
/* la liste chaine et sous forme suivant:  1 mot  dans code source qui doit être insérer et le dernier dans las list chaîne */
                                 
                                 ver=aff; 
                                 
                                 struct identifiant *elem_tab;
                                 
                                 elem_tab=ver;                                           
                                 
                                 while(strcmp(aff->id_nom,point_arret)!=0) // cas arret arriver à 
                                           {   
                                              ver=ver->suiv;
                                                             while(ver!=NULL){
                                                                               if(strcmp(ver->id_nom,aff->id_nom)==0) /* il existe double  																delaration variable */
                                                                                  {
                                                                                     aff->type=NULL;
                                                                                     break;
                                                                                   }
                                                                                      ver=ver->suiv;         /*cas echoue  passe mot suivant */
                                                                               }
                              

                                                aff=aff->suiv; /*passe mot suivant */
                                        
                                                ver=aff; /* le principe on prend 1 mot en compare avec ce que 
                                                           lui précède on arret en arriver à un mot qui 
                                                            n'appartient pas ou variable 
                                                            c-à-d le mot lui appartient au ensemble de constante  */ 
                                            }

/*  PARTIE AFFICHAGE DE LA TABLE DES SYMBOLES */
int i=1;
 printf("  ID       |      TYPE      |     VALUE Bool     |    VALUES Ent   |");
 
 printf("\n");
 while(elem_tab!=NULL){
    printf("\n %s               %s              %s              %d \n",elem_tab->id_nom,elem_tab->type,elem_tab->val_bool,elem_tab->val_ent);
  elem_tab = elem_tab->suiv;
}






}







int yyerror(char *msg){
printf("message erreur %s",msg);
return 0;
}

int main(){

extern FILE *yyin; // Fichier externe 

yyin = fopen("code_source","r"); //  ouvrire fichier code source en mode lecture

yyparse();   // lance analyseur

fclose(yyin);  // ferme fichier

return 0; 
}



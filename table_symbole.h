#include <stdlib.h>


typedef enum {programme 
              , constante 
              , var,
               debut , 
               si , alors , 
              sinon , fsi ,
              fin }mot_cle; /* diffrent mot cle du*/





struct identifiant {
      
      char *id_nom;
      char *type;
      int  val_ent;
      char *val_bool;      
      struct identifiant *suiv;
};

struct identifiant *word_list; 


struct identifiant *save_list; 


struct identifiant * add_word( char *word);



int etat;



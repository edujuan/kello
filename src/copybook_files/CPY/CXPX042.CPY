           SELECT CXD042 ASSIGN TO PATH-CXD042
                  ORGANIZATION IS INDEXED
                  ACCESS MODE IS DYNAMIC
                  STATUS IS ST-CXD042
                  LOCK MODE IS AUTOMATIC
                  WITH LOCK ON RECORD
                  RECORD KEY IS CHAVE-CX42 = ANOMES-CX42 CONTAREDUZ-CX42
                  ALTERNATE RECORD KEY IS ALT-CX42 =
                            CONTAREDUZ-CX42 ANOMES-CX42 WITH DUPLICATES.

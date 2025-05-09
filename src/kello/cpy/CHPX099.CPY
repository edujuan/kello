           SELECT CHD099 ASSIGN TO PATH-CHD099
                  ORGANIZATION INDEXED
                  ACCESS MODE DYNAMIC
                  LOCK MODE IS AUTOMATIC
                  WITH LOCK ON RECORD
                  RECORD KEY IS CHAVE-CH99 = DATA-MOVTO-CH99 SEQ-CH99
                  ALTERNATE RECORD KEY ALT1-CH99 =
                     NOME-CH99, PORTADOR-CH99 WITH DUPLICATES
                  ALTERNATE RECORD KEY ALT2-CH99 = SITUACAO-CH99
                     DATA-VENCTO-CH99 PORTADOR-CH99 WITH DUPLICATES
                  ALTERNATE RECORD KEY ALT3-CH99 = DATA-MOVTO-CH99
                     VENDEDOR-CH99 SEQ-CH99 WITH DUPLICATES
                  STATUS IS ST-CHD099.

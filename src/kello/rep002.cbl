       COPY DSLANG.CPY.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. REP002.
      *AUTORA: MARELI AMANCIO VOLPATO
      *DATA: 24/02/2000
      *DESCRI��O: Cadastro de FUN��ES - CONTROLE DE REPORTAGEM
       ENVIRONMENT DIVISION.
       SPECIAL-NAMES.
       PRINTER IS LPRINTER
       DECIMAL-POINT IS COMMA.
       class-control.
           Window             is class "wclass".

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY REPX002.
           SELECT RELAT ASSIGN TO PRINTER NOME-IMPRESSORA.

       DATA DIVISION.
       FILE SECTION.
       COPY REPW002.
       FD  RELAT
           LABEL RECORD IS OMITTED.
       01  REG-RELAT.
           05  FILLER              PIC X(80).
       WORKING-STORAGE SECTION.
           COPY IMPRESSORA.
           COPY "REP002.CPB".
           COPY "REP002.CPY".
           COPY "DS-CNTRL.MF".
           COPY "CBDATA.CPY".
       78  REFRESH-TEXT-AND-DATA-PROC VALUE 255.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  VARIAVEIS.
           05  ST-RED002             PIC XX       VALUE SPACES.
           05  ULT-CODIGO            PIC 9(2)     VALUE ZEROS.
      *    Ult-codigo - ser� utilizado p/ encontrar o �ltimo c�digo
      *    de regi�o utilizado
           05  GRAVA-W               PIC 9        VALUE ZEROS.
           05  ERRO-W                PIC 9        VALUE ZEROS.
           05  ORDEM-W               PIC 9        VALUE ZEROS.
           05  LIN                   PIC 9(02)    VALUE ZEROS.
      *    ordem-w - flag que controla a ordem do relatorio - num�rico
      *    ou alfab�tico
           05  HORA-W                PIC 9(8)     VALUE ZEROS.
           05  PAG-W                 PIC 9(2)     VALUE ZEROS.
           05  EMP-REFERENCIA.
               10  FILLER            PIC X(15)
                   VALUE "\PROGRAMA\KELLO".
               10  VAR1              PIC X VALUE "\".
               10  EMP-REC           PIC XXX.
               10  VAR2              PIC X VALUE "\".
               10  ARQ-REC           PIC X(10).
           05  EMPRESA-REF REDEFINES EMP-REFERENCIA PIC X(30).
           COPY "PARAMETR".

       77 janelaPrincipal              object reference.
       77 handle8                      pic 9(08) comp-x value zeros.
       77 wHandle                      pic 9(09) comp-5 value zeros.

       01  CAB01.
           05  EMPRESA-REL         PIC X(60)   VALUE SPACES.
           05  FILLER              PIC X(13)   VALUE SPACES.
           05  FILLER              PIC X(5)    VALUE "PAG: ".
           05  PAG-REL             PIC Z9      VALUE ZEROS.
       01  CAB02.
           05  FILLER              PIC X(63)   VALUE
           "RELACAO DE FUNCOES DE REPORTAGEM".
           05  HORA-REL            PIC X(5)    VALUE "  :  ".
           05  FILLER              PIC XX      VALUE SPACES.
           05  EMISSAO-REL         PIC 99/99/9999 BLANK WHEN ZEROS.
       01  CAB03.
           05  FILLER              PIC X(80)   VALUE ALL "=".
       01  CAB04.
           05  FILLER              PIC X(80)   VALUE
           "COD.      DESCRICAO  ".

       01  LINDET.
           05  LINDET-REL          PIC X(80)   VALUE SPACES.

       LINKAGE SECTION.
       77  POP-UP                  PIC X(30).
       PROCEDURE DIVISION USING POP-UP.

       MAIN-PROCESS SECTION.
           PERFORM INICIALIZA-PROGRAMA.
           PERFORM CORPO-PROGRAMA UNTIL GS-EXIT-FLG-TRUE.
           GO FINALIZAR-PROGRAMA.

       INICIALIZA-PROGRAMA SECTION.
           ACCEPT PARAMETROS-W FROM COMMAND-LINE.
           COPY "CBDATA1.CPY".
           MOVE ZEROS TO PAG-W ERRO-W.
           INITIALIZE GS-DATA-BLOCK
           INITIALIZE DS-CONTROL-BLOCK
           MOVE GS-DATA-BLOCK-VERSION-NO
                                   TO DS-DATA-BLOCK-VERSION-NO
           MOVE GS-VERSION-NO  TO DS-VERSION-NO
           MOVE EMPRESA-W          TO EMP-REC
           MOVE NOME-EMPRESA-W     TO EMPRESA-REL
           MOVE "RED002" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-RED002.
           OPEN I-O RED002
           MOVE 1 TO GRAVA-W.
           IF ST-RED002 = "35"
              CLOSE RED002      OPEN OUTPUT RED002
              CLOSE RED002      OPEN I-O RED002
           END-IF.
           IF ST-RED002 <> "00"
              MOVE "ERRO ABERTURA RED002: "  TO GS-MENSAGEM-ERRO
              MOVE ST-RED002 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF COD-USUARIO-W NOT NUMERIC
              MOVE "Executar pelo MENU" TO GS-MENSAGEM-ERRO
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ERRO-W = ZEROS
                MOVE 1 TO GS-ORDER
                PERFORM ACHAR-CODIGO
                PERFORM LOAD-SCREENSET.

       CORPO-PROGRAMA SECTION.
           EVALUATE TRUE
               WHEN GS-CENTRALIZA-TRUE
                   PERFORM CENTRALIZAR
               WHEN GS-SAVE-FLG-TRUE
                   PERFORM SALVAR-DADOS
                   PERFORM CARREGA-ULTIMOS
                   PERFORM LIMPAR-DADOS
                   PERFORM INCREMENTA-CODIGO
                   MOVE "SET-POSICAO-CURSOR1" TO DS-PROCEDURE
               WHEN GS-EXCLUI-FLG-TRUE
                   PERFORM EXCLUI-RECORD
                   PERFORM CARREGA-ULTIMOS
                   PERFORM ACHAR-CODIGO
                   PERFORM MOSTRA-ULT-CODIGO
               WHEN GS-CLR-FLG-TRUE
                   PERFORM LIMPAR-DADOS
                   PERFORM MOSTRA-ULT-CODIGO
               WHEN GS-PRINTER-FLG-TRUE
                    COPY IMPRESSORA.CHAMA.
                    IF LNK-MAPEAMENTO <> SPACES
                       PERFORM IMPRIME-RELATORIO
                    END-IF
                    PERFORM MOSTRA-ULT-CODIGO
               WHEN GS-CARREGA-ULT-TRUE
                   PERFORM CARREGA-ULTIMOS
                   MOVE "SET-POSICAO-CURSOR1" TO DS-PROCEDURE
               WHEN GS-CARREGA-LIST-BOX-TRUE
                   MOVE GS-LINDET(1: 2) TO GS-CODIGO
                   PERFORM CARREGAR-DADOS
           END-EVALUATE
           PERFORM CLEAR-FLAGS
           PERFORM CALL-DIALOG-SYSTEM.

       CENTRALIZAR SECTION.
          move-object-handle principal handle8
          move handle8 to wHandle
          invoke Window "fromHandleWithClass" using wHandle Window
                 returning janelaPrincipal

          invoke janelaPrincipal "CentralizarNoDesktop".

       CARREGAR-DADOS SECTION.
           MOVE ZEROS TO GRAVA-W.
           MOVE GS-CODIGO       TO CODIGO-RE02.
           READ RED002 INVALID KEY INITIALIZE REG-RED002
                                   MOVE 1 TO GRAVA-W.
           MOVE DESCRICAO-RE02          TO GS-DESCRICAO.
       CARREGA-MENSAGEM-ERRO SECTION.
           PERFORM LOAD-SCREENSET.
           MOVE 1 TO ERRO-W.
           MOVE "EXIBE-ERRO" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
       LIMPAR-DADOS SECTION.
           INITIALIZE REG-RED002
           MOVE GS-ORDER TO ORDEM-W
           INITIALIZE GS-DATA-BLOCK
           MOVE ORDEM-W TO GS-ORDER
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
       EXCLUI-RECORD SECTION.
           DELETE RED002.
           PERFORM LIMPAR-DADOS.
           MOVE 1 TO GRAVA-W.
       SALVAR-DADOS SECTION.
           MOVE GS-CODIGO                    TO CODIGO-RE02
           MOVE GS-DESCRICAO                 TO DESCRICAO-RE02
           MOVE FUNCTION NUMVAL(GS-ACUMULAR) TO ACUMULAR-RE02
           IF GRAVA-W = 1
              WRITE REG-RED002 INVALID KEY
                    PERFORM ERRO-GRAVACAO
           ELSE
              REWRITE REG-RED002 INVALID KEY
                    PERFORM ERRO-GRAVACAO
              NOT INVALID KEY
                    SUBTRACT 1 FROM ULT-CODIGO
           END-IF.
       ERRO-GRAVACAO SECTION.
           MOVE "ERRO GRAVA��O" TO GS-MENSAGEM-ERRO
           MOVE ST-RED002       TO GS-MENSAGEM-ERRO(23: 2)
           PERFORM LOAD-SCREENSET
           PERFORM CARREGA-MENSAGEM-ERRO
           PERFORM ACHAR-CODIGO
           SUBTRACT 1 FROM ULT-CODIGO.
       CARREGA-ULTIMOS SECTION.
           MOVE "CLEAR-LIST-BOX" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           IF GS-ORDER = ZEROS
              MOVE SPACES TO DESCRICAO-RE02
              START RED002 KEY IS NOT < DESCRICAO-RE02
                    INVALID KEY MOVE "10" TO ST-RED002
           ELSE
             MOVE ZEROS TO CODIGO-RE02
               START RED002 KEY IS NOT < CODIGO-RE02
                 INVALID KEY MOVE "10" TO ST-RED002.
           MOVE SPACES TO GS-LINDET.
           MOVE ZEROS TO GS-CONT.
           PERFORM UNTIL ST-RED002 = "10"
              READ RED002 NEXT RECORD AT END
                   MOVE "10" TO ST-RED002
              NOT AT END
                   ADD 1                            TO GS-CONT
      *            MOVE SPACES TO GS-LINDET
                   MOVE CODIGO-RE02                 TO GS-LINDET(01: 06)
                   MOVE DESCRICAO-RE02              TO GS-LINDET(07: 30)
                   EVALUATE ACUMULAR-RE02
                      WHEN 1 MOVE "1-Coordena��o"   TO GS-LINDET(32:20)
                      WHEN 2 MOVE "2-Fotografo"     TO GS-LINDET(32:20)
                      WHEN 3 MOVE "3-Cinegrafista"  TO GS-LINDET(32:20)
                      WHEN 4 MOVE "4-Auxiliar"      TO GS-LINDET(32:20)
                      WHEN 5 MOVE "5-Material"      TO GS-LINDET(32:20)
                      WHEN 6 MOVE "6-Loca��o KM"    TO GS-LINDET(32:20)
                      WHEN 7 MOVE "7-Aluguel"       TO GS-LINDET(32:20)
                      WHEN 8 MOVE "8-Outros"        TO GS-LINDET(32:20)
                      WHEN OTHER MOVE SPACES        TO GS-LINDET(32:20)
                   END-EVALUATE
                   MOVE "INSERE-LIST" TO DS-PROCEDURE
                   PERFORM CALL-DIALOG-SYSTEM
              END-READ
           END-PERFORM.

       CLEAR-FLAGS SECTION.
           INITIALIZE GS-FLAG-GROUP.

       SET-UP-FOR-REFRESH-SCREEN SECTION.
           MOVE "REFRESH-DATA" TO DS-PROCEDURE.

       LOAD-SCREENSET SECTION.
           MOVE DS-PUSH-SET TO DS-CONTROL
           MOVE "REP002" TO DS-SET-NAME
           PERFORM CALL-DIALOG-SYSTEM.

       IMPRIME-RELATORIO SECTION.
           OPEN OUTPUT RELAT.
           IF GS-ORDER = 1
              MOVE ZEROS TO CODIGO-RE02
              START RED002 KEY IS NOT < CODIGO-RE02 INVALID KEY
                    MOVE "10" TO ST-RED002
           ELSE
              MOVE SPACES TO DESCRICAO-RE02
              START RED002 KEY IS NOT < DESCRICAO-RE02 INVALID KEY
                    MOVE "10" TO ST-RED002.

           MOVE ZEROS TO LIN.
           PERFORM CABECALHO.
           PERFORM UNTIL ST-RED002 = "10"
                READ RED002 NEXT RECORD AT END
                     MOVE "10" TO ST-RED002
                NOT AT END
                     MOVE SPACES                   TO LINDET-REL
                     MOVE CODIGO-RE02              TO LINDET-REL(01: 08)
                     MOVE DESCRICAO-RE02           TO LINDET-REL(09: 30)
                     EVALUATE ACUMULAR-RE02
                        WHEN 1 MOVE "1-Coordena��o" TO LINDET-REL(32:20)
                        WHEN 2 MOVE "2-Fotografo"   TO LINDET-REL(32:20)
                        WHEN 3 MOVE "3-Cinegrafista"
                                                    TO LINDET-REL(32:20)
                        WHEN 4 MOVE "4-Auxiliar"    TO LINDET-REL(32:20)
                        WHEN 5 MOVE "5-Material"    TO LINDET-REL(32:20)
                        WHEN 6 MOVE "6-Loca��o KM"  TO LINDET-REL(32:20)
                        WHEN 7 MOVE "7-Aluguel"     TO LINDET-REL(32:20)
                        WHEN 8 MOVE "8-Outros"      TO LINDET-REL(32:20)
                        WHEN OTHER MOVE SPACES      TO LINDET-REL(32:20)
                     END-EVALUATE

                     WRITE REG-RELAT FROM LINDET
                     ADD 1 TO LIN
                     IF LIN > 56
                       PERFORM CABECALHO
                     END-IF
                END-READ
           END-PERFORM.
           MOVE SPACES TO REG-RELAT.
           WRITE REG-RELAT AFTER PAGE.
           CLOSE RELAT.

       CABECALHO SECTION.
           ADD  1     TO PAG-W.
           MOVE PAG-W TO PAG-REL.
           IF PAG-W = 1
              WRITE REG-RELAT FROM CAB01
           ELSE
              WRITE REG-RELAT FROM CAB01 AFTER PAGE.

           WRITE REG-RELAT FROM CAB02 AFTER 2.
           WRITE REG-RELAT FROM CAB03.
           WRITE REG-RELAT FROM CAB04.
           WRITE REG-RELAT FROM CAB03.
           MOVE 4 TO LIN.
       ACHAR-CODIGO SECTION.
           MOVE ZEROS TO CODIGO-RE02 ULT-CODIGO
           START RED002 KEY IS NOT < CODIGO-RE02 INVALID KEY
                 MOVE "10" TO ST-RED002
           END-START
           PERFORM UNTIL ST-RED002 = "10"
                 READ RED002 NEXT RECORD AT END
                      MOVE "10" TO ST-RED002
                 NOT AT END
                      MOVE CODIGO-RE02 TO ULT-CODIGO
                 END-READ
           END-PERFORM.
           PERFORM INCREMENTA-CODIGO.
       INCREMENTA-CODIGO SECTION.
           ADD 1 TO ULT-CODIGO.
           MOVE 1 TO GRAVA-W.
           MOVE ULT-CODIGO TO GS-CODIGO.
       MOSTRA-ULT-CODIGO SECTION.
           MOVE 1 TO GRAVA-W.
           MOVE ULT-CODIGO TO GS-CODIGO
           MOVE "SET-POSICAO-CURSOR1" TO DS-PROCEDURE.

       CALL-DIALOG-SYSTEM SECTION.
           CALL "DSRUN" USING DS-CONTROL-BLOCK, GS-DATA-BLOCK.
           IF NOT DS-NO-ERROR
              MOVE DS-ERROR-CODE TO DISPLAY-ERROR-NO
              DISPLAY "DS ERROR NO:  " DISPLAY-ERROR-NO
             GO FINALIZAR-PROGRAMA
           END-IF.
       FINALIZAR-PROGRAMA SECTION.
           CLOSE RED002.
           MOVE DS-QUIT-SET TO DS-CONTROL.
           PERFORM CALL-DIALOG-SYSTEM.
           EXIT PROGRAM.

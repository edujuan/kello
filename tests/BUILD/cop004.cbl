       copy dslang.cpy.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COP004.
       AUTHOR. MARELI AMANCIO VOLPATO.
       DATE-WRITTEN. 02/08/1999.
      *DESCRI��O: Cadastro de Campanhas
       ENVIRONMENT DIVISION.
       SPECIAL-NAMES.
       PRINTER IS LPRINTER
       DECIMAL-POINT IS COMMA.
       class-control.
           Window             is class "wclass".

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY COPX004.
           SELECT RELAT ASSIGN TO PRINTER NOME-IMPRESSORA.

       DATA DIVISION.
       FILE SECTION.

       COPY COPW004.
       FD  RELAT
           LABEL RECORD IS OMITTED.
       01  REG-RELAT.
           05  FILLER              PIC X(80).
       WORKING-STORAGE SECTION.
           COPY IMPRESSORA.
           COPY "COP004.CPB".
           COPY "COP004.CPY".
           COPY "DS-CNTRL.MF".
           COPY "CBDATA.CPY".
       78  REFRESH-TEXT-AND-DATA-PROC VALUE 255.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  VARIAVEIS.
           05  ST-COD004             PIC XX       VALUE SPACES.
           05  ULT-CODIGO            PIC 9(2)     VALUE ZEROS.
      *    Ult-codigo - ser� utilizado p/ encontrar o �ltimo c�digo
      *    do brinde utilizado
           05  GRAVA-W               PIC 9        VALUE ZEROS.
           05  ERRO-W                PIC 9        VALUE ZEROS.
           05  ORDEM-W               PIC 9        VALUE ZEROS.
           05  LIN                   PIC 9(02)    VALUE ZEROS.
      *    ordem-w - flag que controla a ordem do relatorio - num�rico
      *    ou alfab�tico
           05  HORA-W                PIC 9(8)     VALUE ZEROS.
           05  PAG-W                 PIC 9(2)     VALUE ZEROS.
           05  DATA-E                PIC ZZ/ZZ/ZZZZ.
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
           "RELACAO DE CADASTRO DE CAMPANHAS DE CONTRATOS".
           05  HORA-REL            PIC X(5)    VALUE "  :  ".
           05  FILLER              PIC XX      VALUE SPACES.
           05  EMISSAO-REL         PIC 99/99/9999 BLANK WHEN ZEROS.
       01  CAB03.
           05  FILLER              PIC X(80)   VALUE ALL "=".
       01  CAB04.
           05  FILLER              PIC X(80)   VALUE
           "COD DESCRICAO                          ".

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
           MOVE "COD004" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-COD004.
           OPEN I-O COD004
           MOVE 1 TO GRAVA-W.
           IF ST-COD004 = "35"
              CLOSE COD004      OPEN OUTPUT COD004
              CLOSE COD004      OPEN I-O COD004
           END-IF.
           IF ST-COD004 <> "00"
              MOVE "ERRO ABERTURA COD004: "  TO GS-MENSAGEM-ERRO
              MOVE ST-COD004 TO GS-MENSAGEM-ERRO(23: 02)
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
           MOVE GS-CODIGO       TO CODIGO-CO04.
           READ COD004 INVALID KEY INITIALIZE REG-COD004
                                   MOVE 1 TO GRAVA-W
           NOT INVALID KEY
             MOVE DATA-INI-CO04   TO DATA-INV
             CALL "GRIDAT1" USING DATA-INV
             MOVE DATA-INV        TO GS-DATA-INI
             MOVE DATA-FIM-CO04   TO DATA-INV
             CALL "GRIDAT1" USING DATA-INV
             MOVE DATA-INV        TO GS-DATA-FIM.
       CARREGA-MENSAGEM-ERRO SECTION.
           PERFORM LOAD-SCREENSET.
           MOVE 1 TO ERRO-W.
           MOVE "EXIBE-ERRO" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
       LIMPAR-DADOS SECTION.
           INITIALIZE REG-COD004
           MOVE GS-ORDER TO ORDEM-W
           INITIALIZE GS-DATA-BLOCK
           MOVE ORDEM-W TO GS-ORDER
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
       EXCLUI-RECORD SECTION.
           DELETE COD004.
           PERFORM LIMPAR-DADOS.
           MOVE 1 TO GRAVA-W.
       SALVAR-DADOS SECTION.
           MOVE GS-CODIGO       TO CODIGO-CO04.
           MOVE GS-DATA-INI     TO DATA-INV
           CALL "GRIDAT2" USING DATA-INV
           MOVE DATA-INV        TO DATA-INI-CO04.
           MOVE GS-DATA-FIM     TO DATA-INV
           CALL "GRIDAT2" USING DATA-INV
           MOVE DATA-INV        TO DATA-FIM-CO04.
           IF GRAVA-W = 1
              WRITE REG-COD004 INVALID KEY
                   PERFORM ERRO-GRAVACAO
           ELSE REWRITE REG-COD004 INVALID KEY
                PERFORM ERRO-GRAVACAO
               NOT INVALID KEY
                SUBTRACT 1 FROM ULT-CODIGO
           END-IF.
       ERRO-GRAVACAO SECTION.
           MOVE "ERRO GRAVA��O" TO GS-MENSAGEM-ERRO
           MOVE ST-COD004       TO GS-MENSAGEM-ERRO(23: 2)
           PERFORM LOAD-SCREENSET
           PERFORM CARREGA-MENSAGEM-ERRO
           PERFORM ACHAR-CODIGO
           SUBTRACT 1 FROM ULT-CODIGO.
       CARREGA-ULTIMOS SECTION.
           MOVE "CLEAR-LIST-BOX" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           IF GS-ORDER = ZEROS
              MOVE ZEROS TO DATA-INI-CO04
              START COD004 KEY IS NOT < DATA-INI-CO04
                    INVALID KEY MOVE "10" TO ST-COD004
           ELSE
             MOVE ZEROS TO CODIGO-CO04
               START COD004 KEY IS NOT < CODIGO-CO04
                 INVALID KEY MOVE "10" TO ST-COD004.
           MOVE SPACES TO GS-LINDET.
           MOVE ZEROS TO GS-CONT.
           PERFORM UNTIL ST-COD004 = "10"
              READ COD004 NEXT RECORD AT END MOVE "10" TO ST-COD004
              NOT AT END
                ADD 1 TO GS-CONT
      *         MOVE SPACES TO GS-LINDET
                MOVE CODIGO-CO04          TO GS-LINDET(01: 04)
                MOVE DATA-INI-CO04        TO DATA-INV
                CALL "GRIDAT1" USING DATA-INV
                MOVE DATA-INV             TO DATA-E
                MOVE DATA-E               TO GS-LINDET(5: 11)
                MOVE DATA-FIM-CO04        TO DATA-INV
                CALL "GRIDAT1" USING DATA-INV
                MOVE DATA-INV             TO DATA-E
                MOVE DATA-E               TO GS-LINDET(16: 10)
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
           MOVE "COP004" TO DS-SET-NAME
           PERFORM CALL-DIALOG-SYSTEM.

       IMPRIME-RELATORIO SECTION.
           OPEN OUTPUT RELAT.
           IF GS-ORDER = 1
              MOVE ZEROS TO CODIGO-CO04
              START COD004 KEY IS NOT < CODIGO-CO04 INVALID KEY
                           MOVE "10" TO ST-COD004
           ELSE MOVE ZEROS TO DATA-INI-CO04
                START COD004 KEY IS NOT < DATA-INI-CO04 INVALID KEY
                           MOVE "10" TO ST-COD004.
           MOVE ZEROS TO LIN. PERFORM CABECALHO.
           PERFORM UNTIL ST-COD004 = "10"
             READ COD004 NEXT RECORD AT END MOVE "10" TO ST-COD004
              NOT AT END
               MOVE SPACES TO LINDET-REL
                MOVE CODIGO-CO04          TO LINDET-REL(01: 04)
                MOVE DATA-INI-CO04        TO DATA-INV
                CALL "GRIDAT1" USING DATA-INV
                MOVE DATA-INV             TO DATA-E
                MOVE DATA-E               TO LINDET-REL(5: 11)
                MOVE "a"                  TO LINDET-REL(16: 2)
                MOVE DATA-FIM-CO04        TO DATA-INV
                CALL "GRIDAT1" USING DATA-INV
                MOVE DATA-INV             TO DATA-E
                MOVE DATA-E               TO LINDET-REL(18: 10)
                WRITE REG-RELAT FROM LINDET
                ADD 1 TO LIN
                IF LIN > 56 PERFORM CABECALHO
                END-IF
             END-READ
           END-PERFORM.
           MOVE SPACES TO REG-RELAT.
           WRITE REG-RELAT AFTER PAGE.
           CLOSE RELAT.
       CABECALHO SECTION.
           ADD 1 TO PAG-W.  MOVE PAG-W TO PAG-REL.
           IF PAG-W = 1
              WRITE REG-RELAT FROM CAB01
           ELSE WRITE REG-RELAT FROM CAB01 AFTER PAGE.
           WRITE REG-RELAT FROM CAB02 AFTER 2.
           WRITE REG-RELAT FROM CAB03.
           WRITE REG-RELAT FROM CAB04.
           WRITE REG-RELAT FROM CAB03.
           MOVE 4 TO LIN.
       ACHAR-CODIGO SECTION.
           MOVE ZEROS TO CODIGO-CO04 ULT-CODIGO
           START COD004 KEY IS NOT < CODIGO-CO04 INVALID KEY
                 MOVE "10" TO ST-COD004
           END-START
           PERFORM UNTIL ST-COD004 = "10"
              READ COD004 NEXT RECORD AT END MOVE "10" TO ST-COD004
                NOT AT END
                 MOVE CODIGO-CO04 TO ULT-CODIGO
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
           CLOSE COD004.
           MOVE DS-QUIT-SET TO DS-CONTROL.
           PERFORM CALL-DIALOG-SYSTEM.
           EXIT PROGRAM.

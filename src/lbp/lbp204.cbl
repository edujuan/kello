       COPY DSLANG.CPY.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LBP204.
      *DATA: 02/06/2000
      *AUTORA: MARELI AM�NCIO VOLPATO
      *PROGRAMA: RELATORIO DE AVALIA��O DE AMPLIA��O
      *FUN��O: Listar todos os trabalhos que estiverem dentro do
      *        intervalo de data solicitado. Poder� ser geral ou indiv.
       ENVIRONMENT DIVISION.
       class-control.
           Window             is class "wclass".
       SPECIAL-NAMES.
         DECIMAL-POINT IS COMMA
         PRINTER IS LPRINTER.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY CGPX001.
           COPY LBPX025.
           COPY LBPX027.
           COPY LBPX103.
           COPY LBPX104.

           SELECT WORK ASSIGN TO VARIA-W
                  ORGANIZATION IS INDEXED
                  ACCESS MODE IS DYNAMIC
                  STATUS IS ST-WORK
                  RECORD KEY IS SEQ-WK
                  ALTERNATE RECORD KEY IS DATA-MOVTO-WK WITH DUPLICATES
                  ALTERNATE RECORD KEY IS FUNCIONARIO-WK WITH DUPLICATES
                  ALTERNATE RECORD KEY IS TIPO-PROB-WK WITH DUPLICATES
                  ALTERNATE RECORD KEY IS TIPO-FOTO-WK WITH DUPLICATES.

           SELECT RELAT ASSIGN TO PRINTER NOME-IMPRESSORA.


       DATA DIVISION.
       FILE SECTION.
       COPY CGPW001.
       COPY LBPW025.
       COPY LBPW027.
       COPY LBPW103.
       COPY LBPW104.
       FD  WORK.
       01  REG-WORK.
           05  SEQ-WK              PIC 9(4).
           05  DATA-MOVTO-WK       PIC 9(8).
           05  FUNCIONARIO-WK      PIC X(20).
           05  QT-FOTOS-WK         PIC 9(4).
           05  QT-PROB-WK          PIC 9(4).
           05  TIPO-FOTO-WK        PIC X(20).
      *    05  FOTO-PROB-WK        PIC 9(4).
           05  TIPO-PROB-WK        PIC X(20).
           05  PERC-WK             PIC 99V99.
       FD  RELAT
           LABEL RECORD IS OMITTED.
       01  REG-RELAT.
           05  FILLER              PIC X(130).
       WORKING-STORAGE SECTION.
           COPY IMPRESSORA.
           COPY "LBP204.CPB".
           COPY "LBP204.CPY".
           COPY "CBDATA.CPY".
           COPY "CPTIME.CPY".
           COPY "DS-CNTRL.MF".
           COPY "CBPRINT.CPY".
       01  PASSAR-PARAMETROS.
           05  PASSAR-STRING-1       PIC X(60).
       78  REFRESH-TEXT-AND-DATA-PROC VALUE 255.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  VARIAVEIS.
           05  ST-CGD001             PIC XX       VALUE SPACES.
           05  ST-LBD025             PIC XX       VALUE SPACES.
           05  ST-LBD027             PIC XX       VALUE SPACES.
           05  ST-LBD103             PIC XX       VALUE SPACES.
           05  ST-LBD104             PIC XX       VALUE SPACES.
           05  ST-WORK               PIC XX       VALUE SPACES.
           05  ERRO-W                PIC 9        VALUE ZEROS.
           05  LIN                   PIC 99       VALUE ZEROS.
           05  PAG-W                 PIC 99       VALUE ZEROS.
           05  EMP-REFERENCIA.
               10  FILLER            PIC X(15)
                   VALUE "\PROGRAMA\KELLO".
               10  VAR1              PIC X VALUE "\".
               10  EMP-REC           PIC XXX.
               10  VAR2              PIC X VALUE "\".
               10  ARQ-REC           PIC X(10).
           05  EMPRESA-REF REDEFINES EMP-REFERENCIA PIC X(30).
           05  VARIA-W               PIC 9(8)     VALUE ZEROS.
           05  DATA-INI              PIC 9(8)     VALUE ZEROS.
           05  DATA-FIM              PIC 9(8)     VALUE ZEROS.
           05  DATA-INI-ANT          PIC 9(8)     VALUE ZEROS.
           05  DATA-FIM-ANT          PIC 9(8)     VALUE ZEROS.
           05  DATA-E                PIC 99/99/9999 BLANK WHEN ZEROS.
           05  VALOR-E               PIC ZZ.ZZZ.ZZZ,ZZ BLANK WHEN ZEROS.
           05  PERC-E                PIC ZZ,ZZ    BLANK WHEN ZEROS.
      *    OPCAO INDIVIDUAL
           05  GRAVAR-OPCAO          PIC 9        VALUE ZEROS.
           05  CODIGO-W              PIC 9(2)     VALUE ZEROS.
           05  CODIGO-W1             PIC 9(3)     VALUE ZEROS.

      *    CONTROLE DE QUEBRA
           05  DATA-MOVTO-ANT        PIC 9(8)     VALUE ZEROS.
           05  FUNCIONARIO-ANT       PIC X(15)    VALUE SPACES.
           05  TIPO-PROB-ANT       PIC X(15)    VALUE SPACES.
           05  TIPO-FOTO-ANT         PIC X(10)    VALUE SPACES.
      *    TOTALIZA VARIAVEIS
           05  TOTAL-FOTO            PIC 9(7)     VALUE ZEROS.
           05  TOTAL-FOTO-PROB       PIC 9(8)     VALUE ZEROS.
           05  TOTAL-FOTO-G          PIC 9(8)     VALUE ZEROS.
           05  TOTAL-FOTO-PROB-G     PIC 9(7)     VALUE ZEROS.
           05  QTDE-E                PIC ZZZZ.ZZZ.
           05  DATA-MOVTO-W          PIC 9(8)     VALUE ZEROS.
           05  DATA-DIA-I            PIC 9(8)     VALUE ZEROS.
           05  PASSAR-STRING         PIC X(20)    VALUE SPACES.
           COPY "PARAMETR".

       77 janelaPrincipal              object reference.
       77 handle8                      pic 9(08) comp-x value zeros.
       77 wHandle                      pic 9(09) comp-5 value zeros.

       01  CAB01.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  EMPRESA-REL         PIC X(70)   VALUE SPACES.
           05  FILLER              PIC X(12)   VALUE "EMISSAO/HR: ".
           05  EMISSAO-REL         PIC 99/99/9999 BLANK WHEN ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  HORA-REL            PIC X(5)    VALUE "  :  ".
           05  FILLER              PIC X(10)   VALUE SPACES.
           05  FILLER              PIC X(5)    VALUE "PAG: ".
           05  PG-REL              PIC Z9      VALUE ZEROS.
       01  CAB02.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  FILLER              PIC X(43)   VALUE
           "RELATORIO DE AVALIACAO DE AMPLIACAO-ORDEM: ".
           05  ORDEM-REL           PIC X(18)   VALUE SPACES.
           05  FILLER              PIC X(10)    VALUE SPACES.
           05  FILLER              PIC X(16)   VALUE "INT.DATA MOVTO: ".
           05  DATA-INI-REL        PIC 99/99/9999.
           05  FILLER              PIC X(3)    VALUE ' a '.
           05  DATA-FIM-REL        PIC 99/99/9999.
       01  CAB03.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  FILLER              PIC X(110) VALUE ALL "=".
       01  CAB04.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  FILLER              PIC X(110)  VALUE
           "DATA-MOVTO FUNCIONARIO          TIPO-FOTO            QT-FOTO
      -    "S FOTO.PROB TIPO-PROBLEMA         PERC".
       01  LINDET.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  LINDET-REL          PIC X(110)  VALUE SPACES.

       PROCEDURE DIVISION.

       MAIN-PROCESS SECTION.
           PERFORM INICIALIZA-PROGRAMA.
           PERFORM CORPO-PROGRAMA UNTIL GS-EXIT-FLG-TRUE.
           GO FINALIZAR-PROGRAMA.

       INICIALIZA-PROGRAMA SECTION.
           ACCEPT PARAMETROS-W FROM COMMAND-LINE.
           COPY "CBDATA1.CPY".
           MOVE DATA-INV TO DATA-MOVTO-W.
           CALL "GRIDAT2" USING DATA-INV.
           MOVE DATA-INV       TO DATA-DIA-I.
           MOVE ZEROS TO ERRO-W.
           INITIALIZE GS-DATA-BLOCK
           INITIALIZE DS-CONTROL-BLOCK
           MOVE GS-DATA-BLOCK-VERSION-NO
                                   TO DS-DATA-BLOCK-VERSION-NO
           MOVE GS-VERSION-NO  TO DS-VERSION-NO
           MOVE EMPRESA-W          TO EMP-REC
           MOVE NOME-EMPRESA-W     TO EMPRESA-REL
           MOVE "CGD001"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CGD001.
           MOVE "LBD025"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-LBD025.
           MOVE "LBD027"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-LBD027.
           MOVE "LBD103"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-LBD103.
           MOVE "LBD104"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-LBD104.
           OPEN INPUT CGD001 LBD025 LBD027 LBD104 LBD103.
           IF ST-LBD025 <> "00"
              MOVE "ERRO ABERTURA LBD025: "  TO GS-MENSAGEM-ERRO
              MOVE ST-LBD025 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LBD027 <> "00"
              MOVE "ERRO ABERTURA LBD027: "  TO GS-MENSAGEM-ERRO
              MOVE ST-LBD027 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LBD103 <> "00"
              MOVE "ERRO ABERTURA LBD103: "  TO GS-MENSAGEM-ERRO
              MOVE ST-LBD103 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LBD104 <> "00"
              MOVE "ERRO ABERTURA LBD104: "  TO GS-MENSAGEM-ERRO
              MOVE ST-LBD104 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CGD001 <> "00"
              MOVE "ERRO ABERTURA CGD001: "  TO GS-MENSAGEM-ERRO
              MOVE ST-CGD001 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF COD-USUARIO-W NOT NUMERIC
              MOVE "Executar pelo MENU" TO GS-MENSAGEM-ERRO
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ERRO-W = ZEROS
              PERFORM LOAD-SCREENSET.

       CORPO-PROGRAMA SECTION.
           EVALUATE TRUE
               WHEN GS-CENTRALIZA-TRUE
                    PERFORM CENTRALIZAR
               WHEN GS-PRINTER-FLG-TRUE
                    COPY IMPRESSORA.CHAMA.
                    IF LNK-MAPEAMENTO <> SPACES
                       PERFORM IMPRIME-RELATORIO
                    END-IF
               WHEN GS-GRAVA-WORK-FLG-TRUE
                    PERFORM GRAVA-WORK
                    PERFORM ZERA-VARIAVEIS
                    PERFORM CARREGA-LISTA
               WHEN GS-CARREGA-LISTA-FLG-TRUE
                    PERFORM ZERA-VARIAVEIS
                    PERFORM CARREGA-LISTA
               WHEN GS-LER-INDIVIDUAL-TRUE
                    PERFORM LER-CODIGOS
               WHEN GS-OPCAO-POP-UP-TRUE
                    PERFORM LER-POPUP
           END-EVALUATE
           PERFORM CLEAR-FLAGS.
           PERFORM CALL-DIALOG-SYSTEM.

       CENTRALIZAR SECTION.
          move-object-handle principal handle8
          move handle8 to wHandle
          invoke Window "fromHandleWithClass" using wHandle Window
                 returning janelaPrincipal

          invoke janelaPrincipal "CentralizarNoDesktop".


       CARREGA-MENSAGEM-ERRO SECTION.
           PERFORM LOAD-SCREENSET.
           MOVE "EXIBE-ERRO" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE 1 TO ERRO-W.
       LIMPAR-DADOS SECTION.
           INITIALIZE GS-DATA-BLOCK
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
       LER-CODIGOS SECTION.
           EVALUATE GS-OPCAO-INDIVIDUAL
             WHEN 1 MOVE GS-CODIGO TO CODIGO-CG01
                 READ CGD001 INVALID KEY MOVE SPACES TO NOME-CG01
                 END-READ
                 MOVE NOME-CG01    TO GS-DESCRICAO
             WHEN 2 MOVE GS-CODIGO TO CODIGO-LB25
                 READ LBD025 INVALID KEY MOVE SPACES TO DESCRICAO-LB25
                 END-READ
                 MOVE DESCRICAO-LB25 TO GS-DESCRICAO
             WHEN 3 MOVE GS-CODIGO TO CODIGO-LB27
                 READ LBD027 INVALID KEY MOVE SPACES TO DESCRICAO-LB27
                 END-READ
                 MOVE DESCRICAO-LB27 TO GS-DESCRICAO
           END-EVALUATE.

       LER-POPUP SECTION.
           EVALUATE GS-OPCAO-INDIVIDUAL
             WHEN 1 CALL   "CGP001T" USING PARAMETROS-W PASSAR-STRING-1
                    CANCEL "CGP001T"
                    MOVE PASSAR-STRING-1(1: 30)  TO GS-DESCRICAO
                    MOVE PASSAR-STRING-1(33: 6)  TO GS-CODIGO
             WHEN 2 CALL   "LBP025T" USING PARAMETROS-W PASSAR-STRING-1
                    CANCEL "LBP025T"
                    MOVE PASSAR-STRING-1(1: 30)  TO GS-DESCRICAO
                    MOVE PASSAR-STRING-1(33: 3)  TO GS-CODIGO
             WHEN 3 CALL   "LBP027T" USING PARAMETROS-W PASSAR-STRING-1
                    CANCEL "LBP027T"
                    MOVE PASSAR-STRING-1(1: 20)  TO GS-DESCRICAO
                    MOVE PASSAR-STRING-1(33: 2)  TO GS-CODIGO
           END-EVALUATE.

       GRAVA-WORK SECTION.
           IF ST-WORK NOT = "35" CLOSE WORK   DELETE FILE WORK.
           ACCEPT VARIA-W FROM TIME.
           OPEN OUTPUT WORK.  CLOSE WORK.  OPEN I-O WORK.
           MOVE "TELA-AGUARDA" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE GS-DATA-INI    TO DATA-INV DATA-INI-ANT DATA-INI-REL.
           CALL "GRIDAT2" USING DATA-INV.
           MOVE DATA-INV       TO DATA-INI.
           MOVE GS-DATA-FIM    TO DATA-INV DATA-FIM-ANT DATA-FIM-REL.
           CALL "GRIDAT2" USING DATA-INV.
           MOVE DATA-INV       TO DATA-FIM.
      *    VERIFICA OPCAO DO RELATORIO - INDIV OU GERAL
           MOVE DATA-INI       TO DATA-MOVTO-L104
           MOVE GS-CODIGO      TO CODIGO-W CODIGO-W1
           EVALUATE GS-OPCAO-INDIVIDUAL
             WHEN 0 MOVE ZEROS TO SEQ-L104
                    START LBD104 KEY IS NOT < CHAVE-L104 INVALID KEY
                          MOVE "10" TO ST-LBD104
             WHEN 1 MOVE GS-CODIGO TO FUNCIONARIO-L104
                    START LBD104 KEY IS NOT < ALT1-L104 INVALID KEY
                          MOVE "10" TO ST-LBD104
             WHEN 2 MOVE CODIGO-W1 TO TIPO-PROBLEMA-L104
                    START LBD104 KEY IS NOT < ALT3-L104 INVALID KEY
                          MOVE "10" TO ST-LBD104
             WHEN 3 MOVE CODIGO-W TO TIPO-FOTO-L104
                    START LBD104 KEY IS NOT < ALT2-L104 INVALID KEY
                          MOVE "10" TO ST-LBD104
           END-EVALUATE.

           MOVE ZEROS          TO SEQ-WK.
           PERFORM UNTIL ST-LBD104 = "10"
             READ LBD104 NEXT RECORD AT END MOVE "10" TO ST-LBD104
              NOT AT END
               IF DATA-MOVTO-L104 > DATA-FIM
                  MOVE "10" TO ST-LBD104
               ELSE
                PERFORM VERIFICA-OPCAO
                IF GRAVAR-OPCAO = ZEROS MOVE "10" TO ST-LBD104
                                       CONTINUE
                ELSE
                 ADD 1                   TO SEQ-WK
                 MOVE DATA-MOVTO-L104    TO DATA-MOVTO-WK
                                            GS-EXIBE-VENCTO
                 MOVE "TELA-AGUARDA1"    TO DS-PROCEDURE
                 PERFORM CALL-DIALOG-SYSTEM
                 MOVE FUNCIONARIO-L104   TO CODIGO-CG01
                 READ CGD001 INVALID KEY MOVE SPACES TO NOME-CG01
                 END-READ
                 MOVE NOME-CG01          TO FUNCIONARIO-WK
                 MOVE QTDE-FOTOS-L104    TO QT-FOTOS-WK
                 MOVE FOTOS-PROB-L104    TO QT-PROB-WK

                 MOVE TIPO-FOTO-L104    TO CODIGO-LB27
                 READ LBD027 INVALID KEY MOVE SPACES TO DESCRICAO-LB27
                 END-READ
                 MOVE DESCRICAO-LB27     TO TIPO-FOTO-WK
                 MOVE TIPO-PROBLEMA-L104 TO CODIGO-LB25
                 READ LBD025 INVALID KEY MOVE SPACES TO DESCRICAO-LB25
                 END-READ
                 MOVE DESCRICAO-LB25     TO TIPO-PROB-WK
                 COMPUTE PERC-WK = (QT-PROB-WK * 100) / QT-FOTOS-WK
                 WRITE REG-WORK
                END-IF
               END-IF
             END-READ
           END-PERFORM.
           MOVE "TELA-AGUARDA2" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
       VERIFICA-OPCAO SECTION.
           MOVE GS-CODIGO TO CODIGO-W CODIGO-W1.
           MOVE 0 TO GRAVAR-OPCAO
           EVALUATE GS-OPCAO-INDIVIDUAL
             WHEN 0 MOVE 1 TO GRAVAR-OPCAO
             WHEN 1 IF GS-CODIGO = FUNCIONARIO-L104
                       MOVE 1 TO GRAVAR-OPCAO
             WHEN 2 IF CODIGO-W1 = TIPO-PROBLEMA-L104
                       MOVE 1 TO GRAVAR-OPCAO
             WHEN 3 IF CODIGO-W = TIPO-FOTO-L104
                       MOVE 1 TO GRAVAR-OPCAO
           END-EVALUATE.

       CARREGA-LISTA SECTION.
           MOVE "CLEAR-LIST-BOX" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE SPACES TO GS-LINDET.
           PERFORM ORDEM.
           PERFORM ZERA-VARIAVEIS.
           MOVE "REFRESH-DATA" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           PERFORM UNTIL ST-WORK = "10"
              READ WORK NEXT RECORD AT END MOVE "10" TO ST-WORK
              NOT AT END
                  PERFORM MOVER-DADOS-LINDET
              END-READ
           END-PERFORM.
           PERFORM TOTALIZA
           MOVE "TOTAL GERAL: " TO GS-LINDET(1: 30)
           MOVE TOTAL-FOTO-G           TO QTDE-E
           MOVE QTDE-E                 TO GS-LINDET(54: 9)
           MOVE TOTAL-FOTO-PROB-G      TO QTDE-E
           MOVE QTDE-E                 TO GS-LINDET(63: 10)


           MOVE "INSERE-LIST" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.

           MOVE SPACES TO GS-LINDET
           MOVE "INSERE-LIST" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.

       ORDEM SECTION.
           INITIALIZE REG-WORK.
           EVALUATE GS-ORDEM
             WHEN 1
                MOVE "DATA-MOVTO" TO GS-DESCR-ORDEM
                START WORK KEY IS NOT < DATA-MOVTO-WK INVALID KEY
                      MOVE "10" TO ST-WORK
             WHEN 2
                MOVE "FUNCIONARIO   " TO GS-DESCR-ORDEM
                START WORK KEY IS NOT < FUNCIONARIO-WK INVALID KEY
                      MOVE "10" TO ST-WORK
             WHEN 3
                MOVE "TIPO-FOTO" TO GS-DESCR-ORDEM
                START WORK KEY IS NOT < TIPO-FOTO-WK INVALID KEY
                      MOVE "10" TO ST-WORK
             WHEN 4
                MOVE "TIPO-PROBLEMA " TO GS-DESCR-ORDEM
                START WORK KEY IS NOT < TIPO-PROB-WK INVALID KEY
                      MOVE "10" TO ST-WORK

           END-EVALUATE.
       MOVER-DADOS-LINDET SECTION.
           EVALUATE GS-ORDEM
             WHEN 1
              IF DATA-MOVTO-ANT NOT = ZEROS
                 IF DATA-MOVTO-ANT NOT = DATA-MOVTO-WK
                    PERFORM TOTALIZA
             WHEN 2
              IF FUNCIONARIO-ANT  NOT = SPACES
                 IF FUNCIONARIO-ANT NOT = FUNCIONARIO-WK
                    PERFORM TOTALIZA
             WHEN 3
              IF TIPO-FOTO-ANT NOT = SPACES
                 IF TIPO-FOTO-ANT NOT = TIPO-FOTO-WK
                    PERFORM TOTALIZA
             WHEN 4
              IF TIPO-PROB-ANT NOT = SPACES
                 IF TIPO-PROB-ANT NOT = TIPO-PROB-WK
                    PERFORM TOTALIZA
           END-EVALUATE.
           PERFORM MOVER-CHAVE-ANT.
           PERFORM MOVER-DADOS.
           MOVE "INSERE-LIST" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
       MOVER-DADOS SECTION.
           MOVE DATA-MOVTO-WK     TO DATA-INV
           CALL "GRIDAT1" USING DATA-INV
           MOVE DATA-INV               TO DATA-E
           MOVE DATA-E                 TO GS-LINDET(1: 11)
           MOVE FUNCIONARIO-WK         TO GS-LINDET(12: 21)
           MOVE TIPO-FOTO-WK           TO GS-LINDET(33: 21)
           MOVE QT-FOTOS-WK            TO QTDE-E
           ADD QT-FOTOS-WK             TO TOTAL-FOTO
           MOVE QTDE-E                 TO GS-LINDET(54: 9)
           MOVE QT-PROB-WK             TO QTDE-E
           MOVE QTDE-E                 TO GS-LINDET(63: 10)
           ADD QT-PROB-WK              TO TOTAL-FOTO-PROB
           MOVE TIPO-PROB-WK           TO GS-LINDET(73: 21)
           IF PERC-WK NOT NUMERIC MOVE ZEROS TO PERC-WK.
           MOVE PERC-WK                TO PERC-E
           MOVE PERC-E                 TO GS-LINDET(94: 5).
       ZERA-VARIAVEIS SECTION.
           MOVE ZEROS TO DATA-MOVTO-ANT.
           MOVE SPACES TO FUNCIONARIO-ANT TIPO-PROB-ANT TIPO-FOTO-ANT.
           MOVE ZEROS TO TOTAL-FOTO-G TOTAL-FOTO-PROB-G.
           PERFORM ZERA-SUBTOTAL.

       ZERA-SUBTOTAL SECTION.
           MOVE ZEROS TO TOTAL-FOTO TOTAL-FOTO-PROB.

       MOVER-CHAVE-ANT SECTION.
           MOVE DATA-MOVTO-WK          TO DATA-MOVTO-ANT.
           MOVE FUNCIONARIO-WK         TO FUNCIONARIO-ANT.
           MOVE TIPO-PROB-WK       TO TIPO-PROB-ANT
           MOVE TIPO-FOTO-WK           TO TIPO-FOTO-ANT.
       TOTALIZA SECTION.
           MOVE SPACES                 TO GS-LINDET
           MOVE TOTAL-FOTO             TO QTDE-E
           MOVE QTDE-E                 TO GS-LINDET(54: 9)
           MOVE TOTAL-FOTO-PROB        TO QTDE-E
           MOVE QTDE-E                 TO GS-LINDET(63: 10)

           ADD TOTAL-FOTO              TO TOTAL-FOTO-G
           ADD TOTAL-FOTO-PROB         TO TOTAL-FOTO-PROB-G

           PERFORM ZERA-SUBTOTAL.
           MOVE "INSERE-LIST" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.

           MOVE SPACES TO GS-LINDET
           MOVE "INSERE-LIST" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.

       CLEAR-FLAGS SECTION.
           INITIALIZE GS-FLAG-GROUP.
       SET-UP-FOR-REFRESH-SCREEN SECTION.
           MOVE "REFRESH-DATA" TO DS-PROCEDURE.

       LOAD-SCREENSET SECTION.
           MOVE DS-PUSH-SET TO DS-CONTROL
           MOVE "LBP204" TO DS-SET-NAME
           PERFORM CALL-DIALOG-SYSTEM.

       IMPRIME-RELATORIO SECTION.
           MOVE ZEROS TO PAG-W.

           COPY CONDENSA.

           PERFORM ORDEM.
           PERFORM ZERA-VARIAVEIS.
           MOVE ZEROS TO LIN. PERFORM CABECALHO.
           MOVE SPACES TO LINDET-REL
           PERFORM UNTIL ST-WORK = "10"
              READ WORK NEXT RECORD AT END MOVE "10" TO ST-WORK
              NOT AT END
                      PERFORM MOVER-DADOS-RELATORIO
              END-READ
           END-PERFORM.
           PERFORM TOTALIZA-REL

           MOVE SPACES          TO LINDET-REL

           MOVE "TOTAL GERAL: "        TO LINDET-REL(1: 30)
           MOVE TOTAL-FOTO-G           TO QTDE-E
           MOVE QTDE-E                 TO LINDET-REL(54: 9)
           MOVE TOTAL-FOTO-PROB-G      TO QTDE-E
           MOVE QTDE-E                 TO LINDET-REL(63: 10)

           WRITE REG-RELAT FROM LINDET
           ADD 1 TO LIN.

           COPY DESCONDENSA.

       MOVER-DADOS-RELATORIO SECTION.
           EVALUATE GS-ORDEM
             WHEN 1
              IF DATA-MOVTO-ANT NOT = ZEROS
                 IF DATA-MOVTO-ANT NOT = DATA-MOVTO-WK
                    PERFORM TOTALIZA-REL
             WHEN 2
              IF FUNCIONARIO-ANT  NOT = SPACES
                 IF FUNCIONARIO-ANT NOT = FUNCIONARIO-WK
                    PERFORM TOTALIZA-REL
             WHEN 3
              IF TIPO-FOTO-ANT NOT = SPACES
                 IF TIPO-FOTO-ANT NOT = TIPO-FOTO-WK
                    PERFORM TOTALIZA-REL
             WHEN 4
              IF TIPO-PROB-ANT NOT = SPACES
                 IF TIPO-PROB-ANT NOT = TIPO-PROB-WK
                    PERFORM TOTALIZA-REL
           END-EVALUATE.
           PERFORM MOVER-CHAVE-ANT.
           PERFORM MOVER-DADOS
           MOVE GS-LINDET TO LINDET-REL

           WRITE REG-RELAT FROM LINDET.
           ADD 1 TO LIN.
           IF LIN > 56 PERFORM CABECALHO.
       TOTALIZA-REL SECTION.
           MOVE SPACES                 TO LINDET-REL
           MOVE TOTAL-FOTO             TO QTDE-E
           MOVE QTDE-E                 TO LINDET-REL(54: 9)
           MOVE TOTAL-FOTO-PROB        TO QTDE-E
           MOVE QTDE-E                 TO LINDET-REL(63: 10)

           ADD TOTAL-FOTO              TO TOTAL-FOTO-G
           ADD TOTAL-FOTO-PROB         TO TOTAL-FOTO-PROB-G

           PERFORM ZERA-SUBTOTAL.
           WRITE REG-RELAT FROM LINDET-REL.
           ADD 1 TO LIN.

           MOVE SPACES TO LINDET-REL.
           WRITE REG-RELAT FROM LINDET-REL.
           ADD 1 TO LIN.
           IF LIN > 56 PERFORM CABECALHO.
       CABECALHO SECTION.
           MOVE GS-DESCR-ORDEM TO ORDEM-REL.
           ADD 1 TO LIN PAG-W.
           MOVE PAG-W TO PG-REL.
           IF LIN = 1
              WRITE REG-RELAT FROM CAB01
           ELSE WRITE REG-RELAT FROM CAB01 AFTER PAGE.
           WRITE REG-RELAT FROM CAB02 AFTER 2.
           WRITE REG-RELAT FROM CAB03.
           WRITE REG-RELAT FROM CAB04.
           WRITE REG-RELAT FROM CAB03.
           MOVE 6 TO LIN.
       CALL-DIALOG-SYSTEM SECTION.
           CALL "DSRUN" USING DS-CONTROL-BLOCK, GS-DATA-BLOCK.
           IF NOT DS-NO-ERROR
              MOVE DS-ERROR-CODE TO DISPLAY-ERROR-NO
              DISPLAY "DS ERROR NO:  " DISPLAY-ERROR-NO
             GO FINALIZAR-PROGRAMA
           END-IF.
       FINALIZAR-PROGRAMA SECTION.
           CLOSE LBD025 LBD027 LBD104 CGD001.
           CLOSE WORK.  DELETE FILE WORK.

           MOVE DS-QUIT-SET TO DS-CONTROL
           PERFORM CALL-DIALOG-SYSTEM
           EXIT PROGRAM.

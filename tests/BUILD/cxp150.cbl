       copy dslang.cpy.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CXP150.
      *DATA: 17/03/1999
      *AUTORA: MARELI AM�NCIO VOLPATO
      *RELAT�RIO: Relat�rio de Apura��o de Resultados - Caixa - Int.dias
      *FUN��O: Relaciona todo o movimento dentro de um intervalo de
      *        dias solicitado. A conta a ser considerada 100%
      *        ser� a conta 1.01.00.00(260)-Entrada de recursos. As
      *        percentagens ser�o arredondadas.
       ENVIRONMENT DIVISION.
       SPECIAL-NAMES.
         DECIMAL-POINT IS COMMA
         PRINTER IS LPRINTER.
       class-control.
           Window             is class "wclass".

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY CXPX020.
           COPY CXPX100.
           SELECT WORK ASSIGN TO VARIA-W
                  ORGANIZATION IS INDEXED
                  ACCESS MODE IS DYNAMIC
                  RECORD KEY IS CONTA-WK
                  ALTERNATE RECORD KEY IS CONTA-REDUZ-WK
                  STATUS IS ST-WORK.

           SELECT RELAT ASSIGN TO PRINTER NOME-IMPRESSORA.

           SELECT EXCEL ASSIGN TO ARQUIVO-EXCEL
                        ORGANIZATION IS SEQUENTIAL
                        ACCESS MODE IS SEQUENTIAL.


       DATA DIVISION.
       FILE SECTION.
       COPY CXPW020.
       COPY CXPW100.
       FD  WORK.
       01  REG-WORK.
           05  CONTA-WK        PIC 9(7).
           05  CONTA-REDUZ-WK  PIC 9(5).
           05  VALOR-WK        PIC S9(8)V99.
           05  GRAU-WK         PIC 9.
       FD  RELAT
           LABEL RECORD IS OMITTED.
       01  REG-RELAT.
           05  FILLER              PIC X(130).

       FD EXCEL.
       01 REG-EXCEL.
          05 EXCEL-CONTA1          PIC X(60).
          05 FILLER                PIC X(01) VALUE ";".
          05 EXCEL-CONTA2          PIC X(60).
          05 FILLER                PIC X(01) VALUE ";".
          05 EXCEL-CONTA3          PIC X(60).
          05 FILLER                PIC X(01) VALUE ";".
          05 EXCEL-CONTA4          PIC X(60).
          05 FILLER                PIC X(01) VALUE ";".
          05 EXCEL-TOTAL           PIC X(15).
          05 FILLER                PIC X(01) VALUE ";".
          05 EXCEL-PERCENTUAL      PIC X(12).
          05 FILLER                PIC X(02) VALUE X"0DA0".

       WORKING-STORAGE SECTION.
           COPY IMPRESSORA.
           COPY "CXP150.CPB".
           COPY "CXP150.CPY".
           COPY "CBDATA.CPY".
           COPY "DS-CNTRL.MF".
           COPY "CBPRINT.CPY".
       78  REFRESH-TEXT-AND-DATA-PROC VALUE 255.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  VARIAVEIS.
           05  ST-CXD020             PIC XX       VALUE SPACES.
           05  ST-CXD100             PIC XX       VALUE SPACES.
           05  ST-WORK               PIC XX       VALUE SPACES.
           05  ERRO-W                PIC 9        VALUE ZEROS.
           05  PAG-W                 PIC 99       VALUE ZEROS.
           05  LIN                   PIC 9(02)    VALUE ZEROS.
           05  VARIA-W               PIC 9(8)     VALUE ZEROS.
           05  EMP-REFERENCIA.
               10  FILLER            PIC X(15)
                   VALUE "\PROGRAMA\KELLO".
               10  VAR1              PIC X VALUE "\".
               10  EMP-REC           PIC XXX.
               10  VAR2              PIC X VALUE "\".
               10  ARQ-REC           PIC X(10).
           05  EMPRESA-REF REDEFINES EMP-REFERENCIA PIC X(30).
           05  MESANO-INI            PIC 9(6)     VALUE ZEROS.
           05  MESANO-FIM            PIC 9(6)     VALUE ZEROS.
           05  DATA-E                PIC 99/99/9999 BLANK WHEN ZEROS.
           05  VALOR-E               PIC ZZ.ZZZ.ZZZ,ZZ-.
           05  CONTA-E               PIC 9.99.99.99.
           05  DATA-MOVTO-W          PIC 9(8)     VALUE ZEROS.
           05  VALOR-ENT             PIC 9(8)V99  VALUE ZEROS.
           05  VALOR-SAI             PIC 9(8)V99  VALUE ZEROS.
           05  MESANO-I              PIC 9(6)     VALUE ZEROS.
           05  MESANO-CORRENTE       PIC 9(6)     VALUE ZEROS.
      *  MES/ANO CORRENTE - LER� O SALDO A PARTIR DO ARQUIVO CXD100
      *      ENQUANTO OS DEMAIS DO CXD040(ARQUIVO DE SALDO)
           05  SALDO-FINAL           PIC S9(8)V99 VALUE ZEROS.
           05  DATA-INI              PIC 9(8)     VALUE ZEROS.
           05  DATA-FIM              PIC 9(8)     VALUE ZEROS.
           05  TOTAL-PERC            PIC 9(8)V99  VALUE ZEROS.
           05  PERC-W                PIC 999V99   VALUE ZEROS.
           05  PERC-E                PIC ZZZ,ZZ.
           COPY "PARAMETR".

       77 janelaPrincipal              object reference.
       77 handle8                      pic 9(08) comp-x value zeros.
       77 wHandle                      pic 9(09) comp-5 value zeros.

       01  CAB01.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  EMPRESA-REL         PIC X(59)   VALUE SPACES.
           05  FILLER              PIC X(12)   VALUE "EMISSAO/HR: ".
           05  EMISSAO-REL         PIC 99/99/9999 BLANK WHEN ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  HORA-REL            PIC X(5)    VALUE "  :  ".
           05  FILLER              PIC X(11)   VALUE SPACES.
           05  FILLER              PIC X(5)    VALUE "PAG: ".
           05  PG-REL              PIC Z9      VALUE ZEROS.
       01  CAB02.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  FILLER              PIC X(46)   VALUE
           "APURACAO DE RESULTADOS - INT.DIAS".
           05  FILLER              PIC X(21)   VALUE SPACES.
           05  FILLER              PIC X(15)   VALUE "INTERV. MOVTO: ".
           05  DATA-INI-REL        PIC 99/99/9999.
           05  FILLER              PIC X(3)    VALUE ' a '.
           05  DATA-FIM-REL        PIC 99/99/9999.
       01  CAB03.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  FILLER              PIC X(105)  VALUE ALL "=".
       01  CAB04.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  FILLER              PIC X(105)  VALUE
           "DESCRICAO DAS CONTAS
      -    "                   VALOR-R$ PERC.%".
       01  LINDET.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  LINDET-REL          PIC X(105)  VALUE SPACES.
       PROCEDURE DIVISION.

       MAIN-PROCESS SECTION.
           PERFORM INICIALIZA-PROGRAMA.
           PERFORM CORPO-PROGRAMA UNTIL CXP150-EXIT-FLG-TRUE.
           GO FINALIZAR-PROGRAMA.

       INICIALIZA-PROGRAMA SECTION.
           ACCEPT PARAMETROS-W FROM COMMAND-LINE.
           COPY "CBDATA1.CPY".
           MOVE DATA-INV TO DATA-MOVTO-W.
           MOVE DATA-INV(5: 4) TO MESANO-CORRENTE(1: 4).
           MOVE DATA-INV(3: 2) TO MESANO-CORRENTE(5: 2)
           MOVE ZEROS TO ERRO-W.
           INITIALIZE CXP150-DATA-BLOCK
           INITIALIZE DS-CONTROL-BLOCK
           MOVE CXP150-DATA-BLOCK-VERSION-NO
                                   TO DS-DATA-BLOCK-VERSION-NO
           MOVE CXP150-VERSION-NO  TO DS-VERSION-NO
           MOVE EMPRESA-W          TO EMP-REC
           MOVE NOME-EMPRESA-W     TO EMPRESA-REL
           MOVE "CXD020"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CXD020.
           MOVE "CXD100"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CXD100.
           OPEN INPUT CXD100 CXD020.
           ACCEPT VARIA-W FROM TIME.
           OPEN OUTPUT WORK.
           IF ST-CXD020 <> "00"
              MOVE "ERRO ABERTURA CXD020: "  TO CXP150-MENSAGEM-ERRO
              MOVE ST-CXD020 TO CXP150-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CXD100 <> "00"
              MOVE "ERRO ABERTURA CXD100: "  TO CXP150-MENSAGEM-ERRO
              MOVE ST-CXD100 TO CXP150-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF COD-USUARIO-W NOT NUMERIC
              MOVE "Executar pelo MENU" TO CXP150-MENSAGEM-ERRO
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ERRO-W = ZEROS
              PERFORM LOAD-SCREENSET.

       CORPO-PROGRAMA SECTION.
           EVALUATE TRUE
               WHEN CXP150-CENTRALIZA-TRUE
                    PERFORM CENTRALIZAR
               WHEN CXP150-PRINTER-FLG-TRUE
                    COPY IMPRESSORA.CHAMA.
                    IF LNK-MAPEAMENTO <> SPACES
                       PERFORM IMPRIME-RELATORIO
                    END-IF
               WHEN CXP150-CARREGA-LISTA-FLG-TRUE
                    PERFORM CARREGA-LISTA
               WHEN CXP150-GERAR-EXCEL-TRUE
                   PERFORM GERAR-EXCEL
           END-EVALUATE.
           PERFORM CLEAR-FLAGS.
           PERFORM CALL-DIALOG-SYSTEM.

       CENTRALIZAR SECTION.
          move-object-handle principal handle8
          move handle8 to wHandle
          invoke Window "fromHandleWithClass" using wHandle Window
                 returning janelaPrincipal

          invoke janelaPrincipal "CentralizarNoDesktop".

       GERAR-EXCEL SECTION.
           MOVE SPACES TO ARQUIVO-EXCEL

           STRING "\ARQUIVOS\APURACAO-DIA-" CXP150-DATA-INI "-"
             CXP150-DATA-FIM INTO ARQUIVO-EXCEL

           OPEN OUTPUT EXCEL
           MOVE "DESCRI��O DAS CONTAS" TO EXCEL-CONTA1
           MOVE SPACES                 TO EXCEL-CONTA2
                                          EXCEL-CONTA3
                                          EXCEL-CONTA4
           MOVE "TOTAL-CONTA"          TO EXCEL-TOTAL
           MOVE "PERC."                TO EXCEL-PERCENTUAL

           WRITE REG-EXCEL

           PERFORM INVERTE-DATA.
           PERFORM CONTA-PERCENTAGEM.
           MOVE ZEROS          TO CONTA-WK.
           START WORK KEY IS NOT < CONTA-WK  INVALID KEY
                 MOVE "10" TO ST-WORK.
           PERFORM UNTIL ST-WORK = "10"
              READ WORK NEXT RECORD AT END
                    MOVE "10" TO ST-CXD100
              NOT AT END
                    MOVE SPACES            TO CXP150-LINDET
                    MOVE CONTA-WK       TO CONTA-E
                    MOVE CONTA-REDUZ-WK TO CODIGO-REDUZ-CX20
                    READ CXD020 INVALID KEY
                           MOVE SPACES TO DESCRICAO-CX20
                           MOVE ZEROS  TO TIPO-CONTA-CX20
                    END-READ
                    IF TIPO-CONTA-CX20 = 1
                       MOVE SPACES     TO EXCEL-CONTA1
                                          EXCEL-CONTA2
                                          EXCEL-CONTA3
                                          EXCEL-CONTA4
                                          EXCEL-TOTAL
                                          EXCEL-PERCENTUAL
                       WRITE REG-EXCEL
                    END-IF
                    MOVE SPACES TO EXCEL-CONTA1 EXCEL-CONTA2
                                   EXCEL-CONTA3 EXCEL-CONTA4
                    EVALUATE GRAU-WK
                      WHEN 1 STRING CONTA-E " (" CONTA-REDUZ-WK ") "
                             DESCRICAO-CX20 INTO EXCEL-CONTA1
                      WHEN 2 STRING CONTA-E " (" CONTA-REDUZ-WK ") "
                             DESCRICAO-CX20 INTO EXCEL-CONTA2
                      WHEN 3 STRING CONTA-E " (" CONTA-REDUZ-WK ") "
                             DESCRICAO-CX20 INTO EXCEL-CONTA3
                      WHEN 4 STRING CONTA-E " (" CONTA-REDUZ-WK ") "
                             DESCRICAO-CX20 INTO EXCEL-CONTA4
                    END-EVALUATE
                    MOVE VALOR-WK          TO VALOR-E
                    MOVE VALOR-E           TO EXCEL-TOTAL
                    COMPUTE PERC-W = (VALOR-WK / TOTAL-PERC) * 100
                    MOVE PERC-W            TO PERC-E
                    MOVE PERC-E            TO EXCEL-PERCENTUAL

                    WRITE REG-EXCEL
              END-READ
           END-PERFORM.

           MOVE SPACES     TO EXCEL-CONTA1
                              EXCEL-CONTA2
                              EXCEL-CONTA3
                              EXCEL-CONTA4
                              EXCEL-TOTAL
                              EXCEL-PERCENTUAL
           WRITE REG-EXCEL

           MOVE "TOTAL GERAL..." TO EXCEL-CONTA1
           MOVE SALDO-FINAL      TO VALOR-E.
           MOVE VALOR-E          TO EXCEL-TOTAL
           COMPUTE PERC-W = (SALDO-FINAL / TOTAL-PERC) * 100.
           MOVE PERC-W           TO PERC-E.
           MOVE PERC-E           TO EXCEL-PERCENTUAL
           WRITE REG-EXCEL


           CLOSE EXCEL.

       CARREGA-MENSAGEM-ERRO SECTION.
           PERFORM LOAD-SCREENSET.
           MOVE "EXIBE-ERRO" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE 1 TO ERRO-W.
       LIMPAR-DADOS SECTION.
           INITIALIZE CXP150-DATA-BLOCK
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
       INVERTE-DATA SECTION.
           MOVE CXP150-DATA-INI    TO DATA-INI-REL DATA-INV.
           CALL "GRIDAT2" USING DATA-INV.
           MOVE DATA-INV           TO DATA-INI.
           MOVE CXP150-DATA-FIM    TO DATA-FIM-REL DATA-INV.
           CALL "GRIDAT2" USING DATA-INV.
           MOVE DATA-INV           TO DATA-FIM.
           PERFORM INICIO-WORK.
       INICIO-WORK SECTION.
           CLOSE WORK  OPEN OUTPUT WORK  CLOSE WORK  OPEN I-O WORK
      *    Grava todas as contas existentes no cxd020
           MOVE "GRAVANDO..." TO CXP150-MENSAGEM-AGUARDA.
           MOVE 1          TO CONTA-WK.
           MOVE 99999      TO CONTA-REDUZ-WK.
           MOVE 1          TO GRAU-WK.
           MOVE ZEROS      TO VALOR-WK.
           WRITE REG-WORK.
      *    Conta p/ gravar valores de contas n�o cadastradas
           MOVE ZEROS      TO CODIGO-REDUZ-CX20.
           START CXD020 KEY IS NOT < CODIGO-REDUZ-CX20 INVALID KEY
                 MOVE "10" TO ST-CXD020.
           PERFORM UNTIL ST-CXD020 = "10"
             READ CXD020 NEXT RECORD AT END MOVE "10" TO ST-CXD020
               NOT AT END
                 MOVE CODIGO-REDUZ-CX20     TO
                            CXP150-MENSAGEM-AGUARDA(12: 25)
                 MOVE "TELA-AGUARDA" TO DS-PROCEDURE
                 PERFORM CALL-DIALOG-SYSTEM
                 MOVE CODIGO-REDUZ-CX20     TO CONTA-REDUZ-WK
                 MOVE CODIGO-COMPL-CX20     TO CONTA-WK
                 MOVE GRAU-CX20             TO GRAU-WK
                 MOVE ZEROS                 TO VALOR-WK
                 WRITE REG-WORK
             END-READ
           END-PERFORM.
           MOVE ZEROS           TO SALDO-FINAL.
           MOVE DATA-INI        TO DATA-MOV-CX100
           MOVE ZEROS           TO SEQ-CX100.
           START CXD100 KEY IS NOT < CHAVE-CX100 INVALID KEY
                 MOVE "10" TO ST-CXD100.
           PERFORM UNTIL ST-CXD100 = "10"
             READ CXD100 NEXT RECORD AT END MOVE "10" TO ST-CXD100
                NOT AT END
                 IF DATA-MOV-CX100 > DATA-FIM MOVE "10" TO ST-CXD100
                 ELSE
                   IF CONTA-REDUZ-CX100 = 888 CONTINUE
                   ELSE
                      MOVE CONTA-REDUZ-CX100 TO CODIGO-REDUZ-CX20
                      READ CXD020 INVALID KEY
                           MOVE 1 TO CODIGO-COMPL-CX20
                      END-READ
                      MOVE CODIGO-COMPL-CX20 TO CONTA-WK
                      READ WORK
                      END-READ
                      MOVE CONTA-REDUZ-WK     TO
                            CXP150-MENSAGEM-AGUARDA(12: 25)
                      MOVE "TELA-AGUARDA" TO DS-PROCEDURE
                      PERFORM CALL-DIALOG-SYSTEM

                      MOVE ZEROS TO VALOR-SAI VALOR-ENT
                      IF TIPO-LCTO-CX100 < 50
                             MOVE VALOR-CX100 TO VALOR-SAI
                             SUBTRACT
                                VALOR-CX100 FROM VALOR-WK SALDO-FINAL
                      ELSE ADD VALOR-CX100 TO VALOR-WK SALDO-FINAL
                           MOVE VALOR-CX100 TO VALOR-ENT
                      END-IF
                      REWRITE REG-WORK
                      END-REWRITE
                      PERFORM TOTALIZA
                   END-IF
             END-READ
           END-PERFORM.
       TOTALIZA SECTION.
           EVALUATE GRAU-WK
             WHEN 4 MOVE ZEROS TO CONTA-WK(6: 2)
                    PERFORM TOTALIZA1
                    MOVE ZEROS TO CONTA-WK(4: 4)
                    PERFORM TOTALIZA1
                    MOVE ZEROS TO CONTA-WK(2: 6)
                    PERFORM TOTALIZA1
             WHEN 3 MOVE ZEROS TO CONTA-WK(4: 4)
                    PERFORM TOTALIZA1
                    MOVE ZEROS TO CONTA-WK(2: 6)
                    PERFORM TOTALIZA1
             WHEN 2 MOVE ZEROS TO CONTA-WK(2: 6)
                    PERFORM TOTALIZA1
           END-EVALUATE.
       TOTALIZA1 SECTION.
           READ WORK INVALID KEY CONTINUE
             NOT INVALID KEY ADD VALOR-ENT      TO VALOR-WK
                             SUBTRACT VALOR-SAI FROM VALOR-WK
                             REWRITE REG-WORK.
       CONTA-PERCENTAGEM SECTION.
           MOVE "UNSHOW-TELA-AGUARDA" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE 1010000 TO CONTA-WK.
           READ WORK INVALID KEY MOVE ZEROS TO VALOR-WK TOTAL-PERC
               NOT INVALID KEY MOVE VALOR-WK  TO TOTAL-PERC.
       CARREGA-LISTA SECTION.
           MOVE "CLEAR-LIST-BOX" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE SPACES TO CXP150-LINDET.
           PERFORM INVERTE-DATA.
           PERFORM CONTA-PERCENTAGEM.
           MOVE ZEROS          TO CONTA-WK.
           START WORK KEY IS NOT < CONTA-WK  INVALID KEY
                 MOVE "10" TO ST-WORK.
           PERFORM UNTIL ST-WORK = "10"
              READ WORK NEXT RECORD AT END MOVE "10" TO ST-CXD100
              NOT AT END
                    MOVE SPACES            TO CXP150-LINDET
                    MOVE CONTA-WK       TO CONTA-E
                    MOVE CONTA-REDUZ-WK TO CODIGO-REDUZ-CX20
                    READ CXD020 INVALID KEY
                           MOVE SPACES TO DESCRICAO-CX20
                           MOVE ZEROS  TO TIPO-CONTA-CX20
                    END-READ
                    IF TIPO-CONTA-CX20 = 1 PERFORM INSERE-LINHA-BRANCO
                    END-IF
                    EVALUATE GRAU-WK
                      WHEN 1 PERFORM GRAU1
                      WHEN 2 PERFORM GRAU2
                      WHEN 3 PERFORM GRAU3
                      WHEN 4 PERFORM GRAU4
                    END-EVALUATE
                    MOVE VALOR-WK          TO VALOR-E
                    MOVE VALOR-E           TO CXP150-LINDET(84: 14)
                    COMPUTE PERC-W = (VALOR-WK / TOTAL-PERC) * 100
                    MOVE PERC-W            TO PERC-E
                    MOVE PERC-E            TO CXP150-LINDET(99: 66)
                    MOVE "INSERE-LIST" TO DS-PROCEDURE
                    PERFORM CALL-DIALOG-SYSTEM
              END-READ
           END-PERFORM.
           MOVE SPACES TO CXP150-LINDET.
           PERFORM INSERE-LINHA-BRANCO.
           MOVE "TOTAL GERAL..." TO CXP150-LINDET(60: 14).
           MOVE SALDO-FINAL      TO VALOR-E.
           MOVE VALOR-E          TO CXP150-LINDET(84: 14).
           COMPUTE PERC-W = (SALDO-FINAL / TOTAL-PERC) * 100.
           MOVE PERC-W           TO PERC-E.
           MOVE PERC-E           TO CXP150-LINDET(99: 66).
           MOVE "INSERE-LIST"    TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
       GRAU1 SECTION.
           MOVE CONTA-E           TO CXP150-LINDET(01: 10)
           MOVE "("               TO CXP150-LINDET(12: 01)
           MOVE CONTA-REDUZ-WK    TO CXP150-LINDET(13: 05)
           MOVE ")"               TO CXP150-LINDET(18: 01).
           MOVE DESCRICAO-CX20    TO CXP150-LINDET(19: 30).
       GRAU2 SECTION.
           MOVE CONTA-E           TO CXP150-LINDET(12: 10)
           MOVE "("               TO CXP150-LINDET(23: 01)
           MOVE CONTA-REDUZ-WK    TO CXP150-LINDET(24: 05)
           MOVE ")"               TO CXP150-LINDET(29: 01).
           MOVE DESCRICAO-CX20    TO CXP150-LINDET(30: 30).
       GRAU3 SECTION.
           MOVE CONTA-E           TO CXP150-LINDET(23: 10)
           MOVE "("               TO CXP150-LINDET(34: 01)
           MOVE CONTA-REDUZ-WK    TO CXP150-LINDET(35: 05)
           MOVE ")"               TO CXP150-LINDET(40: 01).
           MOVE DESCRICAO-CX20    TO CXP150-LINDET(41: 30).
       GRAU4 SECTION.
           MOVE CONTA-E           TO CXP150-LINDET(34: 10)
           MOVE "("               TO CXP150-LINDET(45: 01)
           MOVE CONTA-REDUZ-WK    TO CXP150-LINDET(46: 05)
           MOVE ")"               TO CXP150-LINDET(51: 01).
           MOVE DESCRICAO-CX20    TO CXP150-LINDET(52: 30).
       INSERE-LINHA-BRANCO SECTION.
           MOVE "INSERE-LIST" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
       CLEAR-FLAGS SECTION.
           INITIALIZE CXP150-FLAG-GROUP.
       SET-UP-FOR-REFRESH-SCREEN SECTION.
           MOVE "REFRESH-DATA" TO DS-PROCEDURE.

       LOAD-SCREENSET SECTION.
           MOVE DS-PUSH-SET TO DS-CONTROL
           MOVE "CXP150"   TO DS-SET-NAME
           PERFORM CALL-DIALOG-SYSTEM.

       IMPRIME-RELATORIO SECTION.
           MOVE ZEROS TO PAG-W.

           COPY CONDENSA.

           MOVE ZEROS TO LIN. PERFORM CABECALHO.
           MOVE SPACES TO LINDET-REL
           MOVE ZEROS             TO CONTA-WK.
           START WORK KEY IS NOT < CONTA-WK  INVALID KEY
                 MOVE "10" TO ST-WORK.
           PERFORM UNTIL ST-WORK = "10"
              READ WORK NEXT RECORD AT END MOVE "10" TO ST-CXD100
              NOT AT END
                    MOVE SPACES            TO LINDET-REL
                    MOVE CONTA-WK          TO CONTA-E
                    MOVE CONTA-REDUZ-WK    TO CODIGO-REDUZ-CX20
                    READ CXD020 INVALID KEY
                         MOVE SPACES TO DESCRICAO-CX20
                         MOVE ZEROS  TO TIPO-CONTA-CX20
                    END-READ
                    IF TIPO-CONTA-CX20 = 1 PERFORM LINHA-BRANCO-IMP
                    END-IF
                    EVALUATE GRAU-WK
                      WHEN 1 PERFORM GRAU1-IMP
                      WHEN 2 PERFORM GRAU2-IMP
                      WHEN 3 PERFORM GRAU3-IMP
                      WHEN 4 PERFORM GRAU4-IMP
                    END-EVALUATE
                    MOVE VALOR-WK          TO VALOR-E
                    MOVE VALOR-E           TO LINDET-REL(84: 14)
                    COMPUTE PERC-W = (VALOR-WK / TOTAL-PERC) * 100
                    MOVE PERC-W            TO PERC-E
                    MOVE PERC-E            TO LINDET-REL(99: 6)
                    WRITE REG-RELAT FROM LINDET
                    ADD 1 TO LIN
                    IF LIN > 56 PERFORM CABECALHO
                    END-IF
              END-READ
           END-PERFORM.
           MOVE SPACES TO CXP150-LINDET.
           PERFORM LINHA-BRANCO-IMP.
           MOVE "TOTAL GERAL..." TO LINDET-REL(60: 14).
           MOVE SALDO-FINAL      TO VALOR-E.
           MOVE VALOR-E          TO LINDET-REL(84: 14).
           COMPUTE PERC-W = (SALDO-FINAL / TOTAL-PERC) * 100.
           MOVE PERC-W           TO PERC-E.
           MOVE PERC-E           TO LINDET-REL(99: 66).
           WRITE REG-RELAT FROM LINDET AFTER 2.

           COPY DESCONDENSA.

       GRAU1-IMP SECTION.
           MOVE CONTA-E           TO LINDET-REL(01: 10)
           MOVE "("               TO LINDET-REL(12: 01)
           MOVE CONTA-REDUZ-WK    TO LINDET-REL(13: 05)
           MOVE ")"               TO LINDET-REL(18: 01).
           MOVE DESCRICAO-CX20    TO LINDET-REL(19: 30).
       GRAU2-IMP SECTION.
           MOVE CONTA-E           TO LINDET-REL(12: 10)
           MOVE "("               TO LINDET-REL(23: 01)
           MOVE CONTA-REDUZ-WK    TO LINDET-REL(24: 05)
           MOVE ")"               TO LINDET-REL(29: 01).
           MOVE DESCRICAO-CX20    TO LINDET-REL(30: 30).
       GRAU3-IMP SECTION.
           MOVE CONTA-E           TO LINDET-REL(23: 10)
           MOVE "("               TO LINDET-REL(34: 01)
           MOVE CONTA-REDUZ-WK    TO LINDET-REL(35: 05)
           MOVE ")"               TO LINDET-REL(40: 01).
           MOVE DESCRICAO-CX20    TO LINDET-REL(41: 30).
       GRAU4-IMP SECTION.
           MOVE CONTA-E           TO LINDET-REL(34: 10)
           MOVE "("               TO LINDET-REL(45: 01)
           MOVE CONTA-REDUZ-WK    TO LINDET-REL(46: 05)
           MOVE ")"               TO LINDET-REL(51: 01).
           MOVE DESCRICAO-CX20    TO LINDET-REL(52: 30).
       LINHA-BRANCO-IMP SECTION.
           WRITE REG-RELAT FROM LINDET.
           ADD 1 TO LIN.
       CABECALHO SECTION.
           ADD 1 TO LIN PAG-W.
           MOVE PAG-W TO PG-REL.
           IF LIN = 1
              WRITE REG-RELAT FROM CAB01
           ELSE WRITE REG-RELAT FROM CAB01 AFTER PAGE.
           WRITE REG-RELAT FROM CAB02 AFTER 2.
           WRITE REG-RELAT FROM CAB03.
           WRITE REG-RELAT FROM CAB04.
           WRITE REG-RELAT FROM CAB03.
           MOVE 6 TO  LIN.
       CALL-DIALOG-SYSTEM SECTION.
           CALL "DSRUN" USING DS-CONTROL-BLOCK, CXP150-DATA-BLOCK.
           IF NOT DS-NO-ERROR
              MOVE DS-ERROR-CODE TO DISPLAY-ERROR-NO
              DISPLAY "DS ERROR NO:  " DISPLAY-ERROR-NO
             GO FINALIZAR-PROGRAMA
           END-IF.
       FINALIZAR-PROGRAMA SECTION.
           CLOSE CXD100 CXD020 WORK.
           DELETE FILE WORK.
           MOVE DS-QUIT-SET TO DS-CONTROL.
           PERFORM CALL-DIALOG-SYSTEM.
           EXIT PROGRAM.

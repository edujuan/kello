       copy dslang.cpy.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CHP070.
       DATE-WRITTEN. 02/06/1999.
       AUTHOR. MARELI AM�NCIO VOLPATO
      *PROGRAMA: Relat�rio de cheques pr�-datados POR DATA-MOVTO
      *FUN��O: Listar todos os cheques que estiverem dentro do intervalo
      *        de MOVIMENTO. As ordens ser�o: Vencto, Portador, cliente
      *        e VCTO/vcto. Altera portador atraves de senha.
      *  PROGRAMA EXCLUSIVO P/ ADALTON
       ENVIRONMENT DIVISION.
       SPECIAL-NAMES.
         DECIMAL-POINT IS COMMA
         PRINTER IS LPRINTER.
       class-control.
           Window             is class "wclass".

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY CAPX004.
           COPY CGPX010.
           COPY CHPX010.
           COPY CAPX018.
           COPY CRPX200.
           COPY CRPX201.
           COPY LOGACESS.SEL.
           SELECT WORK ASSIGN TO VARIA-W
                  ORGANIZATION IS INDEXED
                  ACCESS MODE IS DYNAMIC
                  STATUS IS ST-WORK
                  RECORD KEY IS CHAVE-WK = DATA-MOVTO-WK SEQ-WK
                  ALTERNATE RECORD KEY IS ALT-WK =
                        VENCTO-WK VALOR-WK
                            WITH DUPLICATES.
           SELECT RELAT ASSIGN TO PRINTER NOME-IMPRESSORA.


       DATA DIVISION.
       FILE SECTION.
       COPY CAPW004.
       COPY CGPW010.
       COPY CAPW018.
       COPY CHPW010.
       COPY CRPW200.
       COPY CRPW201.
       COPY LOGACESS.FD.
       FD  WORK.
       01  REG-WORK.
           05  CLASSIF-WK          PIC 9.
           05  CLIENTE-WK          PIC 9(8).
           05  DATA-MOVTO-WK       PIC 9(8).
           05  SEQ-WK              PIC 9(4).
           05  NOME-CLIEN-WK       PIC X(18).
           05  VENDEDOR-WK         PIC 9(6).
           05  CIDADE-WK           PIC X(13).
           05  BANCO-WK            PIC 9(4).
           05  AGENCIA-WK          PIC 9(5).
           05  NR-CHEQUE-WK        PIC X(7).
           05  PORTADOR-WK         PIC X(10).
           05  VENCTO-WK           PIC 9(8).
           05  VALOR-WK            PIC 9(8)V99.
           05  CARTEIRA-WK         PIC X(4).
       FD  RELAT
           LABEL RECORD IS OMITTED.
       01  REG-RELAT.
           05  FILLER              PIC X(130).
       WORKING-STORAGE SECTION.
           COPY IMPRESSORA.
           COPY "CHP070.CPB".
           COPY "CHP070.CPY".
           COPY "CBDATA.CPY".
           COPY "CPTIME.CPY".
           COPY "DS-CNTRL.MF".
           COPY "CBPRINT.CPY".
           COPY "CPDIAS1.CPY".
       01  PASSAR-PARAMETROS.
           05  PASSAR-STRING-1       PIC X(60).
       78  REFRESH-TEXT-AND-DATA-PROC VALUE 255.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  VARIAVEIS.
           05  ST-CAD004             PIC XX       VALUE SPACES.
           05  ST-CAD018             PIC XX       VALUE SPACES.
           05  ST-CHD010             PIC XX       VALUE SPACES.
           05  ST-CGD010             PIC XX       VALUE SPACES.
           05  ST-CRD200             PIC XX       VALUE SPACES.
           05  ST-CRD201             PIC XX       VALUE SPACES.
           05  ST-WORK               PIC XX       VALUE SPACES.
           05  FS-LOGACESS           PIC XX       VALUE SPACES.
           05  ERRO-W                PIC 9        VALUE ZEROS.
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
           05  LIN                   PIC 9(02).
           05  MOVTO-INI             PIC 9(8)     VALUE ZEROS.
           05  MOVTO-FIM             PIC 9(8)     VALUE ZEROS.
           05  MOVTO-INI-ANT         PIC 9(8)     VALUE ZEROS.
           05  MOVTO-FIM-ANT         PIC 9(8)     VALUE ZEROS.
           05  DATA-E                PIC 99/99/9999 BLANK WHEN ZEROS.
           05  VALOR-E               PIC ZZ.ZZZ.ZZZ,ZZ BLANK WHEN ZEROS.
           05  TIPO-PROCESSO         PIC 9        VALUE ZEROS.
      *    TIPO-PROCESSO = 0-INCLUSAO  1-ALTERA��O
           05  VENCTO-ANT            PIC 9(8)     VALUE ZEROS.
           05  TOTAL-W               PIC 9(8)V99  VALUE ZEROS.
           05  DATA-MOVTO-W          PIC 9(8)     VALUE ZEROS.
           05  DATA-DIA-I            PIC 9(8)     VALUE ZEROS.
           05  SENHA-W1              PIC 9(4)     COMP-3.
           05  ULT-SEQ               PIC 9(5)     VALUE ZEROS.
      *    variaveis p/ calcular o prazo-medio
      *    05  TOTAL-GERAL-PM        PIC 9(11)V99  VALUE ZEROS.
           05  PASSAR-STRING         PIC X(30)    VALUE SPACES.
           COPY "PARAMETR".

       77 janelaPrincipal              object reference.
       77 handle8                      pic 9(08) comp-x value zeros.
       77 wHandle                      pic 9(09) comp-5 value zeros.

       01  CAB01.
           05  FILLER              PIC X(3)    VALUE SPACES.
           05  EMPRESA-REL         PIC X(65)   VALUE SPACES.
           05  FILLER              PIC X(12)   VALUE "EMISSAO/HR: ".
           05  EMISSAO-REL         PIC 99/99/9999 BLANK WHEN ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  HORA-REL            PIC X(5)    VALUE "  :  ".
           05  FILLER              PIC X(10)   VALUE SPACES.
           05  FILLER              PIC X(5)    VALUE "PAG: ".
           05  PG-REL              PIC Z9      VALUE ZEROS.
       01  CAB02.
           05  FILLER              PIC X(3)    VALUE SPACES.
           05  FILLER              PIC X(41)   VALUE
           "RELACAO DE CHEQUES PRE-DATADOS-ORDEM: ".
           05  ORDEM-REL           PIC X(16)   VALUE SPACES.
           05  FILLER              PIC X(15)   VALUE SPACES.
           05  FILLER              PIC X(15)   VALUE "INTERV.VENCTO: ".
           05  MOVTO-INI-REL       PIC 99/99/9999.
           05  FILLER              PIC X(3)    VALUE ' a '.
           05  MOVTO-FIM-REL       PIC 99/99/9999.
       01  CAB03.
           05  FILLER              PIC X(3)    VALUE SPACES.
           05  FILLER              PIC X(110)  VALUE ALL "=".
       01  CAB04.
           05  FILLER              PIC X(3)    VALUE SPACES.
           05  FILLER              PIC X(110)  VALUE
           "NOME-CLIENTE       ALBUM    VENDED BCO. AGENC NR-CHEQ PORTAD
      -    "OR   CART DATA-VECTO         VALOR         TOTAL".
       01  LINDET.
           05  FILLER              PIC X(3)    VALUE SPACES.
           05  LINDET-REL          PIC X(110)  VALUE SPACES.
       01  LINTOT.
           05  FILLER              PIC X(3)    VALUE SPACES.
      *    05  FILLER              PIC X(4)    VALUE "PM: ".
      *    05  PM-REL              PIC ZZZ,ZZ.
      *    05  FILLER              PIC X(3)    VALUE SPACES.
           05  FILLER              PIC X(12)   VALUE "QT-TITULOS: ".
           05  QTDE-TITULO-REL     PIC ZZZZ.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  FILLER              PIC X(13)   VALUE "TOT-PERIODO: ".
           05  TOTAL-PERIODO-REL   PIC ZZ.ZZZ.ZZZ,ZZ.
           05  FILLER              PIC X(04)   VALUE SPACES.
           05  FILLER              PIC X(10)   VALUE "TOT-VENC: ".
           05  TOTAL-VENCIDO-REL   PIC ZZ.ZZZ.ZZZ,ZZ.
           05  FILLER              PIC X(04)   VALUE SPACES.
           05  FILLER              PIC X(12)   VALUE "TOT-A-VENC: ".
           05  TOTAL-AVENCER-REL   PIC ZZ.ZZZ.ZZZ,ZZ.

       01 WS-DATA-SYS.
          05 WS-DATA-CPU.
             10 WS-ANO-CPU         PIC 9(04).
             10 WS-MES-CPU         PIC 9(02).
             10 WS-DIA-CPU         PIC 9(02).
          05 FILLER                PIC X(13).

       01  WS-HORA-SYS                 PIC 9(08).
       01  FILLER REDEFINES WS-HORA-SYS.
           03 WS-HO-SYS                PIC 9(02).
           03 WS-MI-SYS                PIC 9(02).
           03 WS-SE-SYS                PIC 9(02).
           03 WS-MS-SYS                PIC 9(02).

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
           MOVE "CAD004"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CAD004.
           MOVE "CGD010"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CGD010.
           MOVE "CHD010"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CHD010.
           MOVE "CAD018"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CAD018.
           MOVE "CRD200"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CRD200.
           MOVE "CRD201"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CRD201.
           MOVE "LOGACESS" TO ARQ-REC.  MOVE EMPRESA-REF TO
                                                       ARQUIVO-LOGACESS

           OPEN INPUT CAD018 CGD010 CAD004.
           OPEN I-O CHD010.
           OPEN I-O CRD200 CRD201.
           IF ST-CRD200 = "35"  CLOSE CRD200  OPEN OUTPUT CRD200
                                CLOSE CRD200  OPEN I-O CRD200.
           IF ST-CRD201 = "35"  CLOSE CRD201  OPEN OUTPUT CRD201
                                CLOSE CRD201  OPEN I-O CRD201.
           IF ST-CRD200 <> "00"
              MOVE "ERRO ABERTURA CRD200: "  TO GS-MENSAGEM-ERRO
              MOVE ST-CRD200 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CRD201 <> "00"
              MOVE "ERRO ABERTURA CRD201: "  TO GS-MENSAGEM-ERRO
              MOVE ST-CRD201 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CGD010 <> "00"
              MOVE "ERRO ABERTURA CGD010: "  TO GS-MENSAGEM-ERRO
              MOVE ST-CGD010 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CAD004 <> "00"
              MOVE "ERRO ABERTURA CAD004: "  TO GS-MENSAGEM-ERRO
              MOVE ST-CAD004 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CAD018 <> "00"
              MOVE "ERRO ABERTURA CAD018: "  TO GS-MENSAGEM-ERRO
              MOVE ST-CAD018 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CHD010 <> "00"
              MOVE "ERRO ABERTURA CHD010: "  TO GS-MENSAGEM-ERRO
              MOVE ST-CHD010 TO GS-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
      *    MOVE 1 TO COD-USUARIO-W

           open i-o logacess

           move function current-date to ws-data-sys

           move usuario-w           to logacess-usuario
           move ws-data-cpu         to logacess-data
           accept ws-hora-sys from time
           move ws-hora-sys         to logacess-horas
           move 1                   to logacess-sequencia
           move "CHP070"            to logacess-programa
           move "ABERTO"            to logacess-status
           move "10" to fs-logacess
           perform until fs-logacess = "00"
                write reg-logacess invalid key
                    add 1 to logacess-sequencia
                not invalid key
                    move "00" to fs-logacess
                end-write
           end-perform

           close logacess

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
      *             PERFORM VERIFICA-VENCTO-ANT
                    PERFORM GRAVA-WORK
                    PERFORM ZERA-VARIAVEIS
                    PERFORM CARREGA-LISTA
               WHEN GS-CARREGA-LISTA-FLG-TRUE
                    PERFORM ZERA-VARIAVEIS
                    PERFORM CARREGA-LISTA
               WHEN GS-ITEM-SELECIONADO-TRUE
                    PERFORM CHAMA-ALTERACAO
               WHEN GS-LE-PORTADOR-TRUE
                    PERFORM LER-PORTADOR
               WHEN GS-CHAMAR-POP-UP-TRUE
                    PERFORM POPUP-PORTADOR
               WHEN GS-TRANSF-PORTADOR-TRUE
                    PERFORM TRANSFERE-PORTADOR
               WHEN GS-VERIF-SENHA-TRUE
                    PERFORM VERIFICA-SENHA
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
       VERIFICA-SENHA SECTION.
           MOVE ZEROS TO GS-AUTORIZADO.
           MOVE COD-USUARIO-W TO COD-USUARIO-CA004.
           MOVE "SENHA02"     TO PROGRAMA-CA004.
           READ CAD004 INVALID KEY
                MOVE 1 TO GS-AUTORIZADO
              NOT INVALID KEY
                MOVE GS-SENHA TO SENHA-W1
                IF SENHA-W <> SENHA-W1
                   MOVE 1 TO GS-AUTORIZADO.
       LER-PORTADOR SECTION.
           MOVE GS-PORTADOR TO PORTADOR.
           READ CAD018 INVALID KEY MOVE SPACES TO NOME-PORT.
           MOVE NOME-PORT TO GS-DESC-PORTADOR.
       POPUP-PORTADOR SECTION.
           CALL   "CAP018T" USING PARAMETROS-W PASSAR-PARAMETROS.
           CANCEL "CAP018T".
           MOVE PASSAR-PARAMETROS(1: 30) TO GS-DESC-PORTADOR
           MOVE PASSAR-PARAMETROS(1: 30) TO GS-DESC-PORTADOR-T
           MOVE PASSAR-PARAMETROS(33: 4) TO GS-PORTADOR
           MOVE PASSAR-PARAMETROS(33: 4) TO GS-PORTADOR-T.
       TRANSFERE-PORTADOR SECTION.
           MOVE ZEROS TO DATA-MOVTO-WK SEQ-WK.
           START WORK KEY IS NOT < CHAVE-WK INVALID KEY
                 MOVE "10" TO ST-WORK.
           PERFORM UNTIL ST-WORK = "10"
             READ WORK NEXT RECORD AT END MOVE "10" TO ST-WORK
               NOT AT END
                  MOVE CLIENTE-WK   TO GS-EXIBE-TRANSF
                  MOVE "REFRESH-WIN5" TO DS-PROCEDURE
                  PERFORM CALL-DIALOG-SYSTEM
                  MOVE GS-DESC-PORTADOR-T TO PORTADOR-WK
                  REWRITE REG-WORK
                  END-REWRITE
                  MOVE DATA-MOVTO-WK TO DATA-MOVTO-CH10
                  MOVE SEQ-WK        TO SEQ-CH10
                  READ CHD010 INVALID KEY CONTINUE
                    NOT INVALID KEY
                      PERFORM GRAVA-ANOTACAO
                      MOVE GS-PORTADOR-T TO PORTADOR-CH10
                      REWRITE REG-CHD010
                      END-REWRITE
                  END-READ
             END-READ
           END-PERFORM.
           MOVE "UNSHOW-WIN5" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
       GRAVA-ANOTACAO SECTION.
           MOVE COD-COMPL-CH10 TO COD-COMPL-CR200
           MOVE ZEROS TO SEQ-CR200 ULT-SEQ.
           START CRD200 KEY IS NOT < CHAVE-CR200 INVALID KEY
                 MOVE "10" TO ST-CRD200.
           PERFORM UNTIL ST-CRD200 = "10"
             READ CRD200 NEXT RECORD AT END MOVE "10" TO ST-CRD200
               NOT AT END
                 IF COD-COMPL-CR200 <> COD-COMPL-CH10
                              MOVE "10" TO ST-CRD200
                 ELSE MOVE SEQ-CR200 TO ULT-SEQ
                      CONTINUE
             END-READ
           END-PERFORM.
           MOVE ZEROS          TO SITUACAO-ANOTACAO-CR200
           ADD 1 TO ULT-SEQ.
           MOVE ULT-SEQ      TO SEQ-CR200.
           MOVE COD-COMPL-CH10 TO COD-COMPL-CR200.
           MOVE ZEROS        TO DATA-RETORNO-CR200
           MOVE USUARIO-W    TO USUARIO-CR200
           MOVE DATA-DIA-I   TO DATA-MOVTO-CR200
           MOVE HORA-BRA(1: 4) TO HORA-MOVTO-CR200

           MOVE ZEROS TO ST-CRD200.
           PERFORM UNTIL ST-CRD200 = "10"
              WRITE REG-CRD200 INVALID KEY
                 ADD 1 TO SEQ-CR200
                 CONTINUE
               NOT INVALID KEY MOVE "10" TO ST-CRD200
           END-PERFORM.

           MOVE SEQ-CR200      TO SEQ-CR201.
           MOVE COD-COMPL-CH10 TO COD-COMPL-CR201.
           MOVE "TRANSF.PORTADOR-CHEQUE: XXXXXXXXXX - 01-XXXXXXXXXXXXXXX
      -    "X P/ 99-XXXXXXXXXXXXXXXX" TO ANOTACAO-CR201.
           MOVE NR-CHEQUE-CH10      TO ANOTACAO-CR201(25: 11)
           MOVE PORTADOR-CH10       TO ANOTACAO-CR201(38: 4) PORTADOR
           READ CAD018 INVALID KEY MOVE SPACES TO NOME-PORT.
           MOVE NOME-PORT           TO ANOTACAO-CR201(43: 16)
           MOVE GS-PORTADOR-T       TO ANOTACAO-CR201(63: 4) PORTADOR
           READ CAD018 INVALID KEY MOVE SPACES TO NOME-PORT.
           MOVE NOME-PORT           TO ANOTACAO-CR201(68: 16)
           MOVE ZEROS TO ST-CRD201.
           MOVE 1              TO SUBSEQ-CR201.
           PERFORM UNTIL ST-CRD201 = "10"
             WRITE REG-CRD201 INVALID KEY
               ADD 1 TO SUBSEQ-CR201
               CONTINUE
              NOT INVALID KEY
                MOVE "10" TO ST-CRD201
             END-WRITE
           END-PERFORM.
       LIMPAR-DADOS SECTION.
           INITIALIZE GS-DATA-BLOCK
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
       GRAVA-WORK SECTION.
           IF ST-WORK NOT = "35"
              CLOSE WORK
              DELETE FILE WORK.

           ACCEPT VARIA-W FROM TIME.

           OPEN OUTPUT WORK.
           CLOSE WORK.
           OPEN I-O WORK.

           MOVE "TELA-AGUARDA" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE GS-MOVTO-INI TO DATA-INV MOVTO-INI-ANT
                                     MOVTO-INI-REL.
           CALL "GRIDAT2" USING DATA-INV.
           MOVE DATA-INV    TO MOVTO-INI.
           MOVE GS-MOVTO-FIM TO DATA-INV MOVTO-FIM-ANT
                                     MOVTO-FIM-REL.
           CALL "GRIDAT2" USING DATA-INV.
           MOVE DATA-INV    TO MOVTO-FIM.
           MOVE MOVTO-INI TO DATA-MOVTO-CH10
           MOVE ZEROS     TO SEQ-CH10.
           START CHD010 KEY IS NOT < CHAVE-CH10 INVALID KEY
                  MOVE "10" TO ST-CHD010.
           PERFORM UNTIL ST-CHD010 = "10"
             READ CHD010 NEXT RECORD AT END MOVE "10" TO ST-CHD010
              NOT AT END
               IF DATA-MOVTO-CH10 > MOVTO-FIM
                  MOVE "10" TO ST-CHD010
               ELSE
                  IF SITUACAO-CH10 <> 0
                     CONTINUE
                  ELSE
                     PERFORM CONT-GRAVA-WORK
                  END-IF
               END-IF
             END-READ
           END-PERFORM.
           MOVE "TELA-AGUARDA2" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
       CONT-GRAVA-WORK SECTION.
           PERFORM MOVER-DADOS-WORK
           MOVE "TELA-AGUARDA1" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           WRITE REG-WORK.
       MOVER-DADOS-WORK SECTION.
           MOVE DATA-VENCTO-CH10    TO VENCTO-WK
                                       GS-EXIBE-VENCTO
           MOVE CLASS-CLIENTE-CH10   TO CLASSIF-WK CLASSIF-CG10
           MOVE CLIENTE-CH10        TO CLIENTE-WK.
           MOVE NOME-CH10           TO NOME-CLIEN-WK.
           MOVE VENDEDOR-CH10       TO VENDEDOR-WK.
           MOVE BANCO-CH10          TO BANCO-WK
           MOVE AGENCIA-CH10        TO AGENCIA-WK
           MOVE NR-CHEQUE-CH10      TO NR-CHEQUE-WK
           MOVE DATA-MOVTO-CH10     TO DATA-MOVTO-WK
           MOVE SEQ-CH10            TO SEQ-WK
           MOVE PORTADOR-CH10 TO PORTADOR
           READ CAD018 INVALID KEY MOVE "******" TO NOME-PORT.
           MOVE NOME-PORT           TO PORTADOR-WK.
           MOVE VALOR-CH10          TO VALOR-WK
           EVALUATE CARTEIRA-CH10
             WHEN 1 MOVE "SIMP" TO CARTEIRA-WK
             WHEN 2 MOVE "CAUC" TO CARTEIRA-WK
             WHEN 3 MOVE "DESC" TO CARTEIRA-WK
             WHEN OTHER MOVE "   " TO CARTEIRA-WK
           END-EVALUATE.

       CARREGA-LISTA SECTION.
           MOVE "CLEAR-LIST-BOX" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE SPACES TO GS-LINDET.
           PERFORM ORDEM.
           MOVE "REFRESH-DATA" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           MOVE ZEROS TO GS-TOTAL-PERIODO GS-TOTAL-VENCIDO
                         GS-TOTAL-AVENCER GS-QTDE-TITULOS
      *                  GS-PM TOTAL-GERAL-PM.
           PERFORM UNTIL ST-WORK = "10"
              READ WORK NEXT RECORD AT END MOVE "10" TO ST-WORK
              NOT AT END
                   PERFORM MOVER-DADOS-LINDET
              END-READ
           END-PERFORM.
      *    COMPUTE GS-PM = TOTAL-GERAL-PM / GS-TOTAL-PERIODO
           MOVE "REFRESH-DATA" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
       ORDEM SECTION.
           MOVE "VENCTO/VALOR" TO GS-DESCR-ORDEM
           MOVE ZEROS TO VENCTO-WK VENDEDOR-WK VALOR-WK.
           START WORK KEY IS NOT < ALT-WK INVALID KEY
                 MOVE "10" TO ST-WORK.
       MOVER-DADOS-LINDET SECTION.
           IF VENCTO-ANT NOT = ZEROS
              IF VENCTO-ANT NOT = VENCTO-WK
                 PERFORM TOTALIZA.
           PERFORM MOVER-CHAVE-ANT.
           MOVE 0 TO TIPO-PROCESSO.
           PERFORM MOVER-DADOS.

           MOVE "INSERE-LIST" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
       MOVER-DADOS SECTION.
           MOVE NOME-CLIEN-WK     TO GS-LINDET(01: 19)
           MOVE CLIENTE-WK          TO GS-LINDET(20: 9)
           MOVE VENDEDOR-WK       TO GS-LINDET(29: 7)
           MOVE BANCO-WK          TO GS-LINDET(36: 5)
           MOVE AGENCIA-WK        TO GS-LINDET(41: 6)
           MOVE NR-CHEQUE-WK      TO GS-LINDET(47: 8)
           MOVE PORTADOR-WK       TO GS-LINDET(55: 11)
           MOVE CARTEIRA-WK       TO GS-LINDET(66: 5)
           MOVE VENCTO-WK         TO DATA-INV
           CALL "GRIDAT1" USING DATA-INV
           MOVE DATA-INV          TO DATA-E
           MOVE DATA-E            TO GS-LINDET(71: 11)
           MOVE VALOR-WK          TO VALOR-E
           MOVE VALOR-E           TO GS-LINDET(82: 14)
           IF TIPO-PROCESSO = 0
             ADD VALOR-WK           TO TOTAL-W GS-TOTAL-PERIODO
             ADD 1                  TO GS-QTDE-TITULOS
             MOVE TOTAL-W           TO VALOR-E
             MOVE VALOR-E           TO GS-LINDET(96: 13)
             IF VENCTO-WK < DATA-DIA-I
                ADD VALOR-WK        TO GS-TOTAL-VENCIDO
             ELSE ADD VALOR-WK      TO GS-TOTAL-AVENCER
             END-IF
           END-IF.
           MOVE DATA-MOVTO-WK     TO GS-LINDET(110: 8)
           MOVE SEQ-WK            TO GS-LINDET(119: 4).
       ZERA-VARIAVEIS SECTION.
           MOVE ZEROS TO VENCTO-ANT.
       MOVER-CHAVE-ANT SECTION.
           MOVE VENCTO-WK       TO VENCTO-ANT.
       TOTALIZA SECTION.
           MOVE ZEROS TO TOTAL-W.
           MOVE SPACES TO GS-LINDET.
           MOVE "INSERE-LIST" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
       CHAMA-ALTERACAO SECTION.
           IF GS-LINDET = SPACES MOVE ZEROS TO GS-LINDET.
           MOVE GS-LINDET(110: 8) TO PASSAR-STRING(1: 8) DATA-MOVTO-CH10
           MOVE GS-LINDET(119: 4) TO PASSAR-STRING(10: 4) SEQ-CH10.
           MOVE USUARIO-W         TO PASSAR-STRING(20: 5)
           CALL   "CHP010A" USING PARAMETROS-W PASSAR-STRING
           CANCEL "CHP010A"
           READ CHD010.
           MOVE DATA-MOVTO-CH10    TO DATA-MOVTO-WK.
           MOVE SEQ-CH10           TO SEQ-WK.
           READ WORK.
           PERFORM MOVER-DADOS-WORK.
           REWRITE REG-WORK.
           MOVE 1 TO TIPO-PROCESSO.
           PERFORM MOVER-DADOS.
           MOVE "ATUALIZA-LISTA" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
      *    Deveria ser regravado o arquivo work, pois pode ter havido
      *    alguma altera��o no arquivo em que diferencie a classifica��o
      *    por exemplo, mudar a data de vencto fora do intervalo soli-
      *    citado pelo usu�rio. Mas foi solicitado que n�o regrave.
       CLEAR-FLAGS SECTION.
           INITIALIZE GS-FLAG-GROUP.
       SET-UP-FOR-REFRESH-SCREEN SECTION.
           MOVE "REFRESH-DATA" TO DS-PROCEDURE.

       LOAD-SCREENSET SECTION.
           MOVE DS-PUSH-SET TO DS-CONTROL
           MOVE "CHP070" TO DS-SET-NAME
           PERFORM CALL-DIALOG-SYSTEM.

       IMPRIME-RELATORIO SECTION.
           MOVE ZEROS TO PAG-W TOTAL-W.
           COPY CONDENSA.
           PERFORM ORDEM.
           MOVE ZEROS TO LIN. PERFORM CABECALHO.
           MOVE SPACES TO LINDET-REL
           PERFORM UNTIL ST-WORK = "10"
              READ WORK NEXT RECORD AT END MOVE "10" TO ST-WORK
              NOT AT END
                PERFORM MOVER-DADOS-RELATORIO
              END-READ
           END-PERFORM.
           MOVE GS-QTDE-TITULOS   TO QTDE-TITULO-REL.
           MOVE GS-TOTAL-PERIODO  TO TOTAL-PERIODO-REL.
           MOVE GS-TOTAL-VENCIDO  TO TOTAL-VENCIDO-REL.
           MOVE GS-TOTAL-AVENCER  TO TOTAL-AVENCER-REL.
      *    MOVE GS-PM             TO PM-REL
           WRITE REG-RELAT FROM LINTOT AFTER 2.
           COPY DESCONDENSA.
       MOVER-DADOS-RELATORIO SECTION.
           IF VENCTO-ANT NOT = ZEROS
              IF VENCTO-ANT NOT = VENCTO-WK
                 PERFORM TOTALIZA-REL.
           PERFORM MOVER-CHAVE-ANT.

           MOVE NOME-CLIEN-WK     TO LINDET-REL(01: 21)
           MOVE CLIENTE-WK          TO LINDET-REL(20: 9)
           MOVE VENDEDOR-WK       TO LINDET-REL(29: 7)
           MOVE BANCO-WK          TO LINDET-REL(36: 5)
           MOVE AGENCIA-WK        TO LINDET-REL(41: 6)
           MOVE NR-CHEQUE-WK      TO LINDET-REL(47: 8)
           MOVE PORTADOR-WK       TO LINDET-REL(55: 11)
           MOVE CARTEIRA-WK       TO LINDET-REL(66: 5)
           MOVE VENCTO-WK         TO DATA-INV
           CALL "GRIDAT1" USING DATA-INV
           MOVE DATA-INV          TO DATA-E
           MOVE DATA-E            TO LINDET-REL(71: 11)
           MOVE VALOR-WK          TO VALOR-E
           MOVE VALOR-E           TO LINDET-REL(82: 14)
           ADD VALOR-WK           TO TOTAL-W.
           MOVE TOTAL-W           TO VALOR-E
           MOVE VALOR-E           TO LINDET-REL(96: 13)

           WRITE REG-RELAT FROM LINDET.
           ADD 1 TO LIN.
           IF LIN > 56 PERFORM CABECALHO.
       TOTALIZA-REL SECTION.
           MOVE ZEROS TO TOTAL-W.
           MOVE SPACES TO LINDET-REL.
           WRITE REG-RELAT FROM LINDET-REL.
           ADD 1 TO LIN.
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
           open i-o logacess

           move function current-date to ws-data-sys

           move usuario-w           to logacess-usuario
           move ws-data-cpu         to logacess-data
           accept ws-hora-sys from time
           move ws-hora-sys         to logacess-horas
           move 1                   to logacess-sequencia
           move "CHP070"            to logacess-programa
           move "FECHADO"           to logacess-status
           move "10" to fs-logacess
           perform until fs-logacess = "00"
                write reg-logacess invalid key
                    add 1 to logacess-sequencia
                not invalid key
                    move "00" to fs-logacess
                end-write
           end-perform

           close logacess

           CLOSE CHD010 CAD018 CGD010 CRD200 CRD201 CAD004.
           MOVE DS-QUIT-SET TO DS-CONTROL
           PERFORM CALL-DIALOG-SYSTEM
           EXIT PROGRAM.

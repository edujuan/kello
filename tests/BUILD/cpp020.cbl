       copy dslang.cpy.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CPP020.
      *AUTORA: MARELI AMANCIO VOLPATO
      *DATA: 13/07/1998
      *FUN��O: Movimento de contas a pagar

      *-Para lan�amento de contas permanentes - Caso seja inclus�o -
      * incluir 13 meses(sendo o 1o.m�s definitivo os demais previsto),
      * e verificar se existe a chave=fornecedor/docto e situa��o = 0 ou
      * = 1, caso afirmativo
      * n�o permitir a inclus�o(solicitar mudan�a no nr.docto)
      * caso Altera��o - alterar os 12 lan�amentos c/ os novos dados
      * caso exclus�o/suspens�o- excluir/suspender os 12 lan�amentos
      * Em caso de altera��o de previsto p/ definitivo incluir uma
      * parcela(tendo assim sempre 12 prevista). E em caso de altera�ao
      * perguntar se a altera��o � em uma parcela ou em todas)
      * Caso cancelamento - n�o permitir

      *-Um lan�amento ser� considerado suspenso, aquelas contas que n�o
      * tem previs�o p/ pagto, podendo mais tarde, voltar a ser conside-
      * rada uma conta normal

      *-As baixas de contas s� ser�o permitidas, pelo sistema de caixa

      *-Quando entrar com o fornecedor, abrir janela para verificar
      * se existe programa��o financeira p/ o lan�amento, caso contr�-
      * rio enviar uma CIE para o respons�vel.

      *- Contas desmebranda - � para ser utilizada no caixa, para lan�a-
      *  mentos na conta reduzida correta.

      *- O PORTADOR 49 NAO PODERA SER USADO NO CONTAS A PAGAR, ESSE
      *  PORTADOR SIGNIFICA QUE O LANCTO VEIO PELO CONTA CORRENTE

       ENVIRONMENT DIVISION.
       SPECIAL-NAMES.
         DECIMAL-POINT IS COMMA
         PRINTER IS LPRINTER.
       class-control.
           Window             is class "wclass".

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY CAPX002.
           COPY CAPX004.
           COPY CGPX001.
           COPY CXPX020.
           COPY CPPX020.
           COPY CPPX021.
           COPY CPPX022.
           COPY CPPX023.
           COPY CPPX099.
           COPY CAPX018.
           COPY CAPX019.
           COPY CBPX001.
           COPY CBPX003.
           COPY CBPX100.
      *    COPY CIEPX001.
      *    COPY CIEPX010.
           COPY PFPX010.
           COPY LOGX001.
           COPY LOGX002.
           COPY LOGX003.
           COPY LOGACESS.SEL.
           COPY GERX001.
           COPY GERX002.
           SELECT RELAT ASSIGN TO PRINTER NOME-IMPRESSORA.

       DATA DIVISION.
       FILE SECTION.
       COPY CAPW002.
       COPY CAPW004.
       COPY CGPW001.
       COPY CXPW020.
       COPY CAPW018.
       COPY CAPW019.
       COPY CBPW001.
       COPY CBPW003.
       COPY CBPW100.
       COPY CPPW020.
       COPY CPPW021.
       COPY CPPW022.
       COPY CPPW023.
       COPY CPPW099.
      *COPY CIEPW001.
      *COPY CIEPW010.
       COPY PFPW010.
       COPY LOGW001.
       COPY LOGW002.
       COPY LOGW003.
       COPY LOGACESS.FD.
       COPY GERW001.
       COPY GERW002.
       FD  RELAT
           LABEL RECORD IS OMITTED.
       01  REG-RELAT.
           05  FILLER              PIC X(130).
       WORKING-STORAGE SECTION.
           COPY IMPRESSORA.
           COPY "CPP020.CPB".
           COPY "CPP020.CPY".
           COPY "DS-CNTRL.MF".
           COPY "CBDATA.CPY".
           COPY "CBPRINT.CPY".
           COPY "CPADAY1.CPY".
           COPY "CPTIME.CPY".
       78  REFRESH-TEXT-AND-DATA-PROC VALUE 255.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  PASSAR-PARAMETROS.
           05  PASSAR-STRING-1       PIC X(65).
       01  VARIAVEIS.
           05  ST-CGD001             PIC XX       VALUE SPACES.
           05  ST-CAD002             PIC XX       VALUE SPACES.
           05  ST-CAD004             PIC XX       VALUE SPACES.
           05  ST-CXD020             PIC XX       VALUE SPACES.
           05  ST-CPD020             PIC XX       VALUE SPACES.
           05  ST-CPD021             PIC XX       VALUE SPACES.
           05  ST-CPD022             PIC XX       VALUE SPACES.
           05  ST-CPD023             PIC XX       VALUE SPACES.
           05  ST-CPD099             PIC XX       VALUE SPACES.
           05  ST-CAD018             PIC XX       VALUE SPACES.
           05  ST-CAD019             PIC XX       VALUE SPACES.
           05  ST-CBD001             PIC XX       VALUE SPACES.
           05  ST-CBD003             PIC XX       VALUE SPACES.
           05  ST-CBD100             PIC XX       VALUE SPACES.
      *    05  ST-CIED001            PIC XX       VALUE SPACES.
      *    05  ST-CIED010            PIC XX       VALUE SPACES.
           05  ST-PFD010             PIC XX       VALUE SPACES.
           05  ST-LOG001             PIC XX       VALUE SPACES.
           05  ST-LOG002             PIC XX       VALUE SPACES.
           05  ST-LOG003             PIC XX       VALUE SPACES.
           05  FS-LOGACESS           PIC XX       VALUE SPACES.
           05  ST-GED001             PIC XX       VALUE SPACES.
           05  ST-GED002             PIC XX       VALUE SPACES.
           05  ACHEI                 PIC X        VALUE SPACES.
           05  ERRO-W                PIC 9        VALUE ZEROS.
      *    ERRO-W - flag que controla se houve erro de abertura arquivo
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
           05  DATA-MOVTO-W          PIC 9(8)     VALUE ZEROS.
           05  DATA-MOVTO-I          PIC 9(8)     VALUE ZEROS.
           05  DATAWI.
               10  ANO-WI            PIC 9(4).
               10  MES-WI            PIC 99.
               10  DIA-WI            PIC 99.
           05  DATA-WI REDEFINES DATAWI PIC 9(8).
           05  DATAWII.
               10  ANO-WII           PIC 9(4).
               10  MES-WII           PIC 99.
               10  DIA-WII           PIC 99.
           05  DATA-WII REDEFINES DATAWII PIC 9(8).
      * DATA-WII - Encontrar proxima data caso a data de vencto da conta
      * permanente seja invalida, por exemplo 30/02/1998
           05  DATA-LIMITE           PIC 9(08)    VALUE 19950101.
           05  FORNEC-E              PIC ZZZZZZ   VALUE ZEROS.
           05  SEQ-E                 PIC ZZZZZ    VALUE ZEROS.
           05  DATA-E                PIC 99/99/9999.
           05  CODIGO-E              PIC Z.ZZ.ZZ.ZZ.
           05  LETRA                 PIC X        VALUE SPACES.
           05  LETRA1                PIC X        VALUE SPACES.
           05  VALOR-E               PIC ZZZ.ZZZ,ZZ.
           05  VALOR-E1              PIC ZZ.ZZZ.ZZZ,ZZ.
           05  NR-CHEQUE-W           PIC 9(6)     VALUE ZEROS.
           05  I                     PIC 99       VALUE ZEROS.
           05  L                     PIC 99       VALUE ZEROS.
           05  K                     PIC 99       VALUE ZEROS.
           05  J                     PIC 99       VALUE ZEROS.
           05  VLR-PARCELA           PIC 9(8)V99  VALUE ZEROS.
           05  SEQ-CIE               PIC 9(3)     VALUE ZEROS.
           05  LIN                   PIC 9(02)    VALUE ZEROS.
           05  VALOR-TOT-DESM        PIC 9(8)V99  VALUE ZEROS.
      *  verifica total desmembrado de cada parcela p/ jogar o
      *  arredondamento na ultima parcela desmembrada
           05  QTDE-DESM             PIC 9(2)     VALUE ZEROS.
      *  verifica a quantidade de desmembradas
           05  PERC-GR OCCURS 10 PIC 9(3)V99.
      *  percentagem que ser� calculado em cima do parcelamento, desmem-
      *  brado por depto
           05  DIA-PADRAO            PIC 99       VALUE ZEROS.
      *  dia p/ alterar o vencto de contas permanentes
           05  QT-PARCELAS           PIC 99       VALUE ZEROS.
      *  QT-PARCELAS - qtde de parcelas permanentes programadas
           05  ULT-VENCTO            PIC 9(8)     VALUE ZEROS.
      *  ultima data de vencto de conta permanente programada.
           05  FORNEC-W              PIC 9(6)     VALUE ZEROS.
           05  DOCTO-W               PIC X(10)    VALUE SPACES.
      * FORNEC-W E DOCTO-W. VARI�VEIS UTILIZADAS P/ ENCONTRAR AS CONTAS
      * PERMANENTES, RELACIONADAS COM AS MESMAS.
           05  SEQ-ALTERADA          PIC 9(5)     VALUE ZEROS.
      *  SEQ-ALTERADA - � a 1 sequencia da parcela da conta permanente
      *                 alterada.
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
           05  FILLER              PIC X(76)   VALUE
           "CONFERENCIA DO MOVIMENTO DO CONTAS A PAGAR".
           05  FILLER              PIC X(12)   VALUE "DATA MOVTO: ".
           05  DATA-MOVTO-REL      PIC 99/99/9999 VALUE ZEROS.
           05  FILLER              PIC X(15)   VALUE SPACES.
           05  HORA-REL            PIC X(5)    VALUE "  :  ".
           05  FILLER              PIC XX      VALUE SPACES.
           05  EMISSAO-REL         PIC 99/99/9999 BLANK WHEN ZEROS.
       01  CAB03.
           05  FILLER              PIC X(130)  VALUE ALL "=".
       01  CAB04.
           05  FILLER              PIC X(132)  VALUE
           "FORNEC.  SEQUEN  TIP  DOCUMENTO  DESCRICAO
      -    "  PORT  SITUACAO  LIB  APUR.  MOEDA   RESP.  DIGIT   SEQ.CAI
      -    "XA TC CONTAB".
       01  CAB05.
           05  FILLER              PIC X(130)  VALUE
           "PARC.    EMISSAO VENCIMENTO TX.APL MULTA-ATRA JUROS-MORA   V
      -    "ALOR-TOTAL   DATA-PAGTO  VLR-JUROS  VLR-MULTA   DESCONTO   V
      -    "LR-LIQUIDO".
       01  LINDET.
           05  FORNECEDOR-REL      PIC ZZZ.ZZZ.
           05  FILLER              PIC XX      VALUE SPACES.
           05  SEQ-REL             PIC ZZ.ZZZ.
           05  FILLER              PIC XX      VALUE SPACES.
           05  TIPO-FORN-REL       PIC ZZZ.
           05  FILLER              PIC XX      VALUE SPACES.
           05  DOCUMENTO-REL       PIC X(10)   VALUE SPACES.
           05  FILLER              PIC X       VALUE SPACES.
           05  DESCRICAO-REL       PIC X(28)   VALUE SPACES.
           05  FILLER              PIC X       VALUE SPACES.
           05  PORTADOR-REL        PIC 9999    VALUE ZEROS.
           05  FILLER              PIC XX      VALUE SPACES.
           05  SITUACAO-REL        PIC 9       VALUE ZEROS.
           05  FILLER              PIC X       VALUE "-".
           05  DESC-SITUACAO-REL   PIC X(6)    VALUE SPACES.
           05  FILLER              PIC XX      VALUE SPACES.
           05  LIBERADO-REL        PIC XXX     VALUE SPACES.
           05  FILLER              PIC XX      VALUE SPACES.
           05  APURACAO-REL        PIC ZZZZZ.
           05  FILLER              PIC XX      VALUE SPACES.
           05  MOEDA-REL           PIC XXXXX   VALUE ZEROS.
           05  FILLER              PIC X(3)    VALUE SPACES.
           05  RESPONSAVEL-REL     PIC X(5)    VALUE SPACES.
           05  FILLER              PIC XX      VALUE SPACES.
           05  DIGITADOR-REL       PIC X(5)    VALUE SPACES.
           05  FILLER              PIC X(5)    VALUE SPACES.
           05  SEQ-CAIXA-REL       PIC ZZZ     BLANK WHEN ZEROS.
           05  FILLER              PIC X(05)   VALUE SPACES.
           05  TIPO-CONTA-REL      PIC 9       VALUE ZEROS.
           05  FILLER              PIC X(4)    VALUE SPACES.
           05  CONTABILIZADO-REL   PIC 9       VALUE ZEROS.
       01  LINDET1.
           05  PARCELA-REL         PIC 99/99   VALUE ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  DATA-EMISSAO-REL    PIC 99/99/9999 VALUE ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  VENCTO-REL          PIC 99/99/9999 VALUE ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  TAXA-APLIC-REL      PIC ZZ,ZZ   VALUE ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  MULTA-ATRAS-REL     PIC ZZZ.ZZZ,ZZ VALUE ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  JUROS-MORA-REL      PIC ZZZ.ZZZ,ZZ VALUE ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  VALOR-TOTAL-REL     PIC ZZ.ZZZ.ZZZ,ZZ VALUE ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  PREV-DEF-REL        PIC X       VALUE ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  DATA-PAGTO-REL      PIC ZZ/ZZ/ZZZZ BLANK WHEN ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  VLR-JUROS-REL       PIC ZZZ.ZZZ,ZZ BLANK WHEN ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  VLR-MULTA-REL       PIC ZZZ.ZZZ,ZZ BLANK WHEN ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  DESCONTO-REL        PIC ZZZ.ZZZ,ZZ BLANK WHEN ZEROS.
           05  FILLER              PIC X       VALUE SPACES.
           05  VLR-LIQUIDO-REL     PIC ZZ.ZZZ.ZZZ,ZZ BLANK WHEN ZEROS.

       01 WS-DATA-SYS.
          05 WS-DATA-CPU.
             10 WS-ANO-CPU                 PIC 9(04).
             10 WS-MES-CPU                 PIC 9(02).
             10 WS-DIA-CPU                 PIC 9(02).
          05 FILLER                        PIC X(13).

       01  WS-HORA-SYS                 PIC 9(08).
       01  FILLER REDEFINES WS-HORA-SYS.
           03 WS-HO-SYS                PIC 9(02).
           03 WS-MI-SYS                PIC 9(02).
           03 WS-SE-SYS                PIC 9(02).
           03 WS-MS-SYS                PIC 9(02).


       01 mensagem            pic x(200).
       01 tipo-msg            pic x(01).
       01 resp-msg            pic x(01).

       LINKAGE SECTION.
       PROCEDURE DIVISION.

       MAIN-PROCESS SECTION.
           PERFORM INICIALIZA-PROGRAMA.
           PERFORM CORPO-PROGRAMA UNTIL CPP020-EXIT-FLG-TRUE.
           GO FINALIZAR-PROGRAMA.

       INICIALIZA-PROGRAMA SECTION.
           ACCEPT PARAMETROS-W FROM COMMAND-LINE.
           COPY "CBDATA1.CPY".
           MOVE DATA-INV TO DATA-MOVTO-W DATA-MOVTO-REL.
           MOVE ZEROS TO PAG-W ERRO-W.
           INITIALIZE CPP020-DATA-BLOCK
           INITIALIZE DS-CONTROL-BLOCK
           MOVE CPP020-DATA-BLOCK-VERSION-NO
                                   TO DS-DATA-BLOCK-VERSION-NO
           MOVE CPP020-VERSION-NO  TO DS-VERSION-NO
           MOVE EMPRESA-W          TO EMP-REC
           MOVE NOME-EMPRESA-W     TO EMPRESA-REL
           MOVE "CAD004"  TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CAD004.
           MOVE "CGD001" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CGD001.
           MOVE "CXD020" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CXD020.
           MOVE "CAD018" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CAD018.
           MOVE "CAD019" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CAD019.
           MOVE "CBD001" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CBD001.
           MOVE "CBD003" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CBD003.
           MOVE "CBD100" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CBD100.
           MOVE "CPD020" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CPD020.
           MOVE "CPD021" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CPD021.
           MOVE "CPD022" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CPD022.
           MOVE "CPD023" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CPD023.
           MOVE "CPD099" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-CPD099.
      *    MOVE "CIED001" TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CIED001.
      *    MOVE "CIED010" TO ARQ-REC. MOVE EMPRESA-REF TO PATH-CIED010.
           MOVE "PFD010" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-PFD010.
           MOVE "LOG001" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-LOG001
           MOVE "LOG002" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-LOG002
           MOVE "LOG003" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-LOG003
           MOVE "LOGACESS" TO ARQ-REC.  MOVE EMPRESA-REF TO
                                                        ARQUIVO-LOGACESS
           MOVE "GED001" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-GED001.
           MOVE "GED002" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-GED002.
           OPEN I-O CPD020 CPD021 CPD022 PFD010 CBD100 CPD023 LOG003
                    LOG001 LOG002.
      *    OPEN I-O CIED001 CIED010.
           OPEN INPUT CAD018 CAD019 CGD001 CXD020 CAD002 GED001 GED002
                      CAD004
           OPEN I-O CPD099.
           IF ST-CPD099 = "35"
              CLOSE CPD099      OPEN OUTPUT CPD099
              CLOSE CPD099      OPEN I-O CPD099.
           CLOSE CPD099.
           IF ST-CPD020 = "35"
              CLOSE CPD020      OPEN OUTPUT CPD020
              CLOSE CPD020      OPEN I-O CPD020
           END-IF.
           IF ST-CBD100 = "35"
              CLOSE CBD100      OPEN OUTPUT CBD100
              CLOSE CBD100      OPEN I-O CBD100
           END-IF.
           IF ST-CPD023 = "35"
              CLOSE CPD023      OPEN OUTPUT CPD023
              CLOSE CPD023      OPEN I-O CPD023
           END-IF.
           IF ST-CPD021 = "35"
              CLOSE CPD021      OPEN OUTPUT CPD021
              CLOSE CPD021      OPEN I-O CPD021
           END-IF.
           IF ST-CPD022 = "35"
              CLOSE CPD022      OPEN OUTPUT CPD022
              CLOSE CPD022      OPEN I-O CPD022
           END-IF.
           IF ST-PFD010 = "35"
              CLOSE PFD010      OPEN OUTPUT PFD010
              CLOSE PFD010      OPEN I-O PFD010
           END-IF.
           IF ST-LOG001 = "35"
              CLOSE LOG001      OPEN OUTPUT LOG001
              CLOSE LOG001      OPEN I-O LOG001
           END-IF.
           IF ST-LOG002 = "35"
              CLOSE LOG002      OPEN OUTPUT LOG002
              CLOSE LOG002      OPEN I-O LOG002
           END-IF.
           IF ST-LOG003 = "35"
              CLOSE LOG003      OPEN OUTPUT LOG003
              CLOSE LOG003      OPEN I-O LOG003
           END-IF.
      *    IF ST-CIED001 = "35"
      *       CLOSE CIED001     OPEN OUTPUT CIED001
      *       CLOSE CIED001     OPEN I-O CIED001
      *    END-IF.
      *    IF ST-CIED010 = "35"
      *       CLOSE CIED010     OPEN OUTPUT CIED010
      *       CLOSE CIED010     OPEN I-O CIED010
      *    END-IF.
           IF ST-CAD002 <> "00"
              MOVE "ERRO ABERTURA CAD002: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CAD002 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CGD001 <> "00"
              MOVE "ERRO ABERTURA CGD001: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CGD001 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CXD020 <> "00"
              MOVE "ERRO ABERTURA CXD020: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CXD020 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CAD018 <> "00"
              MOVE "ERRO ABERTURA CAD018: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CAD018 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CAD019 <> "00"
              MOVE "ERRO ABERTURA CAD019: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CAD019 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CBD100 <> "00"
              MOVE "ERRO ABERTURA CBD100: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CBD100 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CPD020 <> "00"
              MOVE "ERRO ABERTURA CPD020: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CPD020 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CPD023 <> "00"
              MOVE "ERRO ABERTURA CPD023: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CPD023 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CPD021 <> "00"
              MOVE "ERRO ABERTURA CPD021: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CPD021 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-CPD022 <> "00"
              MOVE "ERRO ABERTURA CPD022: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CPD022 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-PFD010 <> "00"
              MOVE "ERRO ABERTURA PFD010: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-PFD010 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-GED001 <> "00"
              MOVE "ERRO ABERTURA GED001: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-GED001 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-GED002 <> "00"
              MOVE "ERRO ABERTURA GED002: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-GED002 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           OPEN INPUT CBD001.
           IF ST-CBD001 <> "00"
              MOVE "ERRO ABERTURA CBD001: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CBD001 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           CLOSE CBD001.
           OPEN INPUT CBD003.
           IF ST-CBD003 <> "00"
              MOVE "ERRO ABERTURA CBD003: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-CBD003 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           CLOSE CBD003.
           IF ST-PFD010 <> "00"
              MOVE "ERRO ABERTURA PFD010: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-PFD010 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LOG001 <> "00"
              MOVE "ERRO ABERTURA LOG001: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-LOG001 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LOG002 <> "00"
              MOVE "ERRO ABERTURA LOG002: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-LOG002 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ST-LOG003 <> "00"
              MOVE "ERRO ABERTURA LOG003: "  TO CPP020-MENSAGEM-ERRO
              MOVE ST-LOG003 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM CARREGA-MENSAGEM-ERRO.


           open i-o logacess

           move function current-date to ws-data-sys

           move usuario-w           to logacess-usuario
           move ws-data-cpu         to logacess-data
           accept ws-hora-sys from time
           move ws-hora-sys         to logacess-horas
           move 1                   to logacess-sequencia
           move "CPP020"            to logacess-programa
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

           MOVE USUARIO-W TO CPP020-USUARIO

      *    MOVE 1 TO COD-USUARIO-W.
           IF COD-USUARIO-W NOT NUMERIC
              MOVE "Executar pelo MENU" TO CPP020-MENSAGEM-ERRO
              PERFORM CARREGA-MENSAGEM-ERRO.
           IF ERRO-W = 0 PERFORM LOAD-SCREENSET.

       CORPO-PROGRAMA SECTION.
           EVALUATE TRUE
               WHEN CPP020-CENTRALIZA-TRUE
                   PERFORM CENTRALIZAR
               WHEN CPP020-SAVE-FLG-TRUE
                   IF CPP020-PARCELA = 1
                      PERFORM GRAVA-PARCELAS
                   ELSE
                      PERFORM SALVAR-DADOS
                      IF CPP020-TIPO-GRAVACAO = 1
                         PERFORM REGRAVA-DADOS
                      ELSE
                         PERFORM GRAVA-DADOS
                      END-IF
                   END-IF
                   PERFORM LIMPAR-DADOS
                   MOVE "SET-POSICAO-CURSOR1" TO DS-PROCEDURE
               WHEN CPP020-LOAD-FLG-TRUE
                   PERFORM CARREGAR-DADOS
                   MOVE "SET-POSICAO-CURSOR1" TO DS-PROCEDURE
               WHEN CPP020-EXCLUI-FLG-TRUE
                   MOVE FORNEC-CP20 TO FORNEC-W
                   MOVE NR-DOCTO-CP20 TO DOCTO-W
                   MOVE 3 TO SITUACAO-CP20
                   PERFORM EXCLUI
                   PERFORM LIMPAR-DADOS
               WHEN CPP020-SUSPENDE-FLG-TRUE
                   IF CPP020-SITUACAO = 0 MOVE 1 TO SITUACAO-CP20
                   ELSE MOVE 0 TO SITUACAO-CP20
                   END-IF
                   MOVE FORNEC-CP20 TO FORNEC-W
                   MOVE NR-DOCTO-CP20 TO DOCTO-W
                   PERFORM SUSPENDE-CANCELA
               WHEN CPP020-CANCELA-FLG-TRUE
                   IF CPP020-CANCELA-FLG-TRUE
                       AND TIPO-CONTA-CP20 = 1
                          MOVE "NAO-PERMITE-CANCELAR" TO DS-PROCEDURE
                          PERFORM CALL-DIALOG-SYSTEM
                   ELSE
                     MOVE FORNEC-CP20 TO FORNEC-W
                     MOVE NR-DOCTO-CP20 TO DOCTO-W
                     MOVE 4 TO SITUACAO-CP20
                     PERFORM SUSPENDE-CANCELA
               WHEN CPP020-CLR-FLG-TRUE
                   PERFORM LIMPAR-DADOS
               WHEN CPP020-PRINTER-FLG-TRUE
                    COPY IMPRESSORA.CHAMA.
                    IF LNK-MAPEAMENTO <> SPACES
                       PERFORM IMPRIME-RELATORIO
                    END-IF
               WHEN CPP020-CARREGA-ULT-TRUE
                   PERFORM CARREGA-ULTIMOS
                   MOVE "SET-POSICAO-CURSOR1" TO DS-PROCEDURE
               WHEN CPP020-CARREGA-LIST-BOX-TRUE
                   MOVE CPP020-LINDET(1: 6) TO FORNEC-CP20
                   MOVE CPP020-LINDET(8: 5) TO SEQ-CP20
                   INITIALIZE REG-GED001
                   MOVE "N" TO ACHEI
                   MOVE "CPP020 - Movimento do Contas a Pagar" TO
                   PROGRAMA-GE01
                   START GED001 KEY IS NOT LESS ALT-GE01 INVALID KEY
                       MOVE "10" TO ST-GED001
                   END-START
                   PERFORM UNTIL ST-GED001 = "10"
                       READ GED001 NEXT AT END
                           MOVE "10" TO ST-GED001
                       NOT AT END
                           IF "CPP020 - Movimento do Contas a Pagar" <>
                              PROGRAMA-GE01
                              MOVE "10" TO ST-GED001
                           ELSE
                             MOVE USUARIO-GE01       TO USUARIO-C-GE02
                             MOVE COD-USUARIO-W      TO USUARIO-P-GE02
                             MOVE "CPP020 - Movimento do Contas a Pagar"
                             TO PROGRAMA-GE02
                             MOVE SPACES          TO IDENTIFICACAO-GE02
                             STRING CPP020-LINDET(1:6)
                                    CPP020-LINDET(7: 5) INTO
                                    IDENTIFICACAO-GE02
                              READ GED002 NOT INVALID KEY
                                   MOVE "S"           TO ACHEI
                                   MOVE "10"          TO ST-GED001
                              END-READ
                           END-IF
                       END-READ
                   END-PERFORM

      *            IF ACHEI = "N"
      *               MOVE "USU�RIO SEM PERMISS�O PARA MANUTEN��O" TO
      *               CPP020-MENSAGEM-ERRO
      *               PERFORM CARREGA-MENSAGEM-ERRO
      *            ELSE
      *               IF OPERACAO-GE02 = "Altera��o"
      *                  MOVE "DESABILITA-EXCLUSAO" TO DS-PROCEDURE
      *               ELSE
      *                  MOVE "DESABILITA-ALTERACAO" TO DS-PROCEDURE
      *               END-IF
                      PERFORM CARREGAR-DADOS
      *            END-IF
               WHEN CPP020-HABILITA-SITUACAO-TRUE
                   MOVE CPP020-LINDET(1: 6) TO FORNEC-CP20
                   MOVE CPP020-LINDET(8: 5) TO SEQ-CP20
                   READ CPD020 INVALID KEY
                       MOVE "Contas a Pagar N�o Encontrado" TO MENSAGEM
                       MOVE "C" TO TIPO-MSG
                       PERFORM EXIBIR-MENSAGEM
                   NOT INVALID KEY
                       MOVE "SENHA28" TO PROGRAMA-CA004
                       MOVE COD-USUARIO-W TO COD-USUARIO-CA004
                       READ CAD004 INVALID KEY
                            MOVE "Usu�rio sem Permiss�o para Habilitar
      -                     "Contas a Pagar" TO MENSAGEM
                            MOVE "C" TO TIPO-MSG
                            PERFORM EXIBIR-MENSAGEM
                       NOT INVALID KEY
                            MOVE "Voc� Deseja Alterar a Situa��o do Cont
      -                     "as a Pagar ?" TO MENSAGEM
                            MOVE "Q" TO TIPO-MSG
                            PERFORM EXIBIR-MENSAGEM
                            IF RESP-MSG = "S"
                               MOVE 0 TO SITUACAO-CP20
                                         JURO-PAGO-CP20
                                         MULTA-PAGA-CP20
                                         DESCONTO-CP20
                                         DATA-PGTO-CP20
                                         VALOR-LIQ-CP20
                               REWRITE REG-CPD020 INVALID KEY
                                   MOVE "Erro de Regrava��o...CPD020" TO
                                   MENSAGEM
                                   MOVE "C" TO TIPO-MSG
                                   PERFORM EXIBIR-MENSAGEM
                               END-REWRITE
                            END-IF
                       END-READ
                   END-READ
               WHEN CPP020-DIVIDE-PARCELA-TRUE
                   PERFORM DIVIDE-PARCELAS
               WHEN CPP020-VERIF-TOT-PARC-TRUE
                   PERFORM VERIFICA-TOTAL-PARCELA
               WHEN CPP020-VERIFICA-TALAO-TRUE
                   PERFORM VERIFICA-TALAO
               WHEN CPP020-LE-NOMINAL-TRUE
                   PERFORM LE-NOMINAL
               WHEN CPP020-LE-FORNEC-TRUE
                   PERFORM LE-FORNEC
               WHEN CPP020-LE-BANCO-TRUE
                   PERFORM LE-BANCO
               WHEN CPP020-LE-SITUACAO-TRUE
                   PERFORM LE-SITUACAO
               WHEN CPP020-LE-PORTADOR-TRUE
                   PERFORM LE-PORTADOR
               WHEN CPP020-LE-TIPO-FORNEC-TRUE
                   PERFORM LE-TIPO-FORNEC
               WHEN CPP020-LE-COD-APURACAO-TRUE
                   PERFORM LE-COD-APURACAO
               WHEN CPP020-CHAMAR-APURACAO-TRUE
                   PERFORM CHAMAR-APURACAO
               WHEN CPP020-CARREGA-DATA-TRUE
                   PERFORM CARREGA-DATA
               WHEN CPP020-VERIF-DOCTO-TRUE
                   PERFORM VERIFICA-DOCTO-PERMANENTE
               WHEN CPP020-VERIF-PROGRAMACAO-TRUE
                   PERFORM VERIFICA-PROGRAMACAO
               WHEN CPP020-EMISSAO-VENCTO-TRUE
                   PERFORM INVERTE-EMIS-VENCTO
               WHEN CPP020-CHAMAR-POP-UP-TRUE
                    PERFORM CHAMAR-POP-UP
               WHEN CPP020-ITEM-SELEC-PROG-TRUE
                    PERFORM PROGRAMACAO-SELECIONADA
               WHEN CPP020-ITEM-SELECIONADO-TRUE
                    PERFORM ITEM-SELECIONADO-FORN
               WHEN CPP020-VERIF-TOT-DESM-TRUE
                    PERFORM TOTAL-DESMEMBRADO
               WHEN CPP020-VERIF-DESM-TRUE
                    PERFORM VERIF-DESMEMBRADO
           END-EVALUATE.
           PERFORM CLEAR-FLAGS.
           PERFORM CALL-DIALOG-SYSTEM.

           MOVE "SENHA50"     TO PROGRAMA-CA004
           MOVE COD-USUARIO-W TO COD-USUARIO-CA004
           READ CAD004 INVALID KEY
                DISABLE-OBJECT CB3
           NOT INVALID KEY
                ENABLE-OBJECT CB3.


       CENTRALIZAR SECTION.
          move-object-handle principal handle8
          move handle8 to wHandle
          invoke Window "fromHandleWithClass" using wHandle Window
                 returning janelaPrincipal

          invoke janelaPrincipal "CentralizarNoDesktop".

          MOVE "SENHA50"     TO PROGRAMA-CA004
          MOVE COD-USUARIO-W TO COD-USUARIO-CA004
          READ CAD004 INVALID KEY
               DISABLE-OBJECT CB3
          NOT INVALID KEY
               ENABLE-OBJECT CB3.

       CHAMAR-APURACAO SECTION.
           CALL   "CXP020T" USING PARAMETROS-W PASSAR-PARAMETROS
           CANCEL "CXP020T"
           MOVE PASSAR-STRING-1(52: 5) TO CPP020-COD-APURACAO
           PERFORM LE-COD-APURACAO.
       VERIF-DESMEMBRADO SECTION.
      * Utilizar para altera��o do contas a pagar
           MOVE ZEROS TO CPP020-TOTAL-DESMEMBRADO I.
           MOVE CPP020-COD-FORN TO FORNEC-CP23.
           MOVE SEQ-CP20        TO SEQ-CP23
           MOVE ZEROS           TO ITEM-CP23
           START CPD023 KEY IS NOT < CHAVE-CP23 INVALID KEY
                 MOVE "10" TO ST-CPD023.
           PERFORM UNTIL ST-CPD023 = "10"
               READ CPD023 NEXT RECORD AT END
                    MOVE "10" TO ST-CPD023
               NOT AT END
                    IF FORNEC-CP23 NOT = CPP020-COD-FORN OR
                       SEQ-CP23 NOT = SEQ-CP20
                       MOVE "10" TO ST-CPD020
                    ELSE
                       ADD 1 TO I
                       MOVE CODREDUZ-APUR-CP23 TO CPP020-COD-APUR-GR(I)
                                                  CODIGO-REDUZ-CX20
                       READ CXD020 INVALID KEY
                            MOVE SPACES     TO DESCRICAO-CX20
                       END-READ
                       MOVE DESCRICAO-CX20  TO CPP020-DESC-APUR-GR(I)
                       MOVE VALOR-CP23      TO CPP020-VALOR-GR(I)
                       ADD VALOR-CP23       TO CPP020-TOTAL-DESMEMBRADO
                    END-IF
               END-READ
           END-PERFORM.
           IF I = ZEROS
              MOVE 0                  TO CPP020-ACHOU-DESMEMBRAR
              MOVE CPP020-VALOR-TOTAL TO CPP020-TOTAL-DESMEMBRADO
           ELSE
              MOVE 1                  TO CPP020-ACHOU-DESMEMBRAR.

       TOTAL-DESMEMBRADO SECTION.
           MOVE ZEROS TO CPP020-TOTAL-DESMEMBRADO I.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 10
                 IF CPP020-VALOR-GR(I) = ZEROS
                    MOVE 10               TO I
                 ELSE
                   MOVE I                 TO QTDE-DESM
                   ADD CPP020-VALOR-GR(I) TO CPP020-TOTAL-DESMEMBRADO
                   COMPUTE PERC-GR(I) = (CPP020-VALOR-GR(I) * 100)
                           / CPP020-VALOR-TOTAL
                 END-IF
           END-PERFORM.
       CHAMAR-POP-UP SECTION.
           EVALUATE CPP020-OPCAO-POP-UP
             WHEN 1 PERFORM CARREGA-POP-UP-FORNEC
      *             CALL "CGP001T" USING PASSAR-PARAMETROS
      *             CANCEL "CGP001T"
      *             MOVE PASSAR-STRING-1(33: 6) TO CPP020-COD-FORN
             WHEN 2 CALL   "CAP019T" USING PARAMETROS-W
                                           PASSAR-PARAMETROS
                    CANCEL "CAP019T"
                    MOVE PASSAR-STRING-1(1: 30) TO
                         CPP020-DESCR-TIPO-FORN
                    MOVE PASSAR-STRING-1(33: 2) TO CPP020-TIPO-FORN
             WHEN 3 CALL   "CAP018T" USING PARAMETROS-W
                                           PASSAR-PARAMETROS
                    CANCEL "CAP018T"
                    MOVE PASSAR-STRING-1(1: 30) TO CPP020-DESCR-PORTADOR
                    MOVE PASSAR-STRING-1(33: 4) TO CPP020-PORTADOR
             WHEN 4
      *             PERFORM CARREGA-POP-UP-APURACAO
                    CALL "CXP020T" USING PARAMETROS-W PASSAR-PARAMETROS
                    CANCEL "CXP020T"
                    MOVE PASSAR-PARAMETROS(52: 5) TO CPP020-COD-APURACAO
                    MOVE CPP020-COD-APURACAO      TO CODIGO-REDUZ-CX20
                    READ CXD020 INVALID KEY
                         MOVE SPACES          TO DESCRICAO-CX20
                    END-READ
                    MOVE DESCRICAO-CX20       TO CPP020-DESCR-APURACAO
             WHEN 5 CALL   "CBP001T" USING PARAMETROS-W
                                           PASSAR-PARAMETROS
                    CANCEL "CBP001T"
                    MOVE PASSAR-STRING-1(17: 15) TO CPP020-DESC-BANCO-CH
                    MOVE PASSAR-STRING-1(49: 6) TO CPP020-BANCO-CH
             WHEN 6 CALL   "CBP003T" USING PARAMETROS-W
                                           PASSAR-PARAMETROS
                    CANCEL "CBP003T"
                    MOVE PASSAR-STRING-1(1: 30) TO
                                CPP020-DESC-SITUACAO-CH
                    MOVE PASSAR-STRING-1(40: 2) TO CPP020-SITUACAO-CH
           END-EVALUATE.
       ITEM-SELECIONADO-FORN SECTION.
           IF CPP020-OPCAO-POP-UP = 4
              PERFORM ITEM-SELECIONADO-APURACAO
           ELSE
            IF CPP020-OPCAO-POP-UP = 7
                MOVE CPP020-LINDET1(33: 6) TO CPP020-NOMINAL-A-CH
                MOVE CPP020-LINDET1(1: 30) TO CPP020-NOME-CH
            ELSE MOVE CPP020-LINDET1(33: 6)TO CPP020-COD-FORN
                 MOVE CPP020-LINDET1(1: 30) TO CPP020-DESCR-FORN.
       CARREGA-POP-UP-FORNEC SECTION.
           MOVE CPP020-LINDET1(1: 1) TO NOME-CG01 LETRA.
      *    MOVE SPACES TO NOME-CG01.
           START CGD001 KEY IS NOT < NOME-CG01 INVALID KEY
                 MOVE "10" TO ST-CGD001.
           PERFORM UNTIL ST-CGD001 = "10"
              READ CGD001 NEXT RECORD AT END MOVE "10" TO ST-CGD001
                NOT AT END
                  MOVE NOME-CG01     TO LETRA1
                  IF LETRA1 NOT = LETRA MOVE "10" TO ST-CGD001
                  ELSE CONTINUE
                  MOVE NOME-CG01     TO CPP020-LINDET1(1: 32)
                  MOVE CODIGO-CG01   TO CPP020-LINDET1(33: 06)
                  MOVE "INSERE-LISTA-POP-UP" TO DS-PROCEDURE
                  PERFORM CALL-DIALOG-SYSTEM
              END-READ
           END-PERFORM.
       ITEM-SELECIONADO-APURACAO SECTION.
           MOVE CPP020-LINDET1(52: 5)TO CPP020-COD-APURACAO.
           PERFORM LE-COD-APURACAO.
           MOVE DESCRICAO-CX20 TO CPP020-DESCR-APURACAO.
       CARREGA-POP-UP-APURACAO SECTION.
           MOVE "CLEAR-LIST-BOX1" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE ZEROS TO CODIGO-COMPL-CX20.
              START CXD020 KEY IS NOT < CODIGO-COMPL-CX20
                    INVALID KEY MOVE "10" TO ST-CXD020.
           PERFORM UNTIL ST-CXD020 = "10"
              READ CXD020 NEXT RECORD AT END MOVE "10" TO ST-CXD020
              NOT AT END
                MOVE SPACES TO CPP020-LINDET1
                MOVE CODIGO-COMPL-CX20 TO CODIGO-E
                EVALUATE GRAU-CX20
                  WHEN 1 PERFORM GRAU-1
                  WHEN 2 PERFORM GRAU-2
                  WHEN 3 PERFORM GRAU-3
                  WHEN 4 PERFORM GRAU-4
                END-EVALUATE
                MOVE "INSERE-POP-UP-APUR" TO DS-PROCEDURE
                PERFORM CALL-DIALOG-SYSTEM
              END-READ
           END-PERFORM.
       GRAU-1 SECTION.
           MOVE CODIGO-E          TO CPP020-LINDET1(1: 11)
           MOVE DESCRICAO-CX20    TO CPP020-LINDET1(12: 31)
           MOVE CODIGO-REDUZ-CX20 TO CPP020-LINDET1(52: 05).
       GRAU-2 SECTION.
           MOVE CODIGO-E          TO CPP020-LINDET1(4: 11)
           MOVE DESCRICAO-CX20    TO CPP020-LINDET1(15: 31)
           MOVE CODIGO-REDUZ-CX20 TO CPP020-LINDET1(52: 05).
       GRAU-3 SECTION.
           MOVE CODIGO-E          TO CPP020-LINDET1(7: 11)
           MOVE DESCRICAO-CX20    TO CPP020-LINDET1(18: 31)
           MOVE CODIGO-REDUZ-CX20 TO CPP020-LINDET1(52: 05).
       GRAU-4 SECTION.
           MOVE CODIGO-E          TO CPP020-LINDET1(10: 11)
           MOVE DESCRICAO-CX20    TO CPP020-LINDET1(21: 31)
           MOVE CODIGO-REDUZ-CX20 TO CPP020-LINDET1(52: 05).

       INVERTE-EMIS-VENCTO SECTION.
           MOVE CPP020-DATA-EMISSAO TO DATA-INV
           CALL "GRIDAT2" USING DATA-INV
           CANCEL "GRIDAT2".
           MOVE DATA-INV TO CPP020-EMISSAO-INV.
           MOVE CPP020-DATA-VENCTO TO DATA-INV.
           CALL "GRIDAT2" USING DATA-INV.
           CANCEL "GRIDAT2".
           MOVE DATA-INV TO CPP020-VENCTO-INV.
       CARREGA-DATA SECTION.
           MOVE DATA-MOVTO-W TO CPP020-DATA-MOVTO.
           MOVE "CARREGAR-DATA" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
       EXCLUI SECTION.
           OPEN I-O CPD099
           MOVE REG-CPD020 TO REG-CPD099
           WRITE REG-CPD099 NOT INVALID KEY
               MOVE USUARIO-W   TO LOG3-USUARIO
               MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
               MOVE WS-DATA-CPU TO LOG3-DATA
               ACCEPT WS-HORA-SYS FROM TIME
               MOVE WS-HORA-SYS TO LOG3-HORAS
               MOVE "I"         TO LOG3-OPERACAO
               MOVE "CPD099"    TO LOG3-ARQUIVO
               MOVE "CPP020"    TO LOG3-PROGRAMA
               MOVE REG-CPD099  TO LOG3-REGISTRO
               WRITE REG-LOG003
               END-WRITE.

           DELETE CPD020 NOT INVALID KEY
               MOVE USUARIO-W   TO LOG3-USUARIO
               MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
               MOVE WS-DATA-CPU TO LOG3-DATA
               ACCEPT WS-HORA-SYS FROM TIME
               MOVE WS-HORA-SYS TO LOG3-HORAS
               MOVE "E"         TO LOG3-OPERACAO
               MOVE "CPD020"    TO LOG3-ARQUIVO
               MOVE "CPP020"    TO LOG3-PROGRAMA
               MOVE REG-CPD020  TO LOG3-REGISTRO
               WRITE REG-LOG003
               END-WRITE.

      *    IF PORTADOR-CP20 = 12
      *       MOVE 8 TO SITUACAO-CB100
      *       IF CPP020-BANCO-CH <> ZEROS AND
      *          CPP020-NR-CHEQUE-CH <> ZEROS
      *            REWRITE REG-CBD100 NOT INVALID KEY
      *                MOVE USUARIO-W   TO LOG2-USUARIO
      *                MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
      *                MOVE WS-DATA-CPU TO LOG2-DATA
      *                ACCEPT WS-HORA-SYS FROM TIME
      *                MOVE WS-HORA-SYS TO LOG2-HORAS
      *                MOVE "A"         TO LOG2-OPERACAO
      *                MOVE "CBD100"    TO LOG2-ARQUIVO
      *                MOVE "CPP020"    TO LOG2-PROGRAMA
      *                MOVE REG-CBD100  TO LOG2-REGISTRO
      *                WRITE REG-LOG002
      *                END-WRITE.

           IF TIPO-CONTA-CP20 = 1
              PERFORM ESTORNA-PERMANENTE
           ELSE CLOSE CPD099.
           PERFORM LIMPAR-DADOS.
           PERFORM CARREGA-ULTIMOS.
       SUSPENDE-CANCELA SECTION.
           PERFORM VALIDA-DATA-LIMITE.
           REWRITE REG-CPD020 NOT INVALID KEY
               MOVE USUARIO-W   TO LOG3-USUARIO
               MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
               MOVE WS-DATA-CPU TO LOG3-DATA
               ACCEPT WS-HORA-SYS FROM TIME
               MOVE WS-HORA-SYS TO LOG3-HORAS
               MOVE "A"         TO LOG3-OPERACAO
               MOVE "CPD020"    TO LOG3-ARQUIVO
               MOVE "CPP020"    TO LOG3-PROGRAMA
               MOVE REG-CPD020  TO LOG3-REGISTRO
               WRITE REG-LOG003
               END-WRITE.

           MOVE FORNEC-CP20 TO NOMINAL-A-CB100.
           MOVE SEQ-CP20 TO SEQ-CTA-PAGAR-CB100.
           START CBD100 KEY IS = ALT2-CB100
              INVALID KEY CONTINUE
              NOT INVALID KEY
                READ CBD100 NEXT RECORD
                END-READ
                MOVE 8 TO SITUACAO-CB100
                REWRITE REG-CBD100 NOT INVALID KEY
                       MOVE USUARIO-W   TO LOG2-USUARIO
                       MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                       MOVE WS-DATA-CPU TO LOG2-DATA
                       ACCEPT WS-HORA-SYS FROM TIME
                       MOVE WS-HORA-SYS TO LOG2-HORAS
                       MOVE "A"         TO LOG2-OPERACAO
                       MOVE "CBD100"    TO LOG2-ARQUIVO
                       MOVE "CPP020"    TO LOG2-PROGRAMA
                       MOVE REG-CBD100  TO LOG2-REGISTRO
                       WRITE REG-LOG002
                       END-WRITE.

           IF CPP020-SUSPENDE-FLG-TRUE
              IF TIPO-CONTA-CP20 = 1
                 PERFORM SUSPENDE-CANCELA-PERMANENTE.
           IF CPP020-CANCELA-FLG-TRUE
              IF TIPO-CONTA-CP20 = 1
                 PERFORM SUSPENDE-CANCELA-PERMANENTE.
           PERFORM LIMPAR-DADOS.
           PERFORM CARREGA-ULTIMOS.
       SUSPENDE-CANCELA-PERMANENTE SECTION.
      *    SE SITUACAO = 0 PASSA SER 1 OU SITUACAO = 1 PASSA A SER 0
           MOVE FORNEC-W TO FORNEC-CP20.
           MOVE ZEROS TO SEQ-CP20.
           START CPD020 KEY IS NOT < CHAVE-CP20 INVALID KEY
                 MOVE "10" TO ST-CPD020.
           PERFORM UNTIL ST-CPD020 = "10"
              READ CPD020 NEXT RECORD AT END MOVE "10" TO ST-CPD020
                NOT AT END
                  IF FORNEC-CP20 NOT = FORNEC-W MOVE "10" TO ST-CPD020
                  ELSE
                    IF NR-DOCTO-CP20 NOT = DOCTO-W OR
      *                SITUACAO-CP20 NOT = 0 OR
                       TIPO-CONTA-CP20 NOT = 1
                         CONTINUE
                    ELSE
                      IF CPP020-SUSPENDE-FLG-TRUE
                         IF CPP020-SITUACAO = 0 MOVE 1 TO SITUACAO-CP20
                         ELSE MOVE 0 TO SITUACAO-CP20
                         END-IF
                      END-IF
                      IF CPP020-CANCELA-FLG-TRUE
                         MOVE 4 TO SITUACAO-CP20
                      END-IF
                      PERFORM VALIDA-DATA-LIMITE

                      REWRITE REG-CPD020 NOT INVALID KEY
                           MOVE USUARIO-W   TO LOG3-USUARIO
                           MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                           MOVE WS-DATA-CPU TO LOG3-DATA
                           ACCEPT WS-HORA-SYS FROM TIME
                           MOVE WS-HORA-SYS TO LOG3-HORAS
                           MOVE "A"         TO LOG3-OPERACAO
                           MOVE "CPD020"    TO LOG3-ARQUIVO
                           MOVE "CPP020"    TO LOG3-PROGRAMA
                           MOVE REG-CPD020  TO LOG3-REGISTRO
                           WRITE REG-LOG003
                           END-WRITE
                      END-REWRITE

                      MOVE FORNEC-CP20 TO NOMINAL-A-CB100
                      MOVE SEQ-CP20 TO SEQ-CTA-PAGAR-CB100
                      START CBD100 KEY IS = ALT2-CB100
                         INVALID KEY CONTINUE
                         NOT INVALID KEY
                           READ CBD100 NEXT RECORD
                           END-READ
                           MOVE 8 TO SITUACAO-CB100
                           REWRITE REG-CBD100 NOT INVALID KEY
                               MOVE USUARIO-W   TO LOG2-USUARIO
                               MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                               MOVE WS-DATA-CPU TO LOG2-DATA
                               ACCEPT WS-HORA-SYS FROM TIME
                               MOVE WS-HORA-SYS TO LOG2-HORAS
                               MOVE "A"         TO LOG2-OPERACAO
                               MOVE "CBD100"    TO LOG2-ARQUIVO
                               MOVE "CPP020"    TO LOG2-PROGRAMA
                               MOVE REG-CBD100  TO LOG2-REGISTRO
                               WRITE REG-LOG002
                               END-WRITE
                           END-REWRITE
                      END-START
              END-READ
           END-PERFORM.
      * Quando suspende uma conta permanente,as demais parcelas relacio-
      * nadas tamb�m dever�o ser suspensas
       ESTORNA-PERMANENTE SECTION.
           MOVE ZEROS TO SEQ-CP20.
           MOVE FORNEC-W TO FORNEC-CP20.
           START CPD020 KEY IS NOT < CHAVE-CP20 INVALID KEY
                 MOVE "10" TO ST-CPD020.
           PERFORM UNTIL ST-CPD020 = "10"
              READ CPD020 NEXT RECORD AT END MOVE "10" TO ST-CPD020
                NOT AT END
                  IF FORNEC-CP20 NOT = FORNEC-W MOVE "10" TO ST-CPD020
                  ELSE
                    IF NR-DOCTO-CP20 NOT = DOCTO-W OR
                       SITUACAO-CP20 NOT = 0 OR
                       TIPO-CONTA-CP20 NOT = 1
                         CONTINUE
                    ELSE
                      MOVE 3 TO SITUACAO-CP20
                      MOVE REG-CPD020 TO REG-CPD099
                      WRITE REG-CPD099 NOT INVALID KEY
                           MOVE USUARIO-W   TO LOG3-USUARIO
                           MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                           MOVE WS-DATA-CPU TO LOG3-DATA
                           ACCEPT WS-HORA-SYS FROM TIME
                           MOVE WS-HORA-SYS TO LOG3-HORAS
                           MOVE "I"         TO LOG3-OPERACAO
                           MOVE "CPD099"    TO LOG3-ARQUIVO
                           MOVE "CPP020"    TO LOG3-PROGRAMA
                           MOVE REG-CPD099  TO LOG3-REGISTRO
                           WRITE REG-LOG003
                           END-WRITE
                      END-WRITE
                      DELETE CPD020 NOT INVALID KEY
                           MOVE USUARIO-W   TO LOG3-USUARIO
                           MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                           MOVE WS-DATA-CPU TO LOG3-DATA
                           ACCEPT WS-HORA-SYS FROM TIME
                           MOVE WS-HORA-SYS TO LOG3-HORAS
                           MOVE "E"         TO LOG3-OPERACAO
                           MOVE "CPD020"    TO LOG3-ARQUIVO
                           MOVE "CPP020"    TO LOG3-PROGRAMA
                           MOVE REG-CPD020  TO LOG3-REGISTRO
                           WRITE REG-LOG003
                           END-WRITE
                      END-DELETE
                      MOVE FORNEC-CP20 TO NOMINAL-A-CB100
                      MOVE SEQ-CP20 TO SEQ-CTA-PAGAR-CB100
                      START CBD100 KEY IS = ALT2-CB100
                          INVALID KEY CONTINUE
                        NOT INVALID KEY
                         READ CBD100 NEXT RECORD
                         END-READ
                         MOVE 8 TO SITUACAO-CB100
                         REWRITE REG-CBD100 NOT INVALID KEY
                              MOVE USUARIO-W   TO LOG2-USUARIO
                              MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                              MOVE WS-DATA-CPU TO LOG2-DATA
                              ACCEPT WS-HORA-SYS FROM TIME
                              MOVE WS-HORA-SYS TO LOG2-HORAS
                              MOVE "A"         TO LOG2-OPERACAO
                              MOVE "CBD100"    TO LOG2-ARQUIVO
                              MOVE "CPP020"    TO LOG2-PROGRAMA
                              MOVE REG-CBD100  TO LOG2-REGISTRO
                              WRITE REG-LOG002
                              END-WRITE
                         END-REWRITE
                      END-START
              END-READ
           END-PERFORM.
           CLOSE CPD099.
      * Quando estorna uma conta permanente, as demais parcelas relacio-
      * nadas tamb�m dever�o ser exclu�das
       VERIFICA-TALAO SECTION.
           MOVE ZEROS TO I CPP020-ERRO-NR-CHEQUE.
           IF CPP020-QT-PARCELA <> ZEROS
            MOVE CPP020-NR-CHEQUE-CH TO NR-CHEQUE-W NR-CHEQUE-CB100
            MOVE CPP020-BANCO-CH     TO NOMINAL-A-CB100
            IF CPP020-NR-CHEQUE-CH = ZEROS AND CPP020-BANCO-CH = ZEROS
               CONTINUE
            ELSE
             START CBD100 KEY IS NOT < CHAVE-CB100 INVALID KEY
                   MOVE "10" TO ST-CBD100
             END-START
             MOVE 1 TO CPP020-ERRO-NR-CHEQUE
             PERFORM UNTIL ST-CBD100 = "10"
              READ CBD100 NEXT RECORD AT END MOVE "10" TO ST-CBD100
                NOT AT END
      *  SITUACAO = 01-CH.EM BRANCO  03-CH.A PRAZO
                  IF SITUACAO-CB100 <> 01 AND <> 03
                     MOVE "10" TO ST-CBD100
                  ELSE
                   ADD 1 TO I
                   IF I = CPP020-QT-PARCELA MOVE "10" TO ST-CBD100
                                 MOVE 0 TO CPP020-ERRO-NR-CHEQUE
                   END-IF
                  END-IF
              END-READ
             END-PERFORM
            END-IF
           ELSE
            IF CPP020-NR-CHEQUE-CH = ZEROS AND CPP020-BANCO-CH = ZEROS
               CONTINUE
            ELSE
                MOVE CPP020-NR-CHEQUE-CH TO NR-CHEQUE-CB100
                MOVE CPP020-BANCO-CH     TO CODIGO-FORN-CB100
                READ CBD100 INVALID KEY MOVE 1 TO CPP020-ERRO-NR-CHEQUE
                  NOT INVALID KEY CONTINUE
                END-READ
            END-IF
           END-IF.
       VERIFICA-12PERMANENTE SECTION.
           MOVE ZEROS TO DATA-VENCTO-CP20 SITUACAO-CP20.
           MOVE FORNEC-CP20   TO FORNEC-W.
           MOVE NR-DOCTO-CP20 TO DOCTO-W.
           MOVE ZEROS TO QT-PARCELAS ULT-VENCTO.
           START CPD020 KEY IS NOT < ALT4-CP20 INVALID KEY
                 MOVE "10" TO ST-CPD020.
           PERFORM UNTIL ST-CPD020 = "10"
              READ CPD020 NEXT RECORD AT END MOVE "10" TO ST-CPD020
                NOT AT END
                  IF FORNEC-CP20 NOT = FORNEC-W OR
                    SITUACAO-CP20 NOT = 0 MOVE "10" TO ST-CPD020
                  ELSE
                    IF NR-DOCTO-CP20 NOT = DOCTO-W OR
                       TIPO-CONTA-CP20 NOT = 1 OR
                       PREV-DEF-CP20 = 0 CONTINUE
                    ELSE
                       ADD 1 TO QT-PARCELAS
                       IF DATA-VENCTO-CP20 > ULT-VENCTO
                          MOVE DATA-VENCTO-CP20 TO ULT-VENCTO
                       END-IF
                    END-IF
                 END-IF
             END-READ
           END-PERFORM.
           IF QT-PARCELAS < 12
              PERFORM GRAVA-PERMANENTE-12
                 UNTIL QT-PARCELAS = 12

           END-IF.
      *    verifica se existe 12 parcelas permanentes programadas,
      *    caso n�o haja, completar.
       GRAVA-PERMANENTE-12 SECTION.
           ADD 1 TO QT-PARCELAS
           MOVE ULT-VENCTO TO DATA-WI
           MOVE CPP020-COD-FORN TO FORNEC-CP21
           ADD 1 TO MES-WI
           IF MES-WI > 12 MOVE 1 TO MES-WI  ADD 1 TO ANO-WI
           END-IF
           PERFORM ATUALIZA-SEQ-CPD021
           MOVE SEQ-CP21  TO SEQ-CP20
           MOVE 1         TO PREV-DEF-CP20
           MOVE 2         TO GRTIME-TYPE
           MOVE 7         TO GRTIME-FUNCTION
           MOVE DATA-WI   TO DATA-VENCTO-CP20 GRTIME-DATE
                             DATA-WII
           CALL "GRTIME" USING PARAMETROS-GRTIME
           CANCEL "GRTIME"
           IF GRTIME-DATE-FINAL = ZEROS
              MOVE 1      TO DIA-WII
              ADD 1       TO MES-WII
              MOVE ANO-WI TO ANO-WII
              IF MES-WII = 13 MOVE 01 TO MES-WII
                              ADD 1   TO ANO-WII
              END-IF
              MOVE DATA-WII TO DATA-VENCTO-CP20
           END-IF
           MOVE DATA-VENCTO-CP20 TO ULT-VENCTO
           PERFORM VALIDA-DATA-LIMITE
           WRITE REG-CPD020 INVALID KEY
              MOVE "CPD020"  TO CPP020-MENSAGEM-ERRO(15: 07)
              MOVE ST-CPD020 TO CPP020-MENSAGEM-ERRO(23: 02)
              PERFORM ERRO-GRAVACAO
           NOT INVALID KEY
              MOVE USUARIO-W   TO LOG3-USUARIO
              MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
              MOVE WS-DATA-CPU TO LOG3-DATA
              ACCEPT WS-HORA-SYS FROM TIME
              MOVE WS-HORA-SYS TO LOG3-HORAS
              MOVE "I"         TO LOG3-OPERACAO
              MOVE "CPD020"    TO LOG3-ARQUIVO
              MOVE "CPP020"    TO LOG3-PROGRAMA
              MOVE REG-CPD020  TO LOG3-REGISTRO
              WRITE REG-LOG003
              END-WRITE
           END-WRITE
      *    PERFORM GRAVA-CIE
           PERFORM MOVER-DADOS-LISTA
           MOVE "INSERE-LIST" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.

       GRAVA-DESMEMBRADO SECTION.
           IF CPP020-TIPO-GRAVACAO = 1
              MOVE FORNEC-CP20  TO FORNEC-CP23
              MOVE SEQ-CP20     TO SEQ-CP23
              MOVE ZEROS        TO ITEM-CP23
              START CPD023 KEY IS NOT < CHAVE-CP23 INVALID KEY
                    MOVE "10" TO ST-CPD023
              END-START
              PERFORM UNTIL ST-CPD023 = "10"
                READ CPD023 NEXT RECORD AT END MOVE "10" TO ST-CPD023
                  NOT AT END
                    IF FORNEC-CP23 NOT = FORNEC-CP20 OR
                       SEQ-CP23 NOT = SEQ-CP20
                          MOVE "10" TO ST-CPD023
                    ELSE
                      DELETE CPD023 NOT INVALID KEY
                           MOVE USUARIO-W   TO LOG1-USUARIO
                           MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                           MOVE WS-DATA-CPU TO LOG1-DATA
                           ACCEPT WS-HORA-SYS FROM TIME
                           MOVE WS-HORA-SYS TO LOG1-HORAS
                           MOVE "E"         TO LOG1-OPERACAO
                           MOVE "CPD023"    TO LOG1-ARQUIVO
                           MOVE "CPP020"    TO LOG1-PROGRAMA
                           MOVE REG-CPD023  TO LOG1-REGISTRO
                           WRITE REG-LOG001
                           END-WRITE
                      END-DELETE
                    END-IF
                END-READ
              END-PERFORM.
           MOVE FORNEC-CP20   TO FORNEC-CP23.
           MOVE SEQ-CP20      TO SEQ-CP23.
           IF CPP020-PARCELA = 1
                  IF CPP020-DESMEMBRAR = 1
                     PERFORM VARYING J FROM 1 BY 1 UNTIL J > QTDE-DESM
                       ADD 1 TO K
                       MOVE K TO ITEM-CP23
                       COMPUTE VALOR-CP23 = CPP020-VALOR(I) *
                                                (PERC-GR(J) / 100)
                       ADD VALOR-CP23 TO VALOR-TOT-DESM
                       IF J = QTDE-DESM
                          COMPUTE VALOR-CP23 = VALOR-CP23 +
                            (CPP020-VALOR(I) - VALOR-TOT-DESM)
                          MOVE ZEROS       TO VALOR-TOT-DESM
                       END-IF
                       MOVE CPP020-COD-APUR-GR(J) TO CODREDUZ-APUR-CP23
                       WRITE REG-CPD023 INVALID KEY
                           REWRITE REG-CPD023 NOT INVALID KEY
                               MOVE USUARIO-W   TO LOG1-USUARIO
                               MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                               MOVE WS-DATA-CPU TO LOG1-DATA
                               ACCEPT WS-HORA-SYS FROM TIME
                               MOVE WS-HORA-SYS TO LOG1-HORAS
                               MOVE "I"         TO LOG1-OPERACAO
                               MOVE "CPD023"    TO LOG1-ARQUIVO
                               MOVE "CPP020"    TO LOG1-PROGRAMA
                               MOVE REG-CPD023  TO LOG1-REGISTRO
                               WRITE REG-LOG001
                               END-WRITE
                           END-REWRITE
                       NOT INVALID KEY
                           MOVE USUARIO-W   TO LOG1-USUARIO
                           MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                           MOVE WS-DATA-CPU TO LOG1-DATA
                           ACCEPT WS-HORA-SYS FROM TIME
                           MOVE WS-HORA-SYS TO LOG1-HORAS
                           MOVE "I"         TO LOG1-OPERACAO
                           MOVE "CPD023"    TO LOG1-ARQUIVO
                           MOVE "CPP020"    TO LOG1-PROGRAMA
                           MOVE REG-CPD023  TO LOG1-REGISTRO
                           WRITE REG-LOG001
                           END-WRITE
                       END-WRITE
                     END-PERFORM
                  ELSE CONTINUE
                  END-IF
           ELSE
           PERFORM VARYING L FROM 1 BY 1 UNTIL L > 10
              IF CPP020-COD-APUR-GR(L) = ZEROS MOVE 11 TO L
              ELSE MOVE L                     TO ITEM-CP23
                   MOVE CPP020-COD-APUR-GR(L) TO CODREDUZ-APUR-CP23
                   MOVE CPP020-VALOR-GR(L)    TO VALOR-CP23
                   WRITE REG-CPD023 INVALID KEY
                         REWRITE REG-CPD023 NOT INVALID KEY
                             MOVE USUARIO-W   TO LOG1-USUARIO
                             MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                             MOVE WS-DATA-CPU TO LOG1-DATA
                             ACCEPT WS-HORA-SYS FROM TIME
                             MOVE WS-HORA-SYS TO LOG1-HORAS
                             MOVE "I"         TO LOG1-OPERACAO
                             MOVE "CPD023"    TO LOG1-ARQUIVO
                             MOVE "CPP020"    TO LOG1-PROGRAMA
                             MOVE REG-CPD023  TO LOG1-REGISTRO
                             WRITE REG-LOG001
                             END-WRITE
                         END-REWRITE
                   NOT INVALID KEY
                         MOVE USUARIO-W   TO LOG1-USUARIO
                         MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                         MOVE WS-DATA-CPU TO LOG1-DATA
                         ACCEPT WS-HORA-SYS FROM TIME
                         MOVE WS-HORA-SYS TO LOG1-HORAS
                         MOVE "I"         TO LOG1-OPERACAO
                         MOVE "CPD023"    TO LOG1-ARQUIVO
                         MOVE "CPP020"    TO LOG1-PROGRAMA
                         MOVE REG-CPD023  TO LOG1-REGISTRO
                         WRITE REG-LOG001
                         END-WRITE
                   END-WRITE
              END-IF
           END-PERFORM.
       INCLUI-PERMANENTE SECTION.
           MOVE CPP020-COD-FORN       TO FORNEC-CP21.
           MOVE DATA-VENCTO-CP20      TO DATA-WI.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 12
                   ADD 1 TO MES-WI
                   IF MES-WI > 12
                      MOVE 1 TO MES-WI  ADD 1 TO ANO-WI
                   END-IF

                   PERFORM ATUALIZA-SEQ-CPD021

                   MOVE SEQ-CP21  TO SEQ-CP20
                   MOVE 1         TO PREV-DEF-CP20
                   MOVE 2         TO GRTIME-TYPE
                   MOVE 7         TO GRTIME-FUNCTION
                   MOVE DATA-WI   TO DATA-VENCTO-CP20 GRTIME-DATE
                                     DATA-WII
      *            VERIFICA SE DATA VALIDA
                   CALL "GRTIME" USING PARAMETROS-GRTIME
                   CANCEL "GRTIME"
                   IF GRTIME-DATE-FINAL = ZEROS
                      MOVE 1      TO DIA-WII
                      ADD 1       TO MES-WII
                      MOVE ANO-WI TO ANO-WII
                      IF MES-WII = 13 MOVE 01 TO MES-WII
                                      ADD 1   TO ANO-WII
                      END-IF
                      MOVE DATA-WII TO DATA-VENCTO-CP20
                   END-IF
                   MOVE CPP020-DATA-MOVTO TO DATA-INV
                   CALL "GRIDAT2" USING DATA-INV
                   MOVE DATA-INV TO DATA-MOVTO-CP20

                   PERFORM VALIDA-DATA-LIMITE

                   WRITE REG-CPD020 INVALID KEY
                       MOVE "CPD020"  TO CPP020-MENSAGEM-ERRO(15: 07)
                       MOVE ST-CPD020 TO CPP020-MENSAGEM-ERRO(23: 02)
                       PERFORM ERRO-GRAVACAO
                   NOT INVALID KEY
                       MOVE USUARIO-W   TO LOG3-USUARIO
                       MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                       MOVE WS-DATA-CPU TO LOG3-DATA
                       ACCEPT WS-HORA-SYS FROM TIME
                       MOVE WS-HORA-SYS TO LOG3-HORAS
                       MOVE "I"         TO LOG3-OPERACAO
                       MOVE "CPD020"    TO LOG3-ARQUIVO
                       MOVE "CPP020"    TO LOG3-PROGRAMA
                       MOVE REG-CPD020  TO LOG3-REGISTRO
                       WRITE REG-LOG003
                       END-WRITE
                   END-WRITE
      *            PERFORM GRAVA-CIE

                   PERFORM MOVER-DADOS-LISTA
                   MOVE "INSERE-LIST" TO DS-PROCEDURE
                   PERFORM CALL-DIALOG-SYSTEM
           END-PERFORM.
      * Inclus�o de 12 parcelas a serem pagas / contas permanentes
       ALTERA-PERMANENTE SECTION.
           MOVE SEQ-CP20 TO SEQ-ALTERADA.
           MOVE ZEROS TO SITUACAO-CP20 DATA-VENCTO-CP20.
           MOVE FORNEC-W      TO FORNEC-CP20.
           MOVE ZEROS         TO SEQ-CP20.
           MOVE CPP020-VENCTO-INV(7: 2) TO DIA-PADRAO.
      *    altera apenas o dia de vencto
           START CPD020 KEY IS NOT < CHAVE-CP20 INVALID KEY
                 MOVE "10" TO ST-CPD020.
           PERFORM UNTIL ST-CPD020 = "10"
              READ CPD020 NEXT RECORD AT END
                   MOVE "10" TO ST-CPD020
              NOT AT END
                  IF FORNEC-CP20 NOT = FORNEC-W
                     MOVE "10" TO ST-CPD020
                  ELSE
                     IF NR-DOCTO-CP20 NOT = DOCTO-W OR
                        TIPO-CONTA-CP20 NOT = 1 OR
                        SEQ-CP20 = SEQ-ALTERADA OR
                        SITUACAO-CP20 NOT = 0
                        CONTINUE
                     ELSE
                        MOVE CPP020-TIPO-FORN     TO TIPO-FORN-CP20
                        MOVE CPP020-PORTADOR      TO PORTADOR-CP20
                        MOVE CPP020-DESCRICAO     TO DESCRICAO-CP20
                        MOVE CPP020-TIPO-MOEDA(1: 1) TO TIPO-MOEDA-CP20
                        MOVE CPP020-COD-APURACAO  TO CODREDUZ-APUR-CP20
                        MOVE CPP020-JUROS-MORA    TO JUROS-MORA-CP20
                        MOVE CPP020-MULTA-ATRASO  TO MULTA-ATRASO-CP20
                        MOVE CPP020-VALOR-TOTAL   TO VALOR-TOT-CP20
                        MOVE CPP020-EMISSAO-INV   TO DATA-EMISSAO-CP20
                        MOVE DATA-VENCTO-CP20     TO DATA-WI ULT-VENCTO
                        MOVE DIA-PADRAO TO DIA-WI
                        MOVE 2         TO GRTIME-TYPE
                        MOVE 7         TO GRTIME-FUNCTION
                        MOVE DATA-WI   TO DATA-VENCTO-CP20 GRTIME-DATE
                                          DATA-WII
                        CALL "GRTIME" USING PARAMETROS-GRTIME
                        CANCEL "GRTIME"
                        IF GRTIME-DATE-FINAL = ZEROS
                           MOVE ULT-VENCTO TO DATA-VENCTO-CP20
                        END-IF

                        PERFORM VALIDA-DATA-LIMITE

                        REWRITE REG-CPD020 NOT INVALID KEY
                             MOVE USUARIO-W   TO LOG3-USUARIO
                             MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                             MOVE WS-DATA-CPU TO LOG3-DATA
                             ACCEPT WS-HORA-SYS FROM TIME
                             MOVE WS-HORA-SYS TO LOG3-HORAS
                             MOVE "A"         TO LOG3-OPERACAO
                             MOVE "CPD020"    TO LOG3-ARQUIVO
                             MOVE "CPP020"    TO LOG3-PROGRAMA
                             MOVE REG-CPD020  TO LOG3-REGISTRO
                             WRITE REG-LOG003
                             END-WRITE
                        END-REWRITE
                     END-IF
                  END-IF
              END-READ
           END-PERFORM.
           PERFORM CARREGA-ULTIMOS.
      * caso a opcao op-alter-permanente = 2 (todas) altera todas as
      * contas permanentes previstas
       LE-FORNEC SECTION.
           MOVE CPP020-COD-FORN   TO CODIGO-CG01.
           READ CGD001 INVALID KEY MOVE "********" TO NOME-CG01.
           MOVE NOME-CG01         TO CPP020-DESCR-FORN CPP020-NOME-CH.
       LE-NOMINAL SECTION.
           MOVE CPP020-NOMINAL-A-CH TO CODIGO-CG01.
           READ CGD001 INVALID KEY MOVE "********" TO NOME-CG01.
           MOVE NOME-CG01         TO CPP020-NOME-CH.
       LE-BANCO SECTION.
           OPEN INPUT CBD001.
           MOVE CPP020-BANCO-CH   TO CODIGO-FORN-CB01.
           READ CBD001 INVALID KEY MOVE "********" TO NOME-BANCO-CB01.
           MOVE NOME-BANCO-CB01 TO CPP020-DESC-BANCO-CH.
           CLOSE CBD001.
       LE-SITUACAO SECTION.
           OPEN INPUT CBD003.
           MOVE CPP020-SITUACAO-CH TO SITUACAO-CB03.
           READ CBD003 INVALID KEY MOVE "********" TO NOME-SIT-CB03.
           MOVE NOME-SIT-CB03   TO CPP020-DESC-SITUACAO-CH.
           CLOSE CBD003.
       LE-PORTADOR SECTION.
           MOVE CPP020-PORTADOR    TO PORTADOR.
           READ CAD018 INVALID KEY MOVE "******" TO NOME-PORT.
           MOVE NOME-PORT          TO CPP020-DESCR-PORTADOR.
       LE-TIPO-FORNEC SECTION.
           MOVE CPP020-TIPO-FORN   TO CODIGO-TIPO.
           READ CAD019 INVALID KEY MOVE "****" TO NOME-TIPO.
           MOVE NOME-TIPO          TO CPP020-DESCR-TIPO-FORN.
       LE-COD-APURACAO SECTION.
           MOVE CPP020-COD-APURACAO TO CODIGO-REDUZ-CX20.
           READ CXD020 INVALID KEY MOVE "*****" TO DESCRICAO-CX20
                                   MOVE ZEROS TO TIPO-CONTA-CX20.
           MOVE DESCRICAO-CX20      TO CPP020-DESCR-APURACAO.
           IF TIPO-CONTA-CX20 = 0
               MOVE 0 TO CPP020-TIPO-CONTA-APUR
           ELSE MOVE 1 TO CPP020-TIPO-CONTA-APUR.
       CARREGAR-DADOS SECTION.
           START CPD020 KEY IS = CHAVE-CP20 INVALID KEY CONTINUE.
           READ CPD020 INVALID KEY INITIALIZE REG-CPD020.
           MOVE DATA-MOVTO-CP20    TO DATA-INV
           CALL "GRIDAT1" USING DATA-INV
           MOVE DATA-INV           TO CPP020-DATA-MOVTO.
           MOVE FORNEC-CP20        TO CPP020-COD-FORN CODIGO-CG01.
           READ CGD001 INVALID KEY MOVE "*****" TO NOME-CG01.
           MOVE NOME-CG01          TO CPP020-DESCR-FORN.
           MOVE TIPO-FORN-CP20     TO CPP020-TIPO-FORN CODIGO-TIPO.
           READ CAD019 INVALID KEY MOVE "****" TO NOME-TIPO.
           MOVE NOME-TIPO          TO CPP020-DESCR-TIPO-FORN.
           MOVE PORTADOR-CP20      TO CPP020-PORTADOR PORTADOR.
           READ CAD018 INVALID KEY MOVE "******" TO NOME-PORT.
           MOVE NOME-PORT          TO CPP020-DESCR-PORTADOR.
           MOVE NR-DOCTO-CP20      TO CPP020-NR-DOCTO.
           MOVE DATA-EMISSAO-CP20  TO DATA-INV.
           CALL "GRIDAT1" USING DATA-INV.
           MOVE DATA-INV           TO CPP020-DATA-EMISSAO.
           MOVE DATA-VENCTO-CP20   TO DATA-INV.
           CALL "GRIDAT1" USING DATA-INV.
           MOVE DATA-INV           TO CPP020-DATA-VENCTO.
           MOVE DESCRICAO-CP20     TO CPP020-DESCRICAO.
           MOVE DIGITADOR-CP20     TO CPP020-DIGITADOR.
           MOVE TIPO-MOEDA-CP20    TO CPP020-TIPO-MOEDA.
           EVALUATE TIPO-MOEDA-CP20
             WHEN 0 MOVE "-Real"   TO CPP020-TIPO-MOEDA(2: 6)
             WHEN 1 MOVE "-Dolar"  TO CPP020-TIPO-MOEDA(2: 5)
           END-EVALUATE
           MOVE CODREDUZ-APUR-CP20 TO CPP020-COD-APURACAO
                                      CODIGO-REDUZ-CX20.
           READ CXD020 INVALID KEY MOVE "*****" TO DESCRICAO-CX20.
           MOVE DESCRICAO-CX20     TO CPP020-DESCR-APURACAO.
           MOVE PREV-DEF-CP20      TO CPP020-PREV-DEF
           EVALUATE PREV-DEF-CP20
             WHEN 0 MOVE "-Definitivo" TO CPP020-PREV-DEF(2: 11)
             WHEN 1 MOVE "-Previsto  " TO CPP020-PREV-DEF(2: 11)
           END-EVALUATE
           MOVE JUROS-MORA-CP20    TO CPP020-JUROS-MORA.
           MOVE MULTA-ATRASO-CP20  TO CPP020-MULTA-ATRASO.
           MOVE TAXA-APLIC-CP20    TO CPP020-TAXA
           MOVE VALOR-TOT-CP20     TO CPP020-VALOR-TOTAL.
           MOVE RESPONSAVEL-CP20   TO CPP020-RESPONSAVEL.

           MOVE SITUACAO-CP20      TO CPP020-SITUACAO.

           MOVE TIPO-CONTA-CP20    TO CPP020-TIPO-CONTA
                                      CPP020-TIPO-CONTAW.

           MOVE FORNEC-CP20    TO FORNEC-CP22
           MOVE SEQ-CP20       TO SEQ-CP22
           READ CPD022 INVALID KEY
                MOVE SPACES        TO CPP020-OBSERVACAO
           NOT INVALID KEY
                MOVE OBS-CP22      TO CPP020-OBSERVACAO
           END-READ

           EVALUATE TIPO-CONTA-CP20
             WHEN 0 MOVE "-Tempor�ria" TO CPP020-TIPO-CONTA(2: 11)
             WHEN 1 MOVE "-Permanente" TO CPP020-TIPO-CONTA(2: 11)
           END-EVALUATE.
      *    Se for um lan�amento com cheque pr�-datado
      *    IF PORTADOR-CP20 = 12
      *       MOVE SEQ-CP20 TO SEQ-CTA-PAGAR-CB100
      *       MOVE FORNEC-CP20 TO NOMINAL-A-CB100
      *       START CBD100 KEY IS = ALT2-CB100 INVALID KEY
      *                    CONTINUE
      *         NOT INVALID KEY
      *         READ CBD100 NEXT RECORD
      *         END-READ
      *         OPEN INPUT CBD001 CBD003
      *         MOVE CODIGO-FORN-CB100    TO CPP020-BANCO-CH
      *                                      CODIGO-FORN-CB01
      *         READ CBD001 INVALID KEY MOVE SPACES TO NOME-BANCO-CB01
      *         END-READ
      *         MOVE NOME-BANCO-CB01      TO CPP020-DESC-BANCO-CH
      *         MOVE NR-CHEQUE-CB100      TO CPP020-NR-CHEQUE-CH
      *         MOVE NOMINAL-A-CB100      TO CPP020-NOMINAL-A-CH
      *                                      CODIGO-CG01
      *         READ CGD001 INVALID KEY MOVE SPACES TO NOME-CG01
      *         END-READ
      *         MOVE NOME-CG01            TO CPP020-NOME-CH
      *         MOVE VALOR-CB100          TO CPP020-VALOR-CH
      *         MOVE DATA-EMISSAO-CB100   TO CPP020-EMISSAO-CH
      *         MOVE DATA-VENCTO-CB100    TO CPP020-VENCTO-CH
      *         MOVE SITUACAO-CB100       TO CPP020-SITUACAO-CH
      *                                      SITUACAO-CB03
      *         READ CBD003 INVALID KEY MOVE SPACES TO NOME-SIT-CB03
      *         END-READ
      *         MOVE NOME-SIT-CB03        TO CPP020-DESC-SITUACAO-CH
      *         CLOSE CBD001 CBD003.
       CARREGA-MENSAGEM-ERRO SECTION.
           PERFORM LOAD-SCREENSET
           MOVE "EXIBE-ERRO" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE 1 TO ERRO-W.
       ATUALIZA-SEQ-CPD021 SECTION.
           READ CPD021 INVALID KEY
                MOVE 1 TO SEQ-CP21
                WRITE REG-CPD021 INVALID KEY
                        MOVE "CPD021"    TO CPP020-MENSAGEM-ERRO(15: 7)
                        MOVE "ST-CPD021" TO CPP020-MENSAGEM-ERRO(23: 2)
                        PERFORM ERRO-GRAVACAO
                NOT INVALID KEY
                        MOVE USUARIO-W   TO LOG1-USUARIO
                        MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                        MOVE WS-DATA-CPU TO LOG1-DATA
                        ACCEPT WS-HORA-SYS FROM TIME
                        MOVE WS-HORA-SYS TO LOG1-HORAS
                        MOVE "I"         TO LOG1-OPERACAO
                        MOVE "CPD021"    TO LOG1-ARQUIVO
                        MOVE "CPP020"    TO LOG1-PROGRAMA
                        MOVE REG-CPD021  TO LOG1-REGISTRO
                        WRITE REG-LOG001
                        END-WRITE

                END-WRITE
              NOT INVALID KEY
                  ADD 1 TO SEQ-CP21
                  REWRITE REG-CPD021 INVALID KEY
                        MOVE "CPD021"    TO CPP020-MENSAGEM-ERRO(15: 7)
                        MOVE "ST-CPD021" TO CPP020-MENSAGEM-ERRO(23: 2)
                        PERFORM ERRO-GRAVACAO
                  NOT INVALID KEY
                        MOVE USUARIO-W   TO LOG1-USUARIO
                        MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                        MOVE WS-DATA-CPU TO LOG1-DATA
                        ACCEPT WS-HORA-SYS FROM TIME
                        MOVE WS-HORA-SYS TO LOG1-HORAS
                        MOVE "A"         TO LOG1-OPERACAO
                        MOVE "CPD021"    TO LOG1-ARQUIVO
                        MOVE "CPP020"    TO LOG1-PROGRAMA
                        MOVE REG-CPD021  TO LOG1-REGISTRO
                        WRITE REG-LOG001
                        END-WRITE
                  END-REWRITE
           END-READ.
       LIMPAR-DADOS SECTION.
           MOVE CPP020-DATA-MOVTO TO DATA-MOVTO-W
           INITIALIZE REG-CPD020
           INITIALIZE CPP020-DATA-BLOCK
           MOVE DATA-MOVTO-W TO CPP020-DATA-MOVTO.
           PERFORM SET-UP-FOR-REFRESH-SCREEN.
           PERFORM CALL-DIALOG-SYSTEM
           MOVE ZEROS TO CPP020-PARCELA CPP020-GRAVA-OBS
                         CPP020-DESMEMBRAR.

          MOVE "SENHA50"     TO PROGRAMA-CA004
          MOVE COD-USUARIO-W TO COD-USUARIO-CA004
          READ CAD004 INVALID KEY
               DISABLE-OBJECT CB3
          NOT INVALID KEY
               ENABLE-OBJECT CB3.

       DIVIDE-PARCELAS SECTION.
           COMPUTE VLR-PARCELA = CPP020-VALOR-TOTAL / CPP020-QT-PARCELA.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 24
               MOVE ZEROS TO CPP020-VALOR(I) CPP020-NR(I)
                             CPP020-VENCTO(I)
           END-PERFORM.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CPP020-QT-PARCELA
               MOVE VLR-PARCELA       TO CPP020-VALOR(I)
               MOVE I                 TO CPP020-NR(I)
           END-PERFORM.
           COMPUTE CPP020-VALOR(1) = (CPP020-VALOR-TOTAL - (
                   CPP020-QT-PARCELA * VLR-PARCELA)) + VLR-PARCELA.
           MOVE CPP020-DATA-VENCTO     TO CPP020-VENCTO(1).
           PERFORM INVERTE-EMIS-VENCTO.
           MOVE CPP020-VENCTO-INV TO DATA-WI.
           PERFORM VARYING I FROM 2 BY 1 UNTIL I > CPP020-QT-PARCELA
                   ADD 1 TO MES-WI
                   IF MES-WI > 12
                      MOVE 1 TO MES-WI  ADD 1 TO ANO-WI
                   END-IF
                   MOVE 2         TO GRTIME-TYPE
                   MOVE 7         TO GRTIME-FUNCTION
                   MOVE DATA-WI   TO GRTIME-DATE DATA-WII DATA-INV
                   CALL "GRIDAT1" USING DATA-INV
                   MOVE DATA-INV  TO CPP020-VENCTO(I)
                   CALL "GRTIME" USING PARAMETROS-GRTIME
                   CANCEL "GRTIME"
                   IF GRTIME-DATE-FINAL = ZEROS
                      MOVE 1      TO DIA-WII
                      ADD 1       TO MES-WII
                      IF MES-WII = 13 MOVE 01 TO MES-WII
                                      ADD 1   TO ANO-WII
                      END-IF
                      MOVE DATA-WII TO DATA-INV
                      CALL "GRIDAT1" USING DATA-INV
                      MOVE DATA-INV TO CPP020-VENCTO(I)
                   END-IF
           END-PERFORM.
       VERIFICA-TOTAL-PARCELA SECTION.
           MOVE ZEROS TO VLR-PARCELA.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > CPP020-QT-PARCELA
              ADD CPP020-VALOR(I) TO VLR-PARCELA
           END-PERFORM.
           MOVE VLR-PARCELA  TO CPP020-VLR-TOT-PARCELA.
       SALVAR-DADOS SECTION.
           MOVE CPP020-DATA-MOVTO     TO DATA-INV
           CALL "GRIDAT2" USING DATA-INV
           MOVE DATA-INV              TO DATA-MOVTO-CP20.
           MOVE CPP020-COD-FORN       TO FORNEC-CP20
           MOVE CPP020-TIPO-FORN      TO TIPO-FORN-CP20
           MOVE CPP020-PORTADOR       TO PORTADOR-CP20.
           MOVE CPP020-NR-DOCTO       TO NR-DOCTO-CP20.
           MOVE CPP020-EMISSAO-INV    TO DATA-EMISSAO-CP20
           MOVE CPP020-VENCTO-INV     TO DATA-VENCTO-CP20
           MOVE CPP020-DESCRICAO      TO DESCRICAO-CP20
           IF CPP020-TIPO-MOEDA = SPACES MOVE "0" TO TIPO-MOEDA-CP20
           ELSE MOVE CPP020-TIPO-MOEDA(1: 1) TO TIPO-MOEDA-CP20.
           MOVE CPP020-COD-APURACAO   TO CODREDUZ-APUR-CP20
           MOVE CPP020-JUROS-MORA     TO JUROS-MORA-CP20
           MOVE CPP020-MULTA-ATRASO   TO MULTA-ATRASO-CP20
           IF CPP020-PREV-DEF = SPACES MOVE "0" TO PREV-DEF-CP20
           ELSE MOVE CPP020-PREV-DEF(1: 1) TO PREV-DEF-CP20.
           MOVE CPP020-TAXA           TO TAXA-APLIC-CP20
           MOVE CPP020-RESPONSAVEL    TO RESPONSAVEL-CP20
           MOVE ZEROS                 TO LIBERADO-CP20
           MOVE PARAMETROS-W(1: 5)    TO DIGITADOR-CP20.
           IF CPP020-TIPO-CONTA = SPACES
              MOVE "0" TO TIPO-CONTA-CP20
           ELSE
              MOVE CPP020-TIPO-CONTA(1: 1) TO TIPO-CONTA-CP20.
           MOVE 0101                  TO NR-PARCELA-CP20.
           MOVE CPP020-VALOR-TOTAL    TO VALOR-TOT-CP20.
      *    IF PORTADOR-CP20 = 12
      *       IF CPP020-BANCO-CH <> ZEROS AND
      *          CPP020-NR-CHEQUE-CH <> ZEROS
      *           MOVE CPP020-BANCO-CH      TO CODIGO-FORN-CB100
      *           MOVE CPP020-NR-CHEQUE-CH  TO NR-CHEQUE-CB100
      *           MOVE CPP020-NOMINAL-A-CH  TO NOMINAL-A-CB100
      *           MOVE CPP020-EMISSAO-CH    TO DATA-EMISSAO-CB100
      *           MOVE CPP020-VENCTO-CH     TO DATA-VENCTO-CB100
      *           MOVE CPP020-VALOR-CH      TO VALOR-CB100
      *           MOVE CPP020-SITUACAO-CH   TO SITUACAO-CB100.

       GRAVA-OBS SECTION.
           MOVE CPP020-COD-FORN    TO FORNEC-CP22
           MOVE SEQ-CP21           TO SEQ-CP22
           READ CPD022 INVALID KEY
                MOVE CPP020-OBSERVACAO  TO OBS-CP22
                WRITE REG-CPD022 INVALID KEY
                      MOVE "CPD022"  TO CPP020-MENSAGEM-ERRO(15: 07)
                      MOVE ST-CPD022 TO CPP020-MENSAGEM-ERRO(23: 02)
                      PERFORM ERRO-GRAVACAO
                NOT INVALID KEY
                      MOVE USUARIO-W   TO LOG3-USUARIO
                      MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                      MOVE WS-DATA-CPU TO LOG3-DATA
                      ACCEPT WS-HORA-SYS FROM TIME
                      MOVE WS-HORA-SYS TO LOG3-HORAS
                      MOVE "I"         TO LOG3-OPERACAO
                      MOVE "CPD022"    TO LOG3-ARQUIVO
                      MOVE "CPP020"    TO LOG3-PROGRAMA
                      MOVE REG-CPD022  TO LOG3-REGISTRO
                      WRITE REG-LOG003
                      END-WRITE
                END-WRITE
           NOT INVALID KEY
                MOVE CPP020-OBSERVACAO  TO OBS-CP22
                REWRITE REG-CPD022 INVALID KEY
                      MOVE "CPD022"  TO CPP020-MENSAGEM-ERRO(15: 07)
                      MOVE ST-CPD022 TO CPP020-MENSAGEM-ERRO(23: 02)
                      PERFORM ERRO-GRAVACAO
                NOT INVALID KEY
                      MOVE USUARIO-W   TO LOG3-USUARIO
                      MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                      MOVE WS-DATA-CPU TO LOG3-DATA
                      ACCEPT WS-HORA-SYS FROM TIME
                      MOVE WS-HORA-SYS TO LOG3-HORAS
                      MOVE "A"         TO LOG3-OPERACAO
                      MOVE "CPD022"    TO LOG3-ARQUIVO
                      MOVE "CPP020"    TO LOG3-PROGRAMA
                      MOVE REG-CPD022  TO LOG3-REGISTRO
                      WRITE REG-LOG003
                      END-WRITE.
      *ACHA-SEQ-CIE SECTION.
      *    MOVE DATA-MOVTO-I    TO DATA-CI10.
      *    MOVE ZEROS           TO SEQ-CI10 SEQ-CIE.
      *    PERFORM UNTIL ST-CIED010 = "10"
      *      READ CIED010 NEXT RECORD AT END MOVE "10" TO ST-CIED010
      *       NOT AT END
      *         IF DATA-CI10 NOT = DATA-MOVTO-I MOVE "10" TO ST-CIED010
      *            MOVE SEQ-CI10 TO SEQ-CIE
      *         ELSE CONTINUE
      *      END-READ
      *    END-PERFORM.
      *GRAVA-CIE SECTION.
      *    PERFORM ACHA-SEQ-CIE.
      *    MOVE 01                  TO COD-MENS-PADRAO-CI10
      *    MOVE SPACES              TO DESCRICAO-MENS-CI10.
      *    MOVE CPP020-DESCR-FORN   TO DESCRICAO-MENS-CI10(1: 10)
      *    MOVE DESCRICAO-CP20      TO DESCRICAO-MENS-CI10(12: 27)
      *    MOVE DATA-VENCTO-CP20 TO DATA-INV
      *    CALL "GRIDAT1" USING DATA-INV
      *    MOVE DATA-INV            TO DATA-E
      *    MOVE DATA-E              TO DESCRICAO-MENS-CI10(40: 11)
      *    MOVE VALOR-TOT-CP20      TO VALOR-E
      *    MOVE VALOR-E             TO DESCRICAO-MENS-CI10(51: 10)
      *    MOVE DATA-MOVTO-I        TO DATA-CI10
      *    ADD 1                    TO SEQ-CIE
      *    MOVE SEQ-CIE             TO SEQ-CI10
      *    ACCEPT HORA-W            FROM TIME.
      *    MOVE HORA-W(1: 4)        TO HORA-CI10
      *    MOVE USUARIO-W           TO ORIGEM-CI10
      **Fun��o que exerce o destinatario
      *    MOVE 1                   TO FUNCAO-DESTINO-CI10
      *    CODIGO DO USUARIO DESTINO (KELLO)
      *    MOVE ZEROS               TO ST-CIED010.
      *    PERFORM UNTIL ST-CIED010 = "10"
      *      WRITE REG-CIED010 INVALID KEY
      *             ADD 1 TO SEQ-CI10
      *         NOT INVALID KEY MOVE "10" TO ST-CIED010
      *    END-PERFORM.

       GRAVA-PARCELAS SECTION.
           MOVE ZEROS TO K.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 24
               IF CPP020-NR(I) = ZEROS MOVE 24 TO I
               ELSE
                  PERFORM SALVAR-DADOS

                  MOVE CPP020-NR(I)      TO NR-PARCELA-CP20
                  MOVE CPP020-QT-PARCELA TO TOT-PARC-CP20
                  MOVE CPP020-VENCTO(I)  TO DATA-INV DATA-VENCTO-CB100
                  CALL "GRIDAT2" USING DATA-INV
                  MOVE DATA-INV          TO DATA-VENCTO-CP20
                  MOVE CPP020-VALOR(I)   TO VALOR-TOT-CP20 VALOR-CB100

                  PERFORM GRAVA-DADOS

                  ADD 1 TO CPP020-NR-CHEQUE-CH
           END-PERFORM.
       GRAVA-CHEQUES SECTION.
           MOVE SEQ-CP20  TO SEQ-CTA-PAGAR-CB100.
           WRITE REG-CBD100 INVALID KEY
             REWRITE REG-CBD100 NOT INVALID KEY
                 MOVE USUARIO-W   TO LOG2-USUARIO
                 MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                 MOVE WS-DATA-CPU TO LOG2-DATA
                 ACCEPT WS-HORA-SYS FROM TIME
                 MOVE WS-HORA-SYS TO LOG2-HORAS
                 MOVE "A"         TO LOG2-OPERACAO
                 MOVE "CBD100"    TO LOG2-ARQUIVO
                 MOVE "CPP020"    TO LOG2-PROGRAMA
                 MOVE REG-CBD100  TO LOG2-REGISTRO
                 WRITE REG-LOG002
                 END-WRITE
             END-REWRITE
           NOT INVALID KEY
             MOVE USUARIO-W   TO LOG2-USUARIO
             MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
             MOVE WS-DATA-CPU TO LOG2-DATA
             ACCEPT WS-HORA-SYS FROM TIME
             MOVE WS-HORA-SYS TO LOG2-HORAS
             MOVE "I"         TO LOG2-OPERACAO
             MOVE "CBD100"    TO LOG2-ARQUIVO
             MOVE "CPP020"    TO LOG2-PROGRAMA
             MOVE REG-CBD100  TO LOG2-REGISTRO
             WRITE REG-LOG002
             END-WRITE
           END-WRITE.
       GRAVA-DADOS SECTION.
           MOVE ZEROS TO SITUACAO-CP20 LIBERADO-CP20 VALOR-LIQ-CP20
                         JURO-PAGO-CP20 MULTA-PAGA-CP20 DESCONTO-CP20
                         CONTABILIZADO-CP20 SEQ-CAIXA-CP20
                         DATA-PGTO-CP20 VALOR-LIQ-CP20.
           IF TIPO-CONTA-CP20 = 1 MOVE 0 TO PREV-DEF-CP20.
           MOVE CPP020-COD-FORN       TO FORNEC-CP21.
           PERFORM ATUALIZA-SEQ-CPD021.
           MOVE SEQ-CP21      TO SEQ-CP20.
           MOVE ZEROS TO ST-CPD020.

           PERFORM VALIDA-DATA-LIMITE

           WRITE REG-CPD020 INVALID KEY
                 MOVE "CPD020"  TO CPP020-MENSAGEM-ERRO(15: 07)
                 MOVE ST-CPD020 TO CPP020-MENSAGEM-ERRO(23: 02)
                 PERFORM ERRO-GRAVACAO
           NOT INVALID KEY
                 MOVE USUARIO-W   TO LOG3-USUARIO
                 MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
                 MOVE WS-DATA-CPU TO LOG3-DATA
                 ACCEPT WS-HORA-SYS FROM TIME
                 MOVE WS-HORA-SYS TO LOG3-HORAS
                 MOVE "I"         TO LOG3-OPERACAO
                 MOVE "CPD020"    TO LOG3-ARQUIVO
                 MOVE "CPP020"    TO LOG3-PROGRAMA
                 MOVE REG-CPD020  TO LOG3-REGISTRO
                 WRITE REG-LOG003
                 END-WRITE
           END-WRITE.
      *    IF PORTADOR-CP20 = 12
      *      IF CPP020-BANCO-CH <> ZEROS AND
      *         CPP020-NR-CHEQUE-CH <> ZEROS
      *         PERFORM GRAVA-CHEQUES.
           PERFORM GRAVA-DESMEMBRADO.
      *    PERFORM GRAVA-CIE.
           PERFORM MOVER-DADOS-LISTA.
           MOVE "INSERE-LIST" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
           IF TIPO-CONTA-CP20 = 1  PERFORM INCLUI-PERMANENTE.
           IF CPP020-GRAVA-OBS = 1 PERFORM GRAVA-OBS.
       REGRAVA-DADOS SECTION.
           PERFORM VALIDA-DATA-LIMITE

           REWRITE REG-CPD020 INVALID KEY
               move "REWRITE"   TO CPP020-MENSAGEM-ERRO(15:7)
               PERFORM ERRO-GRAVACAO
           NOT INVALID KEY
               MOVE USUARIO-W   TO LOG3-USUARIO
               MOVE FUNCTION CURRENT-DATE TO WS-DATA-SYS
               MOVE WS-DATA-CPU TO LOG3-DATA
               ACCEPT WS-HORA-SYS FROM TIME
               MOVE WS-HORA-SYS TO LOG3-HORAS
               MOVE "A"         TO LOG3-OPERACAO
               MOVE "CPD020"    TO LOG3-ARQUIVO
               MOVE "CPP020"    TO LOG3-PROGRAMA
               MOVE REG-CPD020  TO LOG3-REGISTRO
               WRITE REG-LOG003
               END-WRITE
               CONTINUE.

      *    IF PORTADOR-CP20 = 12
      *      IF CPP020-BANCO-CH <> ZEROS AND
      *         CPP020-NR-CHEQUE-CH <> ZEROS
      *         PERFORM GRAVA-CHEQUES.
           PERFORM GRAVA-DESMEMBRADO.
           PERFORM MOVER-DADOS-LISTA.
           MOVE "ATUALIZA-LISTA" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM.
           IF TIPO-CONTA-CP20 = 1
              MOVE SEQ-CP20 TO SEQ-ALTERADA
              PERFORM VERIFICA-12PERMANENTE

              IF CPP020-OP-ALTER-PERMANENT = 2
                 PERFORM ALTERA-PERMANENTE.
       VERIFICA-DOCTO-PERMANENTE SECTION.
           MOVE CPP020-COD-FORN   TO FORNEC-CP20 FORNEC-W
           MOVE CPP020-NR-DOCTO   TO DOCTO-W
           MOVE ZEROS             TO SEQ-CP20 CPP020-ERRO.
           START CPD020 KEY IS NOT < CHAVE-CP20 INVALID KEY
                MOVE "10" TO ST-CPD020.
           PERFORM UNTIL ST-CPD020 = "10"
              READ CPD020 NEXT RECORD AT END MOVE "10" TO ST-CPD020
                NOT AT END
                  IF FORNEC-CP20 NOT = FORNEC-W MOVE "10" TO ST-CPD020
                  ELSE
                   IF NR-DOCTO-CP20 NOT = DOCTO-W CONTINUE
                   ELSE
                     IF SITUACAO-CP20 NOT > 1
                        MOVE 1 TO CPP020-ERRO
                        MOVE "10" TO ST-CPD020
                     END-IF
                   END-IF
                  END-IF
              END-READ
           END-PERFORM.
      * Fun��o p/ verificar se existe o nr-docto no respectivo
      * fornecedor, porque p/ lan�amentos permanentes n�o pode existir
      * o mesmo nr-docto p/ fornecedor

       VERIFICA-PROGRAMACAO SECTION.
           MOVE CPP020-COD-FORN TO FORNECEDOR-PF10.
           MOVE ZEROS           TO DATA-MOV-PAGAR-PF10.
           START PFD010 KEY IS NOT < ALT1-PF10 INVALID KEY
                  MOVE "10" TO ST-PFD010.
           PERFORM UNTIL ST-PFD010 = "10"
             READ PFD010 NEXT RECORD AT END MOVE "10" TO ST-PFD010
               NOT AT END
                  IF DATA-MOV-PAGAR-PF10 NOT = ZEROS
                     MOVE "10" TO ST-PFD010
                  ELSE PERFORM EXIBE-PROGRAMACAO.
       VALIDA-DATA-LIMITE SECTION.
      *    VERIFICA SE DATA DE MOVTO OU VENCTO < 19950101
           IF DATA-MOVTO-CP20 < DATA-LIMITE
              MOVE "DATA-MOVTO-INV:"  TO CPP020-MENSAGEM-ERRO(15: 15)
              MOVE DATA-MOVTO-CP20 TO CPP020-MENSAGEM-ERRO(30: 08)
              PERFORM ERRO-GRAVACAO
           END-IF

           IF DATA-VENCTO-CP20 < DATA-LIMITE
              MOVE "DATA-VENCTO-INV:"  TO CPP020-MENSAGEM-ERRO(15: 15)
              MOVE DATA-VENCTO-CP20 TO CPP020-MENSAGEM-ERRO(30: 08)
              PERFORM ERRO-GRAVACAO
           END-IF.

       EXIBE-PROGRAMACAO SECTION.
           MOVE "TELA-PROGRAMACAO" TO DS-PROCEDURE.
           PERFORM CALL-DIALOG-SYSTEM.
           MOVE CPP020-COD-FORN TO FORNECEDOR-PF10.
           MOVE ZEROS           TO DATA-MOV-PAGAR-PF10.
           START PFD010 KEY IS NOT < ALT1-PF10 INVALID KEY
                  MOVE "10" TO ST-PFD010.
           PERFORM UNTIL ST-PFD010 = "10"
             READ PFD010 NEXT RECORD AT END MOVE "10" TO ST-PFD010
               NOT AT END
                  IF DATA-MOV-PAGAR-PF10 NOT = ZEROS
                     MOVE "10" TO ST-PFD010
                  ELSE
                    MOVE DESCRICAO-PF10    TO CPP020-LINDET2(1: 31)
                    MOVE COND-PGTO-PF10    TO CPP020-LINDET2(32: 21)
                    MOVE DATA-ENTREGA-PF10 TO DATA-INV
                    CALL "GRIDAT1" USING DATA-INV
                    MOVE DATA-INV          TO DATA-E
                    MOVE DATA-E            TO CPP020-LINDET2(53: 13)
                    MOVE VALOR-PF10        TO VALOR-E1
                    MOVE VALOR-E1          TO CPP020-LINDET2(68: 14)
                    IF APROVADO-POR-PF10 = ZEROS
                       MOVE "N�O" TO CPP020-LINDET2(82: 3)
                    ELSE MOVE "SIM" TO CPP020-LINDET2(80: 3)
                    END-IF
                    MOVE DATA-PROGR-PF10 TO CPP020-LINDET2(85: 8)
                    MOVE SEQ-PF10        TO CPP020-LINDET2(93: 3)
                    MOVE "INSERE-LIST2" TO DS-PROCEDURE
                    PERFORM CALL-DIALOG-SYSTEM
                  END-IF
             END-READ
           END-PERFORM.

       PROGRAMACAO-SELECIONADA SECTION.
           MOVE CPP020-LINDET2(85: 8) TO DATA-PROGR-PF10.
           MOVE CPP020-LINDET2(93: 3) TO SEQ-PF10.
           READ PFD010 INVALID KEY CONTINUE
            NOT INVALID KEY
               MOVE DESCRICAO-PF10      TO CPP020-DESCRICAO
               MOVE VALOR-PF10          TO CPP020-VALOR-TOTAL
               MOVE CONTA-APURAC-PF10   TO CPP020-COD-APURACAO
               MOVE APROVADO-POR-PF10   TO CODIGO-CA002
               READ CAD002 INVALID KEY MOVE SPACES TO NOME-CA002
               END-READ
               MOVE NOME-CA002          TO CPP020-RESPONSAVEL
           END-READ.

       ERRO-GRAVACAO SECTION.
           MOVE "ERRO GRAVA��O" TO CPP020-MENSAGEM-ERRO(1:14)
           PERFORM LOAD-SCREENSET
           PERFORM CARREGA-MENSAGEM-ERRO.
       CARREGA-ULTIMOS SECTION.
           MOVE "CLEAR-LIST-BOX" TO DS-PROCEDURE
           PERFORM CALL-DIALOG-SYSTEM
           MOVE CPP020-DATA-MOVTO TO DATA-INV DATA-MOVTO-W.
           CALL "GRIDAT2" USING DATA-INV.
           MOVE DATA-INV          TO DATA-MOVTO-CP20 DATA-MOVTO-I.
           START CPD020 KEY IS NOT < DATA-MOVTO-CP20
                    INVALID KEY MOVE "10" TO ST-CPD020.
           MOVE SPACES TO CPP020-LINDET.
           PERFORM UNTIL ST-CPD020 = "10"
              READ CPD020 NEXT RECORD AT END MOVE "10" TO ST-CPD020
              NOT AT END
                IF DATA-MOVTO-CP20 NOT = DATA-MOVTO-I
                                   MOVE "10" TO ST-CPD020
                ELSE
                 IF SITUACAO-CP20 = 3 OR SITUACAO-CP20 = 4
                       CONTINUE
                 ELSE PERFORM MOVER-DADOS-LISTA

                      MOVE "INSERE-LIST" TO DS-PROCEDURE
                      PERFORM CALL-DIALOG-SYSTEM
                 END-IF
                END-IF
              END-READ
           END-PERFORM.

           MOVE "SENHA50"     TO PROGRAMA-CA004
           MOVE COD-USUARIO-W TO COD-USUARIO-CA004
           READ CAD004 INVALID KEY
                DISABLE-OBJECT CB3
           NOT INVALID KEY
                ENABLE-OBJECT CB3.

       MOVER-DADOS-LISTA SECTION.
           MOVE SPACES TO CPP020-LINDET
           MOVE FORNEC-CP20        TO FORNEC-E CODIGO-CG01
           MOVE FORNEC-CP20        TO CPP020-LINDET(01: 07)
           MOVE SEQ-CP20           TO SEQ-E
           READ CGD001 INVALID KEY MOVE "************" TO NOME-CG01.
           MOVE SEQ-CP20           TO CPP020-LINDET(08: 06)
           MOVE NOME-CG01(1: 10)   TO CPP020-LINDET(14: 11)
           MOVE DESCRICAO-CP20     TO CPP020-LINDET(25: 31)
           MOVE TIPO-FORN-CP20     TO CPP020-LINDET(56: 04)
           MOVE PORTADOR-CP20      TO CPP020-LINDET(60: 05)
           MOVE SITUACAO-CP20      TO CPP020-LINDET(65: 02)
           MOVE CODREDUZ-APUR-CP20 TO CPP020-LINDET(67: 06)
           MOVE RESPONSAVEL-CP20   TO CPP020-LINDET(73: 06)
           MOVE DATA-VENCTO-CP20   TO DATA-INV
           CALL "GRIDAT1" USING DATA-INV
           MOVE DATA-INV           TO DATA-E
           MOVE DATA-E             TO CPP020-LINDET(79: 11)
           MOVE VALOR-TOT-CP20     TO VALOR-E
           MOVE VALOR-E            TO CPP020-LINDET(90: 10).

       CLEAR-FLAGS SECTION.
           INITIALIZE CPP020-FLAG-GROUP.

       SET-UP-FOR-REFRESH-SCREEN SECTION.
           MOVE "REFRESH-DATA" TO DS-PROCEDURE.

       LOAD-SCREENSET SECTION.
           MOVE DS-PUSH-SET TO DS-CONTROL
           MOVE "CPP020" TO DS-SET-NAME
           PERFORM CALL-DIALOG-SYSTEM.

       IMPRIME-RELATORIO SECTION.
           COPY CONDENSA.
           MOVE ZEROS TO PAG-W.
           MOVE DATA-MOVTO-I TO DATA-MOVTO-CP20.
           START CPD020 KEY IS = DATA-MOVTO-CP20 INVALID KEY
                 MOVE "10" TO ST-CPD020.
           MOVE ZEROS TO LIN. PERFORM CABECALHO.
           PERFORM UNTIL ST-CPD020 = "10"
             READ CPD020 NEXT RECORD AT END MOVE "10" TO ST-CPD020
              NOT AT END
                IF DATA-MOVTO-CP20 NOT = DATA-MOVTO-I
                                   MOVE "10" TO ST-CPD020
                ELSE
                MOVE FORNEC-CP20           TO FORNECEDOR-REL
                MOVE SEQ-CP20              TO SEQ-REL
                MOVE TIPO-FORN-CP20        TO TIPO-FORN-REL
                MOVE NR-DOCTO-CP20         TO DOCUMENTO-REL
                MOVE DESCRICAO-CP20        TO DESCRICAO-REL
                MOVE PORTADOR-CP20         TO PORTADOR-REL
                MOVE SITUACAO-CP20         TO SITUACAO-REL
                EVALUATE SITUACAO-CP20
                 WHEN 0 MOVE "0K"          TO DESC-SITUACAO-REL
                 WHEN 1 MOVE "SUSPEN"      TO DESC-SITUACAO-REL
                 WHEN 2 MOVE "PAGA"        TO DESC-SITUACAO-REL
                 WHEN 3 MOVE "ESTORN"      TO DESC-SITUACAO-REL
                 WHEN 4 MOVE "CANCEL"      TO DESC-SITUACAO-REL
                END-EVALUATE
                EVALUATE LIBERADO-CP20
                 WHEN 0 MOVE "NAO"         TO LIBERADO-REL
                 WHEN 1 MOVE "SIM"         TO LIBERADO-REL
                END-EVALUATE
                MOVE CODREDUZ-APUR-CP20    TO APURACAO-REL
                EVALUATE TIPO-MOEDA-CP20
                 WHEN 0 MOVE "REAL " TO MOEDA-REL
                 WHEN 1 MOVE "DOLAR" TO MOEDA-REL
                END-EVALUATE
                MOVE RESPONSAVEL-CP20      TO RESPONSAVEL-REL
                MOVE DIGITADOR-CP20        TO DIGITADOR-REL
                MOVE SEQ-CAIXA-CP20        TO SEQ-CAIXA-REL
                MOVE CONTABILIZADO-CP20    TO CONTABILIZADO-REL
                MOVE NR-PARCELA-CP20       TO PARCELA-REL
                MOVE DATA-EMISSAO-CP20 TO DATA-INV
                CALL "GRIDAT1" USING DATA-INV
                MOVE DATA-INV              TO DATA-EMISSAO-REL
                MOVE DATA-VENCTO-CP20      TO DATA-INV
                CALL "GRIDAT1" USING DATA-INV
                MOVE DATA-INV              TO VENCTO-REL
                MOVE TAXA-APLIC-CP20       TO TAXA-APLIC-REL
                MOVE MULTA-ATRASO-CP20     TO MULTA-ATRAS-REL
                MOVE JUROS-MORA-CP20       TO JUROS-MORA-REL
                MOVE VALOR-TOT-CP20        TO VALOR-TOTAL-REL
                EVALUATE PREV-DEF-CP20
                 WHEN 0 MOVE "D" TO PREV-DEF-REL
                 WHEN 1 MOVE "P" TO PREV-DEF-REL
                END-EVALUATE
                MOVE DATA-PGTO-CP20        TO DATA-INV
                CALL "GRIDAT1" USING DATA-INV
                MOVE DATA-INV              TO DATA-PAGTO-REL
                MOVE JURO-PAGO-CP20        TO VLR-JUROS-REL
                MOVE MULTA-PAGA-CP20       TO VLR-MULTA-REL
                MOVE DESCONTO-CP20         TO DESCONTO-REL
                MOVE VALOR-LIQ-CP20        TO VLR-LIQUIDO-REL
                MOVE TIPO-CONTA-CP20       TO TIPO-CONTA-REL

                WRITE REG-RELAT FROM LINDET
                WRITE REG-RELAT FROM LINDET1
                ADD 2 TO LIN
                IF LIN > 56 PERFORM CABECALHO
                END-IF
             END-READ
           END-PERFORM.

           COPY DESCONDENSA.
       CABECALHO SECTION.
           ADD 1 TO PAG-W.  MOVE PAG-W TO PAG-REL.
           IF PAG-W = 1
              WRITE REG-RELAT FROM CAB01
           ELSE WRITE REG-RELAT FROM CAB01 AFTER PAGE.
           WRITE REG-RELAT FROM CAB02 AFTER 2.
           WRITE REG-RELAT FROM CAB03.
           WRITE REG-RELAT FROM CAB04.
           WRITE REG-RELAT FROM CAB05.
           WRITE REG-RELAT FROM CAB03.
           MOVE 5 TO LIN.

       exibir-mensagem section.
           move    spaces to resp-msg.
           call    "MENSAGEM" using tipo-msg resp-msg mensagem
           cancel  "MENSAGEM".
           move spaces to mensagem.


       CALL-DIALOG-SYSTEM SECTION.
           CALL "DSRUN" USING DS-CONTROL-BLOCK, CPP020-DATA-BLOCK.
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
           move "CPP020"            to logacess-programa
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
           CLOSE CAD018 CAD019 CPD020 CPD021 CPD022 CGD001
                 CXD020 PFD010 CAD002 CPD023 LOG003 LOG001 LOG002
                 GED001 GED002 CAD004.
      *    CLOSE CIED001 CIED010.
           MOVE DS-QUIT-SET TO DS-CONTROL.
           PERFORM CALL-DIALOG-SYSTEM.
           EXIT PROGRAM.

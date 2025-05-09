       IDENTIFICATION DIVISION.
       PROGRAM-ID. GALHO45.
       AUTHOR. ALFREDO SAVIOLLI NETO.
       DATE-WRITTEN. 09-05-2005.
      *FUN��O: AR    M NOVO ARQUIVO mtd025

       ENVIRONMENT DIVISION.
       SPECIAL-NAMES.
         DECIMAL-POINT IS COMMA
         PRINTER IS LPRINTER.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           COPY CAPX001.

           COPY RCPX100.

           COPY RCPX101.


       DATA DIVISION.
       FILE SECTION.

           COPY CAPW001.

           COPY RCPW100.

           COPY RCPW101.

       WORKING-STORAGE SECTION.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  VARIAVEIS.
           05  ST-RCD100             PIC XX       VALUE SPACES.
           05  ST-RCD101             PIC XX       VALUE SPACES.
           05  ERRO-W                PIC 9        VALUE ZEROS.
      *    ERRO-W - flag que controla se houve erro de abertura arquivo
           05  HORA-W                PIC 9(8)     VALUE ZEROS.
           05  PAG-W                 PIC 9(2)     VALUE ZEROS.
           05  EMP-REFERENCIA.
               10  VAR1              PIC X VALUE "\".
               10  EMP-REC           PIC XXX.
               10  VAR2              PIC X VALUE "\".
               10  ARQ-REC           PIC X(7).
           05  EMPRESA-REF REDEFINES EMP-REFERENCIA PIC X(12).
           05  DATA-MOVTO-W          PIC 9(8)     VALUE ZEROS.
           05  DATA-MOVTO-I          PIC 9(8)     VALUE ZEROS.
           05  CLIENTE-E             PIC ZZZZ.ZZZZ VALUE ZEROS.
           05  SEQ-E                 PIC ZZZZZ    VALUE ZEROS.
           05  DATA-E                PIC 99/99/9999.

           05  CUSTO-PREVISTO-W      PIC 9(8)V99  VALUE ZEROS.
           05  INICIAL-PROCURADA     PIC X(6)     VALUE SPACES.
           05  INICIAL-A-COMPARAR    PIC X(6)     VALUE SPACES.
           05  LETRA                 PIC X        VALUE SPACES.
           05  LETRA1                PIC X        VALUE SPACES.
           05  SAIR-W                PIC 9        VALUE ZEROS.
      *    vari�veis p/ listar os nomes com iniciais solicitadas

           05  VALOR-E               PIC ZZZ.ZZZ,ZZ.
           05  VALOR-E1              PIC ZZ.ZZZ.ZZZ,ZZ.
           05  I                     PIC 99       VALUE ZEROS.
           05  L                     PIC 99       VALUE ZEROS.
           05  K                     PIC 99       VALUE ZEROS.
           05  J                     PIC 99       VALUE ZEROS.
           05  VLR-PARCELA           PIC 9(8)V99  VALUE ZEROS.
           05  DATA-DIA-I            PIC 9(8)     VALUE ZEROS.
           05  CLASSIF-W             PIC 9        VALUE ZEROS.
           05  COL1                  PIC 9(3)     VALUE ZEROS.
           05  ANOTACAO-W            PIC X(80)    VALUE SPACES.
           05  ULT-SEQ               PIC 9(3)     VALUE ZEROS.
           05  LIN                   PIC 9(02)    VALUE ZEROS.
           05  AUX-ALBUM             PIC 9(08)    VALUE ZEROS.

           COPY "PARAMETR".

       01  LINDET.
           05  LINDET-REL          PIC X(130)  VALUE SPACES.

       01  CAB04.
           05  FILLER              PIC X(130)  VALUE
           "CONTRATO    ITEM    CURSO    TURMA".


       PROCEDURE DIVISION.
       MAIN-PROCESS SECTION.
           MOVE ZEROS TO PAG-W ERRO-W.
           OPEN INPUT CONTROLE
           READ CONTROLE
           MOVE EMPRESA            TO EMP-REC
           MOVE "RCD100" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-RCD100
           MOVE "RCD101" TO ARQ-REC.  MOVE EMPRESA-REF TO PATH-RCD101
           OPEN I-O   RCD100
           OPEN INPUT RCD101

           CLOSE CONTROLE.
           IF ST-RCD100 = "35"
              CLOSE RCD100      OPEN OUTPUT RCD100
              CLOSE RCD100      OPEN I-O RCD100
           END-IF.

           display "Vou comecar a atualizar o RCD100" stop " ".
           display "Vou comecar a atualizar o RCD100" stop " ".

           IF ST-RCD100 <> "00" OR ST-RCD101 <> "00"
              CLOSE RCD100
                    RCD101
              stop run.

           INITIALIZE REG-RCD100

           START RCD100 KEY IS NOT LESS ALBUM-REC INVALID KEY
                 MOVE "10" TO ST-RCD100.


           PERFORM UNTIL ST-RCD100 = "10"
             READ RCD100 NEXT RECORD AT END
                  MOVE "10" TO ST-RCD100
             NOT AT END
                  INITIALIZE REG-RCD101
                  MOVE ZEROS     TO TOTAL-REC
                  MOVE ALBUM-REC TO ALBUM-REC1
                  START RCD101 KEY IS NOT LESS ALBUM-REC1 INVALID KEY
                       MOVE "10" TO ST-RCD101
                  END-START
                  PERFORM UNTIL ST-RCD101 = "10"
                       READ RCD101 NEXT AT END
                           MOVE "10" TO ST-RCD101
                       NOT AT END
                           IF ALBUM-REC1 <> ALBUM-REC
                               MOVE "10" TO ST-RCD101
                           ELSE
                               ADD VALOR-REC1 TO TOTAL-REC
                           END-IF
                       END-READ
                  END-PERFORM
                  display reg-rcd100
                  REWRITE REG-RCD100
              END-READ
           END-PERFORM.

           DISPLAY "ACABOU" STOP "  ".
           DISPLAY "ACABOU" STOP "  ".
           DISPLAY "ACABOU" STOP "  ".

           CLOSE RCD100
           CLOSE RCD101
           EXIT PROGRAM.

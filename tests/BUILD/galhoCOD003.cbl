       COPY DSLANG.CPY.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. GALHOCOD050.
      *AUTOR: ALFREDO SAVIOLLI NETO
      *DATA: 14-02-2011
      *DESCRI��O: Convers�o GALHOCOD060

       ENVIRONMENT DIVISION.
       SPECIAL-NAMES.
       DECIMAL-POINT IS COMMA.
       class-control.
           Utilitario         is class "utilitario"
           Window             is class "wclass".

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           COPY CAPX001.

           COPY COPX003.

           SELECT  COD003A ASSIGN TO PATH-COD003A
                   ORGANIZATION IS INDEXED
                   ACCESS MODE IS DYNAMIC
                   LOCK MODE IS MANUAL WITH LOCK ON RECORD
                   STATUS IS ST-COD003A
                   RECORD KEY IS CODIGO-CO03A
                   ALTERNATE RECORD KEY IS NOME-CO03A WITH DUPLICATES.

       DATA DIVISION.
       FILE SECTION.

           COPY CAPW001.

           COPY COPW003.

      *   Cadastro de eventos
       FD  COD003A.
       01  REG-COD003A.
           05  CODIGO-CO03A       PIC 999.
           05  NOME-CO03A         PIC X(20).
           05  EVENTO-PRE-CO03A   PIC 9.
           05  RELAT-ESTAT-CO03A  PIC 9.
      *    1-EVENTO  2-PRE-EVENTO
      *    RELAT-ESTAT-CO03 => 1 ENTRA, 2 N�O ENTRA

       WORKING-STORAGE SECTION.
           COPY "DS-CNTRL.MF".
           COPY "CBDATA.CPY".
       78  REFRESH-TEXT-AND-DATA-PROC VALUE 255.
       77  DISPLAY-ERROR-NO          PIC 9(4).
       01  VARIAVEIS.
           05  ST-CAD001             PIC XX       VALUE SPACES.
           05  ST-COD003             PIC XX       VALUE SPACES.
           05  ST-COD003A            PIC XX       VALUE SPACES.
           05  EMP-REFERENCIA.
               10  FILLER            PIC X(15)
                   VALUE "\PROGRAMA\KELLO".
               10  VAR1              PIC X VALUE "\".
               10  EMP-REC           PIC XXX.
               10  VAR2              PIC X VALUE "\".
               10  ARQ-REC           PIC X(10).
           05  EMPRESA-REF REDEFINES EMP-REFERENCIA PIC X(30).
           05  MENSAGEM              PIC X(200).
           05  FLAG-CRITICA          PIC 9(01) VALUE ZEROS.
           05  TIPO-MSG              PIC X(01).
           05  RESP-MSG              PIC X(01).
           05  STATUS-CODE           PIC X(02) COMP-5.
           05  ACP-CAMINHO1          PIC X(255) VALUE SPACES.
           05  ACP-CAMINHO2          PIC X(255) VALUE SPACES.
           05  ACP-DTINI             PIC 9(08)  VALUE ZEROS.
           05  ACP-DTFIM             PIC 9(08)  VALUE ZEROS.
           05  WS-OK                 PIC X(01)  VALUE SPACES.
           05  DATA-INI              PIC 9(08)  VALUE ZEROS.
           05  DATA-FIM              PIC 9(08)  VALUE ZEROS.
           05  RESP                  PIC X(01)  VALUE SPACES.
           05  ACHEI                 PIC X(01)  VALUE SPACES.
           05  QTDE-FORM             PIC 9(05)  VALUE ZEROS.
           05  MASC-VALOR            PIC ZZZ.ZZZ.ZZ9,99 VALUE ZEROS.
           05  AUX-PREVISTO          PIC 9(09)V99 VALUE ZEROS.
           05  AUX-VLRPAGO           PIC 9(09)V99 VALUE ZEROS.
           05  MASC1                 PIC ZZZ.ZZZ.ZZ9,99 VALUE ZEROS.
           05  MASC2                 PIC ZZZ.ZZZ.ZZ9,99 VALUE ZEROS.
           05  MASC3                 PIC ZZZ.ZZZ.ZZ9,99 VALUE ZEROS.
           05  MASC4                 PIC ZZZ.ZZZ.ZZ9,99 VALUE ZEROS.

       01 ws-data-sys.
          05 ws-data-cpu.
             10 ws-ano-cpu           pic 9(04).
             10 ws-mes-cpu           pic 9(02).
             10 ws-dia-cpu           pic 9(02).
          05 filler                  pic x(13).


       01 file-details.
          05 file-size               pic x(8) comp-x.
          05 file-date.
             10 dia                  pic x comp-x.
             10 month                pic x comp-x.
             10 year                 pic x(2) comp-x.
          05 file-time.
             10 hours                pic x comp-x.
             10 minutes              pic x comp-x.
             10 seconds              pic x comp-x.
             10 hundredths           pic x comp-x.

       PROCEDURE DIVISION.

       MAIN-PROCESS SECTION.
           display erase at 0101.

           open i-o   cad001
           close      cad001
           open input cad001

           if st-cad001 <> "00" and "05" and "35"
              move spaces to mensagem
              string "Erro de Abertura...CAD001" x"0da0"
                     "Status . . . " st-cad001 into mensagem
              move "C" to tipo-msg
              perform exibir-mensagem.


           initialize reg-cad001
           start cad001 key is not less codigo-ca001 invalid key
                 move "10" to st-cad001.

           perform until st-cad001 = "10"
                 read cad001 next at end
                      move "10" to st-cad001
                 not at end
                      DISPLAY "CODIGO-CA001 = " CODIGO-CA001 STOP " "

                      perform renomear-arquivos
                      perform abrir-arquivos
                      perform converter-arquivo
                      perform fechar-arquivos

                      display "ACABEI ESSA EMPRESA" STOP " "
                 end-read
           end-perform

           close cad001

           DISPLAY "ACABOU" STOP "  ".

           STOP " "

           stop run.

       renomear-arquivos section.
           MOVE CODIGO-CA001           TO EMP-REC
           MOVE "COD003"               TO ARQ-REC
           MOVE EMPRESA-REF            TO PATH-COD003A

           OPEN I-O COD003A
           CLOSE    COD003A

           MOVE CODIGO-CA001           TO EMP-REC
           MOVE "COD003"               TO ARQ-REC
           MOVE EMPRESA-REF            TO PATH-COD003

           MOVE CODIGO-CA001           TO EMP-REC
           MOVE "COD003W"              TO ARQ-REC
           MOVE EMPRESA-REF            TO PATH-COD003A

           call "CBL_RENAME_FILE" using PATH-COD003
                                        PATH-COD003A
                              returning status-code

           STRING PATH-COD003 ".idx" DELIMITED BY " " INTO PATH-COD003

           STRING PATH-COD003A ".idx" DELIMITED BY " " INTO PATH-COD003A

           call "CBL_RENAME_FILE" using PATH-COD003
                                        PATH-COD003A
                              returning status-code.
       renomear-arquivos-fim.
           exit.


       abrir-arquivos section.
           MOVE CODIGO-CA001           TO EMP-REC
           MOVE "COD003"               TO ARQ-REC
           MOVE EMPRESA-REF            TO PATH-COD003

           MOVE CODIGO-CA001           TO EMP-REC
           MOVE "COD003W"              TO ARQ-REC
           MOVE EMPRESA-REF            TO PATH-COD003A

           open i-o   cod003
           close      cod003
           open i-o   cod003

           open input cod003a.

       converter-arquivo section.

           INITIALIZE REG-COD003A
           START COD003A KEY IS NOT LESS CODIGO-CO03A INVALID KEY
                MOVE "10" TO ST-COD003A.

           PERFORM UNTIL ST-COD003A = "10"
                READ COD003A NEXT AT END
                     MOVE "10" TO ST-COD003A
                NOT AT END
                     DISPLAY "REG-COD003A = " REG-COD003A

                     MOVE CODIGO-CO03A        TO CODIGO-CO03
                     MOVE NOME-CO03A          TO NOME-CO03
                     MOVE EVENTO-PRE-CO03A    TO EVENTO-PRE-CO03
                     MOVE RELAT-ESTAT-CO03A   TO RELAT-ESTAT-CO03

                     WRITE REG-COD003 INVALID KEY
                           MOVE "Erro de Grava��o...COD003" TO MENSAGEM
                           MOVE "C" TO TIPO-MSG
                           PERFORM EXIBIR-MENSAGEM
                     END-WRITE

                END-READ
           END-PERFORM.

       fechar-arquivos section.
           close cod003 cod003a.

       EXIBIR-MENSAGEM SECTION.
           MOVE    SPACES TO RESP-MSG.
           CALL    "MENSAGEM" USING TIPO-MSG RESP-MSG MENSAGEM
           CANCEL  "MENSAGEM".
           move spaces to mensagem.

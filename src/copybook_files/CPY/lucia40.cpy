           SELECT COD040 ASSIGN TO PATH-COD040
                  ORGANIZATION IS INDEXED
                  ACCESS MODE IS DYNAMIC
                  STATUS IS ST-COD040
                  LOCK MODE IS MANUAL WITH LOCK ON RECORD
                  RECORD KEY IS NR-CONTRATO-CO40
                  ALTERNATE RECORD KEY IS ALT1-CO40 = MESANO-PREV-CO40
                            NR-CONTRATO-CO40
                  ALTERNATE RECORD KEY IS ALT2-CO40 = MESANO-PREV-CO40
                            CIDADE-CO40 WITH DUPLICATES
                  ALTERNATE RECORD KEY IS ALT3-CO40 = ORIGEM-CO40
                            NR-CONTRATO-CO40
                  ALTERNATE RECORD KEY IS ASSINATURA-CO40
                            WITH DUPLICATES.
       FD  COD040.
       01  REG-COD040.
           05  NR-CONTRATO-CO40         PIC 9(4).
           05  ORIGEM-CO40              PIC 9(2).
      *    ORIGEM =  1-KEL  2-MIK
           05  INSTITUICAO-CO40         PIC 9(5).
           05  IDENTIFICACAO-CO40       PIC X(20).
      *    identificacao- qdo for v�rios cursos- existe um nome p/
      *    identificar os mesmos
           05  QTDE-TURMAS-CO40         PIC 9(2).
           05  QTDE-FORM-INI-CO40       PIC 9(4).
           05  PADRAO-INI-CO40          PIC X.
      *    qtde-form-ini e padrao-ini: identificar a forma que foi
      *    aprovado o contrato - esses dados ser�o preenchidos no
      *    momento do cadastro n�o podendo haver manuten��o nos mesmos.
           05  QTDE-FORM-CO40           PIC 9(4).
           05  PADRAO-CO40              PIC X.
           05  MESANO-PREV-CO40         PIC 9(6).
      *    tipo mesano-prev = aaaa/mm.
           05  CAMPANHA-CO40            PIC 9(2).
           05  CIDADE-CO40              PIC 9(4).
           05  REPRESENTANTE-CO40       PIC 9(6).
           05  VLR-COMISSAO-CO40        PIC 9(8)V99 COMP-3.
           05  ASSINATURA-CO40          PIC 9(8)    COMP-3.
      *    assinatura- data-assinatura invertida (aaaa/mm/dd)
           05  STATUS-CO40              PIC 9(2).
           05  TIPO-FOTOG-CO40          PIC 9(2).
           05  MULTA-CONTRAT-CO40       PIC X(20).
           05  CIDADE-FORUM-CO40        PIC 9(4).
           05  COMERCIALIZACAO-CO40     PIC X(30).
           05  OBS-IMPORTANTE-CO40      PIC X(20).
           05  RESPONSAVEL-ATEND-CO40   PIC X(10).
           05  DATA-PREV-VENDA-CO40     PIC 9(8)   COMP-3.
      *   --- dados do contato ---------
           05  ORGANIZADOR-CO40         PIC X(15).
           05  FONE-ORGANIZ-CO40        PIC 9(8)   COMP-3.
           05  CONTATO-BECA-CO40        PIC X(30).
           05  CONTATO-CONVITE-CO40     PIC X(30).
           05  CONTATO-OUTRO-CO40       PIC X(30).
      * ------------------------------------------------
           05  COBERTURA-CO40           PIC 9(2).
      *    cobertura: 1-F/V/O  2-F/V  3-F/O  4-V/O  5-F  6-V  7-O
      *    F-Foto  V-V�deo  O-Oganiza��o de Evento

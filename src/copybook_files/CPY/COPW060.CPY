      *  CADASTRO DE EVENTOS
       FD  COD060.
       01  REG-COD060.
           05  NR-CONTRATO-CO60  PIC 9(04).
           05  ITEM-CO60         PIC 999.
           05  CODEVENTO-CO60    PIC 99999.
           05  DATA-SOLIC-CO60   PIC 9(08)  COMP-3.
           05  DATAREALIZA-CO60  PIC 9(08).
      *    DATAREALIZA-CO60 = AAAA/MM/DD.
           05  HORARIO-CO60      PIC X(10).
           05  LOCAL-CO60        PIC X(25).
           05  REFERENCIA-CO60   PIC X(30).
           05  ENDERECO-CO60     PIC X(40).
           05  PESSOA-CONTATO-CO60 PIC X(30).
           05  UNIFORME-CO60     PIC X(20).
      *    LOCAL, HORARIO, REFERENCIA, ENDERECO, PESSOA-CONTATO S�O
      *    INFORMACOES REFERENTES A LOCALIZACAO DO EVENTO
           05  COD-COMISSAO-CO60 PIC 9(4).
      *    COD-COMISSAO = NR-CONTRATO+COD-COMISSAO
           05  QT-PARTICIPANTE-CO60  PIC 9(4).
           05  QT-TELAO-CO60     PIC 9.
           05  FOTO-CO60         PIC 9.
           05  VIDEO-CO60        PIC 9.
           05  BECA-CO60         PIC 9.
           05  CLIP-CO60         PIC 9.
           05  FAX-CO60          PIC 9.
           05  APROVACAO-CO60    PIC 9.
           05  ORGANIZADOR-CO60  PIC X(15).
      *    05  OBSERVACAO-CO60   PIC X(80).
           05  OBSERVACAO-CO60   PIC X(76).
           05  CIDADE-CO60       PIC 9(04).
           05  NR-REL-REPOR-CO60 PIC 9(6)   COMP-3.
           05  NR-PLANEJ-CO60    PIC 9(8)   COMP-3.
           05  DATA-CANCELAM-CO60 PIC 9(8)  COMP-3.
           05  HORA-CANCELAM-CO60 PIC X(5).
           05  DT-PREV-REAL-CO60  PIC 9(1).
      *    DATA-CANCELAM E HORAS-CANCELAM - DADOS P/ O CANCELAMETO DO
      *    EVENTO
      *    DT-PREV-REAL-CO60 -> 1 DATA-PREVISTA, 2 DATA-REALIZADA, 3


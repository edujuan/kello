      * Cadatro de contrato de Organiza��o de Evento
       FD  OED010.
       01  REG-OED010.
           05  NR-CONTRATO-OE10         PIC 9(4).
           05  TOTAL-ALUNO-OE10         PIC 9(4).
           05  REPRESENTANTE-OE10       PIC 9(6).
           05  ASSINATURA-OE10          PIC 9(8)    COMP-3.
      *    assinatura- data-assinatura invertida (aaaa/mm/dd)
           05  DATA-ULT-EVENTO-OE10     PIC 9(8).
      *    DATA-ULTIMO-EVENTO - INVERTIDA (AAAA/MM/DD)
           05  ALUNO-PRES-OE10          PIC 9(4).
           05  ALUNO-TESOU-OE10         PIC 9(4).
           05  VLR-TOTAL-OE10           PIC 9(8)V99.
           05  QTDE-PARCELA-OE10        PIC 9(3).
           05  TIPO-RECTO-OE10          PIC 9.
      *    1-'parcelamento individual' de cada aluno
      *    2-'direto da comiss�o' - o cliente neste caso dever� ter o
      *       c�digo - ????-0000 (onde ???? ser� o nr do contrato).
           05  CONDICAO-RECTO-OE10      PIC X(30).
      *    campo descritivo que ser� do tipo - cobran�a banc�ria,
      *    dep�sito no vencto, cheque pr�-datado, etc...
           05  CONDICAO-REAJUSTE-OE10   PIC X(30).
      *    ex. gatilho de 7% de infla��o
           05  TAXA-JURO-ATRASO-OE10    PIC 9(2)V99.
           05  MULTA-ATRASO-OE10        PIC X(20).
           05  MULTA-RESCISAO-OE10      PIC X(20).

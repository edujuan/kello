      * cadastro de usu�rios que poder�o ter acesso aos relat�rios de
      * contas correntes conforme tipo de acesso
       FD  CCD001.
       01  REG-CCD001.
           05  NOME-REDUZ-CC01     PIC X(5).
           05  TIPO-ACESSO-CC01    PIC 9(3).
      * TIPO-ACESSO � FIXO COM: 01 - Pessoa F�sica
      *                         02 - Pessoa Jur�dica
      *                         03 - Funcion�rio
      *                         04 - Representante
      *                         05 - Fot�grafo
      *                         06 - Cinegrafista
      *                         07 - Vendedor
      *                         08 - Imposto
      *                         09 - Investidor
      *                         00 - Outros
      *                         10 - Terceirizado
      *                         11 - Franquia


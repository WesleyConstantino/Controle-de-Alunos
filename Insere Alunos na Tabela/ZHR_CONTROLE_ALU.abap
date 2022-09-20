REPORT ZHR_CONTROLE_ALU.

DATA: wa_001 type zhr001_alunos.


*PARAMETER cria a interface do usuario (com campos para ele preencher)
*APÓS O NOME DA TABELA ZHR001_WY, COLOCO UM TRAÇO "-" E EM SEGUIDA USO O ATALHO DE TECLADO "Ctrl + Barra de espaço" PARA VER AS OPÇOES DE LINHAS EXIXTENTES NA TABELA DO BD
PARAMETERS: p_mat TYPE zhr001_alunos-zz_matricula,
            p_nome TYPE zhr001_alunos-zz_nome,
            p_stt  TYPE zhr001_alunos-zz_status.

"executa daqui em diante quando o usuario aperta enter
START-OF-SELECTION.
PERFORM f_insert.

"form executa um bloco de comandos sem dar um retorno
*nesse caso insere passa os valores armazenados em wa_001-zz_re para o campo p_RE da tabela do banco de dados, no primeiro caso a baixo
*No exemplo de wa_001-zz_re = p_RE, seguimos a regra <Nome da variável que armazena os dados> < - traco para separ >  < Linha da tabela do BD >  < Variável dentro da outra variável que armazena um valor especiifico >
FORM f_insert.
wa_001-zz_matricula = p_mat.
wa_001-zz_nome = p_nome.
wa_001-zz_status =  p_stt.


*Insere tudo que está dentro de wa_001 para a tabela do banco de dados zhr001_38
INSERT zhr001_alunos FROM wa_001.

*se for igual a 0
*IS INITIAL é a mesma coisa que == 0
*SY-subrc é uma espécie de biblioteca que retorna 0 para operacoes bem sucedidas e qualquer outro valor para operacoes que falham
IF SY-subrc IS INITIAL.
*COMMIT WORK dá commit no banco dedos e AND WAIT pede para esperar
 COMMIT WORK AND WAIT.
*mensagem de sucesso
 MESSAGE S208(00) WITH 'SALVO COM SUCESSO!'.
ELSE.
 ROLLBACK WORK.
*mensagem de erro
 MESSAGE S208(00) WITH 'ERRO AO GRAVAR!'DISPLAY LIKE 'E'.
ENDIF.

ENDFORM.

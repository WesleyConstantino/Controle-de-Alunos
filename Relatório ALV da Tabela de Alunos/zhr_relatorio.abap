REPORT zhr_relatorio.


DATA:   v_mat       TYPE zhr001_alunos-zz_matricula,
        v_nome     TYPE zhr001_alunos-zz_nome,
        v_stt       TYPE zhr001_alunos-zz_status,


*Boas práricas usar t_out e wa_out pois, se mudarmos o nome da tabela zhr001_alunos em t_out, não precisaremos alterar mais trechos de código no programa
        t_out       TYPE TABLE OF zhr001_alunos, "TABELA INTERNA (matriz) para jogar os dados do BD e manipulá-los de forma indireta
        wa_out      LIKE LINE OF t_out,  "ESTRUTURA / WORK AREA (linha) é uma linha de t_out
*ALV
        t_fieldcat  TYPE  slis_t_fieldcat_alv,
        wa_fieldcat LIKE LINE OF t_fieldcat,
        wa_layout   TYPE  slis_layout_alv.

*DATA: r_re     TYPE RANGE OF v_re.

"001 é o código que demos ao título que escrevemos em "Ir para" -> "Elementos de texto" -> "Símbolos de texto"
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE text-001.
*SELECT-OPTIONS cria labels "DE" e "ATÉ" no front-end; são dois compos numa mesma linha
SELECT-OPTIONS: s_mat     FOR v_mat,
                s_nome   FOR v_nome,
                s_stt     FOR v_stt.
SELECTION-SCREEN END OF BLOCK b0.

START-OF-SELECTION.

  PERFORM f_buscar_dados. "Busca os dados da tabela transparente e popula na tabela interna t_out.
  PERFORM f_exibir_alv. "Exibe o report



FORM f_buscar_dados.
  REFRESH: t_out[]. "Limpa uma tabela; é a mesma coisa de "CLEAR: t_out[]" ou "FREE: t_out[]"

  SELECT   "SELECT seleciona os campos "x" de uma tabela do BD
          zz_matricula
          zz_nome
          zz_status

    INTO TABLE t_out  "INTO TABLE joga os campos do BD acima dentro da tabela interna TABLE t_out
    FROM zhr001_alunos  "É necessário também declarar de onde virão os campos que t_out receberá
    WHERE zz_matricula  IN s_mat "Jogamos os conjuntos de dados dos campos da tabela transparente do BD "zhr001_alunos" "IN" dentro da tabebela interna "t_out" (populando a nossa tabela local)
      AND zz_nome       IN s_nome
      AND zz_status     IN s_stt.

  IF t_out[] IS INITIAL. "Verificar se a tabela está vazia
    MESSAGE e208(00) WITH 'NENHUM REGISTRO ENCONTRADO!'.
  ENDIF.

  DELETE t_out WHERE zz_nome IS INITIAL. "Deleta todos os campos do  t_out onde o zz_nome está vazio


ENDFORM.



FORM f_exibir_alv.

  DATA: lv_tabix TYPE sy-tabix.



  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'zhr001_alunos' "nome da tabela transparente
      i_client_never_display = abap_true
    CHANGING
      ct_fieldcat            = t_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2.


  FIELD-SYMBOLS: <lfs_line>  TYPE slis_fieldcat_alv.


  LOOP AT t_fieldcat ASSIGNING <lfs_line>.
    CASE <lfs_line>-fieldname.
      WHEN 'ZZ_RE'.
        <lfs_line>-hotspot = abap_true.

      WHEN 'ZZ_DATA_CAD'.
        <lfs_line>-no_out = abap_true.

      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.


  wa_layout-colwidth_optimize = abap_true.
  wa_layout-zebra             = abap_true.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout     = wa_layout
      it_fieldcat   = t_fieldcat
    TABLES
      t_outtab      = t_out
    EXCEPTIONS
      program_error = 1.

  IF sy-subrc IS NOT INITIAL.
    "TRATAMENTO DO ERRO
    MESSAGE e208(00) WITH 'ERRO GERAR O ALV!'.
  ENDIF.


ENDFORM.

FORM f_cria_fcat USING VALUE(p_col_pos)
                       VALUE(p_fieldname)
                       VALUE(p_tabname)
                       VALUE(p_ref_tabname)
                       VALUE(p_ref_fieldname)
                       VALUE(p_seltext_m)
                       VALUE(p_key)
                       VALUE(p_hotspot).

  CLEAR: wa_fieldcat.
  wa_fieldcat-col_pos       = p_col_pos.
  wa_fieldcat-fieldname     = p_fieldname.
  wa_fieldcat-tabname       = p_tabname.
  wa_fieldcat-ref_tabname   = p_ref_tabname.
  wa_fieldcat-ref_fieldname = p_ref_fieldname.
  wa_fieldcat-seltext_m     = p_seltext_m.
  wa_fieldcat-key           = p_key.
  wa_fieldcat-hotspot       = p_hotspot.
  APPEND wa_fieldcat TO t_fieldcat.

ENDFORM.

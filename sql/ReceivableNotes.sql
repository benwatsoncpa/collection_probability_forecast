"SELECT arrm_receivable.receivable_id,
       arrm_receivable_status_type.active_clctn_status_ind,
	   arrm_note.created_datetime,
       arrm_program_based_receivable.original_advance_incurred_date,
       'nonfinancial' balance,
       1              amount,
       'note'         type,
       cascom_code.name_eng
FROM   ((arrm_receivable
         INNER JOIN arrm_receivable_status_type
                 ON arrm_receivable.receivable_status_type_code =
arrm_receivable_status_type.receivable_status_type_code)
INNER JOIN arrm_program_based_receivable
ON arrm_receivable.receivable_id =
arrm_program_based_receivable.receivable_id)
INNER JOIN (arrm_note
INNER JOIN cascom_code
       ON arrm_note.note_type_code =
          cascom_code.code_code)
ON arrm_receivable.receivable_id = arrm_note.receivable_id
WHERE  ( ( ( cascom_code.code_type_code ) = 2 )
         AND ( ( arrm_receivable.logical_delete_datetime ) IS NULL )
         AND ( ( arrm_receivable_status_type.logical_delete_datetime ) IS
               NULL )
         AND ( ( arrm_note.logical_delete_datetime ) IS NULL )
         AND ( ( cascom_code.logical_delete_datetime ) IS NULL ) )
UNION ALL
SELECT arrm_receivable.receivable_id,
       arrm_receivable_status_type.active_clctn_status_ind,
	   arrm_note.created_datetime,
       arrm_program_based_receivable.original_advance_incurred_date,
       'nonfinancial' balance,
       1              amount,
       'note'         type,
       cascom_code.name_eng
FROM   ((((arrm_note
           INNER JOIN arrm_debtor_account
                   ON arrm_note.debtor_account_id =
                      arrm_debtor_account.debtor_account_id)
          INNER JOIN arrm_receivable
                  ON arrm_debtor_account.debtor_account_id =
                     arrm_receivable.debtor_account_id)
         INNER JOIN arrm_receivable_status_type
                 ON arrm_receivable.receivable_status_type_code =
arrm_receivable_status_type.receivable_status_type_code)
INNER JOIN arrm_program_based_receivable
ON arrm_receivable.receivable_id =
arrm_program_based_receivable.receivable_id)
INNER JOIN cascom_code
ON arrm_note.note_type_code = cascom_code.code_code
WHERE  ( ( ( cascom_code.code_type_code ) = 2 )
         AND ( ( arrm_receivable.logical_delete_datetime ) IS NULL )
         AND ( ( arrm_receivable_status_type.logical_delete_datetime ) IS
               NULL )
         AND ( ( arrm_debtor_account.logical_delete_datetime ) IS NULL )
         AND ( ( arrm_note.logical_delete_datetime ) IS NULL )
         AND ( ( cascom_code.logical_delete_datetime ) IS NULL ) );" 
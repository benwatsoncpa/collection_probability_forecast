"SELECT arrm_receivable.receivable_id,
       arrm_receivable_status_type.active_clctn_status_ind,
	   arrm_receivable.welcome_letter_sent_date,
       arrm_program_based_receivable.original_advance_incurred_date,
       'nonfinancial'  AS balance,
       1               AS amount,
       'welcomeletter' AS transtype,
       'welcomeletter' AS transsubtype
FROM   (arrm_receivable
        INNER JOIN arrm_receivable_status_type
                ON arrm_receivable.receivable_status_type_code =
                   arrm_receivable_status_type.receivable_status_type_code)
       INNER JOIN arrm_program_based_receivable
               ON arrm_receivable.receivable_id =
                  arrm_program_based_receivable.receivable_id
WHERE  ( ( ( arrm_receivable_status_type.logical_delete_datetime ) IS NULL
         )
         AND ( ( arrm_receivable.logical_delete_datetime) IS NULL));"
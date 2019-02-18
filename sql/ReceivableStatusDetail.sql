"SELECT arrm_receivable.receivable_id,
       arrm_receivable.status_effective_datetime,
	   arrm_receivable_status_type.active_clctn_status_ind,
	   arrm_receivable_status_type.name_eng status
FROM   (arrm_program_based_receivable
        INNER JOIN arrm_receivable
                ON arrm_program_based_receivable.receivable_id =
                   arrm_receivable.receivable_id)
       INNER JOIN arrm_receivable_status_type
               ON arrm_receivable.receivable_status_type_code =
                  arrm_receivable_status_type.receivable_status_type_code
WHERE  (( ( arrm_receivable.logical_delete_datetime ) IS NULL ));"
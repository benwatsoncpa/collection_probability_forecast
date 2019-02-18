"SELECT arrm_receivable.receivable_id,
       arrm_receivable_status_type.active_clctn_status_ind,
	   arrm_document.attached_datetime,
       arrm_program_based_receivable.original_advance_incurred_date,
       'nonfinancial'                balance,
       1                             amount,
       'document'                    TYPE,
       cascom_document_type.name_eng SUBTYPE
FROM   (arrm_program_based_receivable
        inner join (((arrm_document
                      inner join arrm_debtor_account
                              ON arrm_document.debtor_account_id =
                                 arrm_debtor_account.debtor_account_id)
                     inner join arrm_receivable
                             ON arrm_debtor_account.debtor_account_id =
                                arrm_receivable.debtor_account_id)
                    inner join arrm_receivable_status_type
                            ON arrm_receivable.receivable_status_type_code =
arrm_receivable_status_type.receivable_status_type_code)
ON arrm_program_based_receivable.receivable_id =
arrm_receivable.receivable_id)
inner join cascom_document_type
ON arrm_document.document_type_code =
cascom_document_type.document_type_code
WHERE  (( ( arrm_receivable.logical_delete_datetime ) IS NULL ))
UNION ALL
SELECT arrm_receivable.receivable_id,
       arrm_receivable_status_type.active_clctn_status_ind,
	   arrm_document.attached_datetime,
       arrm_program_based_receivable.original_advance_incurred_date,
       'nonfinancial'                balance,
       1                             amount,
       'document'                    TYPE,
       cascom_document_type.name_eng SUBTYPE
FROM   (arrm_document
        inner join cascom_document_type
                ON arrm_document.document_type_code =
                   cascom_document_type.document_type_code)
       inner join (arrm_program_based_receivable
                   inner join (arrm_receivable
                               inner join arrm_receivable_status_type
                                       ON
                               arrm_receivable.receivable_status_type_code =
       arrm_receivable_status_type.receivable_status_type_code)
       ON arrm_program_based_receivable.receivable_id =
       arrm_receivable.receivable_id)
               ON arrm_document.receivable_id = arrm_receivable.receivable_id
WHERE  (( ( arrm_receivable.logical_delete_datetime ) IS NULL ));" 
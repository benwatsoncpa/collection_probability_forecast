"SELECT arrm_program_based_receivable.receivable_id,
       arrm_receivable_status_type.active_clctn_status_ind,
       arrm_case.created_datetime,
       arrm_program_based_receivable.original_advance_incurred_date,
       'nonfinancial' balance,
       1              amount,
       'case'         TYPE,
       cascom_code.name_eng
FROM   ((arrm_receivable
         inner join ((arrm_case
                      inner join arrm_case_receivable
                              ON arrm_case.case_id =
                                 arrm_case_receivable.case_id)
                     inner join arrm_program_based_receivable
                             ON arrm_case_receivable.receivable_id =
                                arrm_program_based_receivable.receivable_id)
                 ON arrm_receivable.receivable_id =
                    arrm_program_based_receivable.receivable_id)
        inner join arrm_receivable_status_type
                ON arrm_receivable.receivable_status_type_code =
                   arrm_receivable_status_type.receivable_status_type_code)
       inner join cascom_code
               ON arrm_case.case_type_code = cascom_code.code_code
WHERE  ( cascom_code.code_type_code ) = 19
       AND arrm_case_receivable.logical_delete_datetime IS NULL
       AND arrm_receivable.logical_delete_datetime IS NULL
       AND arrm_receivable_status_type.logical_delete_datetime IS NULL
       AND arrm_case.logical_delete_datetime IS NULL
       AND cascom_code.logical_delete_datetime IS NULL
GROUP  BY arrm_program_based_receivable.receivable_id,
          arrm_receivable_status_type.active_clctn_status_ind,
          arrm_receivable.limitation_period_end_date,
          arrm_case.created_datetime,
          arrm_program_based_receivable.original_advance_incurred_date,
          cascom_code.name_eng; "
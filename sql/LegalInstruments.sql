"SELECT arrm_receivable.receivable_id, 
       arrm_receivable_status_type.active_clctn_status_ind, 
	   arrm_legal_instrmnt.issue_date, 
       arrm_program_based_receivable.original_advance_incurred_date, 
       'nonfinancial'                 balance, 
       1                              amount, 
       'legalinstrument'              transtype, 
       legal_instrument_type.name_eng transsubtype 
FROM   ((((arrm_legal_instrmnt 
           INNER JOIN arrm_receivable_legal_instrmnt 
                   ON arrm_legal_instrmnt.legal_instrmnt_id = 
                      arrm_receivable_legal_instrmnt.legal_instrmnt_id) 
          INNER JOIN arrm_program_based_receivable 
                  ON arrm_receivable_legal_instrmnt.receivable_id = 
                     arrm_program_based_receivable.receivable_id) 
         INNER JOIN arrm_receivable 
                 ON arrm_program_based_receivable.receivable_id = 
                    arrm_receivable.receivable_id) 
        INNER JOIN arrm_receivable_status_type 
                ON arrm_receivable.receivable_status_type_code = 
                   arrm_receivable_status_type.receivable_status_type_code) 
       INNER JOIN (SELECT cascom_code.code_code, 
                          cascom_code.name_eng 
                   FROM   cascom_code 
                   WHERE  (( ( cascom_code.code_type_code ) = 16 ))) 
              legal_instrument_type 
               ON arrm_legal_instrmnt.legal_instrmnt_type_code = 
                  legal_instrument_type.code_code;" 
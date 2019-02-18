"SELECT arrm_receivable.receivable_id,
       arrm_receivable_status_type.active_clctn_status_ind,
	   arrm_repayment_plan_rcvbl.created_datetime,
       arrm_program_based_receivable.original_advance_incurred_date,
       'nonfinancial'  balance,
       1               amount,
       'repaymentplan' type,
       'repaymentplan' subtype
FROM   (((arrm_repayment_plan
          INNER JOIN arrm_repayment_plan_rcvbl
                  ON arrm_repayment_plan.repayment_plan_id =
                     arrm_repayment_plan_rcvbl.repayment_plan_id)
         INNER JOIN arrm_receivable
                 ON arrm_repayment_plan_rcvbl.receivable_id =
                    arrm_receivable.receivable_id)
        INNER JOIN arrm_receivable_status_type
                ON arrm_receivable.receivable_status_type_code =
                   arrm_receivable_status_type.receivable_status_type_code)
       INNER JOIN arrm_program_based_receivable
               ON arrm_repayment_plan_rcvbl.receivable_id =
                  arrm_program_based_receivable.receivable_id;" 
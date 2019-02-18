"SELECT arrm_receivable.RECEIVABLE_ID,
  arrm_receivable_status_type.ACTIVE_CLCTN_STATUS_IND,
  arrm_receivable_trnsctn.APPLIED_TO_BALANCE_DATETIME,
  arrm_program_based_receivable.ORIGINAL_ADVANCE_INCURRED_DATE,
  cascom_code.NAME_ENG balance,
  arrm_receivable_trnsctn.TRNSCTN_AMOUNT,
  cascom_CODE_1.NAME_ENG transaction_type,
  arrm_trnsctn_source_type.NAME_ENG transaction_subtype
FROM ((((((arrm_receivable_trnsctn
INNER JOIN arrm_receivable
ON arrm_receivable_trnsctn.RECEIVABLE_ID = arrm_receivable.RECEIVABLE_ID)
INNER JOIN arrm_receivable_status_type
ON arrm_receivable.RECEIVABLE_STATUS_TYPE_CODE = arrm_receivable_status_type.RECEIVABLE_STATUS_TYPE_CODE)
INNER JOIN arrm_program_based_receivable
ON arrm_receivable_trnsctn.RECEIVABLE_ID = arrm_program_based_receivable.RECEIVABLE_ID)
INNER JOIN cascom_code
ON arrm_receivable_trnsctn.BALANCE_TYPE_CODE = cascom_code.CODE_CODE)
INNER JOIN arrm_debtor_account_trnsctn
ON arrm_receivable_trnsctn.DEBTOR_ACCOUNT_TRNSCTN_ID = arrm_debtor_account_trnsctn.DEBTOR_ACCOUNT_TRNSCTN_ID)
INNER JOIN arrm_trnsctn_source_type
ON arrm_debtor_account_trnsctn.TRNSCTN_SOURCE_TYPE_CODE = arrm_trnsctn_source_type.TRNSCTN_SOURCE_TYPE_CODE)
INNER JOIN cascom_code cascom_CODE_1
ON arrm_trnsctn_source_type.TRNSCTN_TYPE_CODE            = cascom_CODE_1.CODE_CODE
WHERE (cascom_code.CODE_TYPE_CODE)                       = 13
AND (cascom_CODE_1.CODE_TYPE_CODE)                       = 14
AND arrm_receivable_status_type.LOGICAL_DELETE_DATETIME IS NULL
AND arrm_receivable.LOGICAL_DELETE_DATETIME             IS NULL
AND arrm_debtor_account_trnsctn.LOGICAL_DELETE_DATETIME IS NULL
AND arrm_receivable_trnsctn.LOGICAL_DELETE_DATETIME     IS NULL
AND cascom_code.LOGICAL_DELETE_DATETIME                 IS NULL
AND cascom_CODE_1.LOGICAL_DELETE_DATETIME               IS NULL
AND arrm_trnsctn_source_type.LOGICAL_DELETE_DATETIME    IS NULL;" 
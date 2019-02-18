"SELECT arrm_receivable.RECEIVABLE_ID,
  arrm_receivable_status_type.ACTIVE_CLCTN_STATUS_IND,
  arrm_program_based_receivable.TRNSFRD_IN_DATE,
  arrm_program_based_receivable.ORIGINAL_ADVANCE_INCURRED_DATE,
  'Principal' balance,
  arrm_program_based_receivable.TRNSFRD_IN_PRINCIPLE_AMOUNT,
  'Default' transactiontype,
  'none' transactionsubtype
FROM (arrm_receivable
INNER JOIN arrm_receivable_status_type
ON arrm_receivable.RECEIVABLE_STATUS_TYPE_CODE = arrm_receivable_status_type.RECEIVABLE_STATUS_TYPE_CODE)
INNER JOIN arrm_program_based_receivable
ON arrm_receivable.RECEIVABLE_ID               = arrm_program_based_receivable.RECEIVABLE_ID
WHERE arrm_receivable.LOGICAL_DELETE_DATETIME           IS NULL
AND arrm_receivable_status_type.LOGICAL_DELETE_DATETIME IS NULL
UNION ALL
SELECT arrm_receivable.RECEIVABLE_ID,
  arrm_receivable_status_type.ACTIVE_CLCTN_STATUS_IND,
  arrm_program_based_receivable.TRNSFRD_IN_DATE,
  arrm_program_based_receivable.ORIGINAL_ADVANCE_INCURRED_DATE,
  'Interest' balance,
  arrm_program_based_receivable.TRNSFRD_IN_INTEREST_AMOUNT,
  'Default' transactiontype,
  'none' transactionsubtype
FROM (arrm_receivable
INNER JOIN arrm_receivable_status_type
ON arrm_receivable.RECEIVABLE_STATUS_TYPE_CODE = arrm_receivable_status_type.RECEIVABLE_STATUS_TYPE_CODE)
INNER JOIN arrm_program_based_receivable
ON arrm_receivable.RECEIVABLE_ID               = arrm_program_based_receivable.RECEIVABLE_ID
WHERE arrm_receivable.LOGICAL_DELETE_DATETIME           IS NULL
AND arrm_receivable_status_type.LOGICAL_DELETE_DATETIME IS NULL
UNION ALL
SELECT arrm_receivable.RECEIVABLE_ID,
  arrm_receivable_status_type.ACTIVE_CLCTN_STATUS_IND,
  arrm_program_based_receivable.TRNSFRD_IN_DATE,
  arrm_program_based_receivable.ORIGINAL_ADVANCE_INCURRED_DATE,
  'Admin' balance,
  arrm_program_based_receivable.TRNSFRD_IN_ADMIN_CHARGE_AMOUNT,
  'Default' transactiontype,
  'none' transactionsubtype
FROM (arrm_receivable
INNER JOIN arrm_receivable_status_type
ON arrm_receivable.RECEIVABLE_STATUS_TYPE_CODE = arrm_receivable_status_type.RECEIVABLE_STATUS_TYPE_CODE)
INNER JOIN arrm_program_based_receivable
ON arrm_receivable.RECEIVABLE_ID               = arrm_program_based_receivable.RECEIVABLE_ID
WHERE arrm_receivable.LOGICAL_DELETE_DATETIME           IS NULL
AND arrm_receivable_status_type.LOGICAL_DELETE_DATETIME IS NULL;"
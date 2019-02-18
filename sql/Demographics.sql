"SELECT
    arrm_receivable.receivable_id,
    arrm_party.first_nations_status_ind,
    arrm_party.under_rcmp_investigation_ind,
    arrm_receivable_type.name_eng receivable_type,
    cascom_code.name_eng debtor_type,
    cpf_province.name_eng province,
    arrm_program_year.start_year,
    arrm_program_year.end_year,
    arrm_program.name_eng program_name,
    cpf_producer_org.name_eng producer_org,
    arrm_individual.birth_date,
    arrm_program_based_receivable.original_advance_incurred_date incurred
FROM
    ( ( ( ( ( ( ( ( ( arrm_receivable_type right
    JOIN arrm_receivable ON arrm_receivable_type.receivable_type_code = arrm_receivable.receivable_type_code )
    INNER JOIN arrm_debtor_account ON arrm_receivable.debtor_account_id = arrm_debtor_account.debtor_account_id ) left
    JOIN arrm_party ON arrm_debtor_account.party_id = arrm_party.party_id ) left
    JOIN cascom_code ON arrm_party.party_type_code = cascom_code.code_code )
    INNER JOIN arrm_program_based_receivable ON arrm_receivable.receivable_id = arrm_program_based_receivable.receivable_id ) left
    JOIN (
        SELECT DISTINCT
            arrm_receivable.receivable_id,
            lctn_prov_state.name_eng
        FROM
            ( arrm_addr left
            JOIN lctn_prov_state ON arrm_addr.prov_state_id = lctn_prov_state.prov_state_id ) right
            JOIN ( arrm_receivable left
            JOIN arrm_debtor_account ON arrm_receivable.debtor_account_id = arrm_debtor_account.debtor_account_id ) ON arrm_addr.party_id = arrm_debtor_account
.party_id
        WHERE
            ( arrm_addr.logical_delete_datetime ) IS NULL
            AND   ( arrm_addr.effective_to_datetime ) IS NULL
    ) cpf_province ON arrm_receivable.receivable_id = cpf_province.receivable_id ) left
    JOIN arrm_program_year ON arrm_program_based_receivable.program_year_code = arrm_program_year.program_year_code ) left
    JOIN arrm_program ON arrm_program_based_receivable.program_code = arrm_program.program_code ) left
    JOIN (
        SELECT
            cascom_code.code_code,
            cascom_code.name_eng
        FROM
            cascom_code
        WHERE
            ( cascom_code.code_type_code ) = 36
    ) cpf_producer_org ON arrm_program_based_receivable.producer_org_code = cpf_producer_org.code_code ) left
    JOIN arrm_individual ON arrm_party.party_id = arrm_individual.party_id
WHERE
    ( cascom_code.code_type_code ) = 12"
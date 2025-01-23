--Adding table setup
        PERFORM sl.dba_setup_table ('saml_identity_providers'  -- Table_name
                                  , 'sys_admins'    -- Create
                                  , 'sys_admins'    -- Read
                                  , 'sys_admins'    -- Update
                                  , 'sys_admins');  -- DELETE

                                  
-----  Internamente dba_setup_table
       -- generate the trigger and the trigger function
       PERFORM dba_create_dml_triggers(p_table);
      -- generate the CRUD functions
      PERFORM dba_crud_gen(p_table);
   
   
-- Ejecutar para que cree los procedimientos siguientes:
-- Procedimientos SAML
sql_saml_identity_providers
sql_ins_saml_identity_providers
sql_get_saml_identity_providers
sql_upd_saml_identity_providers
sql_del_saml_identity_providers
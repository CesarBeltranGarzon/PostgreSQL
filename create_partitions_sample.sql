-------------------------------------------------------------------------------
-- Story:        B-00000
-- Author:       Brayan cano
-- Date:         2024-07-29
-- Description:  Script to create partitions for table_name
--------------------------------------------------------------------------------
DO
$$
BEGIN

        CREATE TABLE sl.zlog_acct_account_groups_default -->default partition
            PARTITION OF sl.zlog_acct_account_groups DEFAULT --> main table;

        CREATE TABLE sl.zlog_acct_account_groups_201901
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-01-01') TO ('2019-02-01');

        CREATE TABLE sl.zlog_acct_account_groups_201902
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-02-01') TO ('2019-03-01');

        CREATE TABLE sl.zlog_acct_account_groups_201903
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-03-01') TO ('2019-04-01');

        CREATE TABLE sl.zlog_acct_account_groups_201904
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-04-01') TO ('2019-05-01');

        CREATE TABLE sl.zlog_acct_account_groups_201905
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-05-01') TO ('2019-06-01');

        CREATE TABLE sl.zlog_acct_account_groups_201906
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-06-01') TO ('2019-07-01');

        CREATE TABLE sl.zlog_acct_account_groups_201907
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-07-01') TO ('2019-08-01');

        CREATE TABLE sl.zlog_acct_account_groups_201908
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-08-01') TO ('2019-09-01');

        CREATE TABLE sl.zlog_acct_account_groups_201909
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-09-01') TO ('2019-10-01');

        CREATE TABLE sl.zlog_acct_account_groups_201910
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-10-01') TO ('2019-11-01');

        CREATE TABLE sl.zlog_acct_account_groups_201911
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-11-01') TO ('2019-12-01');

        CREATE TABLE sl.zlog_acct_account_groups_201912
            PARTITION OF sl.zlog_acct_account_groups
            FOR VALUES FROM ('2019-12-01') TO ('2020-01-01');

        -- Permissions
        ALTER TABLE sl.zlog_acct_account_groups_default OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201901 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201902 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201903 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201904 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201905 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201906 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201907 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201908 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201909 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201910 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201911 OWNER TO sluser;
        ALTER TABLE sl.zlog_acct_account_groups_201912 OWNER TO sluser;

    END IF;
END;
$$;

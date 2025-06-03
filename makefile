DBT_TARGET ?= dev

cleanup_time:
	@set -e; \
	rm -f package-lock.yml && dbt clean && dbt deps

deploy_livequery:
	@set -e; \
	dbt run-operation fsc_ibc.drop_livequery_schemas --vars '{"UPDATE_UDFS_AND_SPS": true}' -t $(DBT_TARGET); \
	dbt run -m livequery_models.deploy.core --vars '{"UPDATE_UDFS_AND_SPS": true}' -t $(DBT_TARGET); \
	dbt run-operation fsc_ibc.livequery_grants --vars '{"UPDATE_UDFS_AND_SPS": true}' -t $(DBT_TARGET)

deploy_chain_phase_1:
	@set -e; \
	dbt run -m livequery_models.deploy.core --vars '{"UPDATE_UDFS_AND_SPS": true}' -t $(DBT_TARGET); \
	dbt run-operation fsc_ibc.livequery_grants --vars '{"UPDATE_UDFS_AND_SPS": true}' -t $(DBT_TARGET); \
	dbt run-operation fsc_utils.create_udfs --vars '{"UPDATE_UDFS_AND_SPS": true}' -t $(DBT_TARGET); \
	if [ "$(DBT_TARGET)" != "prod" ]; then \
		dbt run -m "fsc_ibc,tag:phase_1" --full-refresh --vars '{"STREAMLINE_USE_DEV_FOR_EXTERNAL_TABLES":true, "MAIN_SL_NEW_BUILD_ENABLED": true, "GLOBAL_STREAMLINE_FR_ENABLED": true}' -t $(DBT_TARGET); \
		dbt test -m "fsc_ibc,tag:chainhead"; \
		dbt run -m "fsc_ibc,tag:streamline,tag:core,tag:complete" "fsc_ibc,tag:streamline,tag:core,tag:realtime" --vars '{"MAIN_SL_NEW_BUILD_ENABLED": true, "STREAMLINE_INVOKE_STREAMS":True, "MAIN_SL_TESTING_LIMIT": 500}' -t $(DBT_TARGET); \
	else \
		dbt run -m "fsc_ibc,tag:phase_1" --full-refresh --vars '{"MAIN_SL_NEW_BUILD_ENABLED": true, "GLOBAL_STREAMLINE_FR_ENABLED": true}' -t $(DBT_TARGET); \
		dbt test -m "fsc_ibc,tag:chainhead"; \
		dbt run -m "fsc_ibc,tag:streamline,tag:core,tag:complete" "fsc_ibc,tag:streamline,tag:core,tag:realtime" --vars '{"MAIN_SL_NEW_BUILD_ENABLED": true, "STREAMLINE_INVOKE_STREAMS":True}' -t $(DBT_TARGET); \
	fi; \
	echo "# wait ~10 minutes"; \
	echo "# run deploy_chain_phase_2"

deploy_chain_phase_2:
	@set -e; \
	if [ "$(DBT_TARGET)" != "prod" ]; then \
		dbt run -m "fsc_ibc,tag:phase_2" --full-refresh --vars '{"STREAMLINE_USE_DEV_FOR_EXTERNAL_TABLES":true, "GLOBAL_STREAMLINE_FR_ENABLED": true, "GLOBAL_BRONZE_FR_ENABLED": true, "GLOBAL_SILVER_FR_ENABLED": true, "GLOBAL_GOLD_FR_ENABLED": true, "GLOBAL_NEW_BUILD_ENABLED": true}' -t $(DBT_TARGET); \
		dbt run -m "fsc_ibc,tag:streamlines,tag:realtime" "fsc_ibc,tag:streamline,tag:complete" --vars '{"STREAMLINE_INVOKE_STREAMS":True, "DECODER_SL_NEW_BUILD_ENABLED": true}' -t $(DBT_TARGET); \
	else \
		dbt run -m "fsc_ibc,tag:phase_2" --full-refresh --vars '{"GLOBAL_STREAMLINE_FR_ENABLED": true, "GLOBAL_BRONZE_FR_ENABLED": true, "GLOBAL_SILVER_FR_ENABLED": true, "GLOBAL_GOLD_FR_ENABLED": true, "GLOBAL_NEW_BUILD_ENABLED": true}' -t $(DBT_TARGET); \
		dbt run -m "fsc_ibc,tag:streamline,tag:realtime" "fsc_ibc,tag:streamline,tag:complete" --vars '{"STREAMLINE_INVOKE_STREAMS":True, "DECODER_SL_NEW_BUILD_ENABLED": true}' -t $(DBT_TARGET); \
	fi; \
	echo "# wait ~10 minutes"; \
	echo "# run deploy_chain_phase_3"

deploy_chain_phase_3:
	@set -e; \
	if [ "$(DBT_TARGET)" != "prod" ]; then \
		dbt run -m "fsc_ibc,tag:phase_2" --vars '{"STREAMLINE_USE_DEV_FOR_EXTERNAL_TABLES":true}' -t $(DBT_TARGET); \
		dbt run -m "fsc_ibc,tag:phase_3" --full-refresh --vars '{"STREAMLINE_USE_DEV_FOR_EXTERNAL_TABLES":true, "GLOBAL_STREAMLINE_FR_ENABLED": true, "GLOBAL_SILVER_FR_ENABLED": true, "GLOBAL_GOLD_FR_ENABLED": true, "GLOBAL_NEW_BUILD_ENABLED": true}' -t $(DBT_TARGET); \
		dbt run -m "fsc_ibc,tag:silver" "fsc_ibc,tag:streamline,tag:realtime" "fsc_ibc,tag:streamline,tag:complete" --vars '{"STREAMLINE_INVOKE_STREAMS":True, "DECODER_SL_TESTING_LIMIT": 500}' -t $(DBT_TARGET); \
	else \
		dbt run -m "fsc_ibc,tag:phase_2" -t $(DBT_TARGET); \
		dbt run -m "fsc_ibc,tag:phase_3" --full-refresh --vars '{"GLOBAL_STREAMLINE_FR_ENABLED": true, "GLOBAL_SILVER_FR_ENABLED": true, "GLOBAL_GOLD_FR_ENABLED": true, "GLOBAL_NEW_BUILD_ENABLED": true}' -t $(DBT_TARGET); \
		dbt run -m "fsc_ibc,tag:silver" "fsc_ibc,tag:streamline,tag:realtime" "fsc_ibc,tag:streamline,tag:complete" --vars '{"STREAMLINE_INVOKE_STREAMS":True}' -t $(DBT_TARGET); \
	fi; \
	echo "# wait ~10 minutes"; \
	echo "# run deploy_chain_phase_4"

deploy_chain_phase_4:
	@set -e; \
	if [ "$(DBT_TARGET)" != "prod" ]; then \
		dbt run -m "fsc_ibc,tag:phase_3" --vars '{"STREAMLINE_USE_DEV_FOR_EXTERNAL_TABLES":true}' -t $(DBT_TARGET); \
		dbt run -m "fsc_ibc,tag:phase_4" --full-refresh -t $(DBT_TARGET); \
	else \
		dbt run -m "fsc_ibc,tag:phase_3" -t $(DBT_TARGET); \
		dbt run -m "fsc_ibc,tag:phase_4" --full-refresh -t $(DBT_TARGET); \
	fi; \

.PHONY: cleanup_time deploy_livequery deploy_chain_phase_1 deploy_chain_phase_2 deploy_chain_phase_3 deploy_chain_phase_4
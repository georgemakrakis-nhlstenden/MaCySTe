engine_telegraph_r_pod_modbus_nats_kv_client_extra_vars += \
	pod_name \
	modbus_host \
	nats_bucket \
	nats_key

engine_telegraph_r_pod_modbus_nats_kv_client_extra_var_pod_name = telegraph-r
engine_telegraph_r_pod_modbus_nats_kv_client_extra_var_modbus_host = $(engine_sim_plc_r_pod_modbus_nats_kv_server_eth0_ip)
engine_telegraph_r_pod_modbus_nats_kv_client_extra_var_nats_bucket = ship_controls
engine_telegraph_r_pod_modbus_nats_kv_client_extra_var_nats_key = r_engine
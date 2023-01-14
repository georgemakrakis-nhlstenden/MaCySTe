FUNCTION Registers_as_Real : REAL
  VAR_INPUT
    LW : UINT;
    HW : UINT;
  END_VAR

  {{
  union words_to_real {
    uint16_t i[2];
    float f;
  }w2r;

  w2r.i[0] = LW;
  w2r.i[1] = HW;

  return w2r.f;
  }}
END_FUNCTION

FUNCTION_BLOCK slowShutDown
  VAR
    CURRENT_POS : REAL;
  END_VAR
  VAR_EXTERNAL
    CURRENT_RUDDER_POSITION_1 : UINT;
    CURRENT_RUDDER_POSITION_2 : UINT;
  END_VAR
  VAR_IN_OUT
    GOVERNOR : REAL;
  END_VAR
  VAR_INPUT
    PUMP_ON : BOOL;
    SWITCH : UINT;
  END_VAR

  IF (NOT PUMP_ON) THEN
    CURRENT_POS := Registers_as_Real(CURRENT_RUDDER_POSITION_1, CURRENT_RUDDER_POSITION_2);
    IF (ABS(CURRENT_POS) < 3.0 OR GOVERNOR < 0.1) THEN
      IF UINT_TO_BOOL(SWITCH) THEN
        GOVERNOR := 1.0/6.0;
      ELSE
        GOVERNOR := 0.0;
      END_IF;
    ELSE
      GOVERNOR := GOVERNOR - 0.05;
    END_IF;

  END_IF;
END_FUNCTION_BLOCK

FUNCTION_BLOCK tuneGovernors
  VAR
    CURRENT_POS : REAL;
  END_VAR
  VAR_EXTERNAL
    CURRENT_RUDDER_POSITION_1 : UINT;
    CURRENT_RUDDER_POSITION_2 : UINT;
  END_VAR
  VAR
    DESIRED_POS : REAL;
  END_VAR
  VAR_EXTERNAL
    DESIRED_RUDDER_POSITION_1 : UINT;
    DESIRED_RUDDER_POSITION_2 : UINT;
  END_VAR
  VAR_IN_OUT
    GOVERNOR1 : REAL;
    GOVERNOR2 : REAL;
  END_VAR
  VAR
    MAX_DEG : REAL;
    DELTA_POSITION : REAL;
  END_VAR
  VAR_INPUT
    PUMPS_ON : BOOL;
  END_VAR

  IF (PUMPS_ON) THEN
    DESIRED_POS := Registers_as_Real(DESIRED_RUDDER_POSITION_1, DESIRED_RUDDER_POSITION_2);
    CURRENT_POS := Registers_as_Real(CURRENT_RUDDER_POSITION_1, CURRENT_RUDDER_POSITION_2);
    IF (DESIRED_POS < 0.0) THEN
      MAX_DEG := -35.0;
    ELSE
      MAX_DEG := 35.0;
    END_IF;

    DELTA_POSITION := ABS(DESIRED_POS - CURRENT_POS);

    IF (DELTA_POSITION >2.0) THEN
      GOVERNOR1 := 1.0;
      GOVERNOR2 := 1.0;
    ELSE
      GOVERNOR1 := DESIRED_POS / (2.0 * MAX_DEG);
      GOVERNOR2 := DESIRED_POS / (2.0 * MAX_DEG);
    END_IF;
  END_IF;
END_FUNCTION_BLOCK

FUNCTION_BLOCK tuneSingleGovernor
  VAR
    CURRENT_POS : REAL;
  END_VAR
  VAR_EXTERNAL
    CURRENT_RUDDER_POSITION_1 : UINT;
    CURRENT_RUDDER_POSITION_2 : UINT;
  END_VAR
  VAR
    DESIRED_POS : REAL;
  END_VAR
  VAR_EXTERNAL
    DESIRED_RUDDER_POSITION_1 : UINT;
    DESIRED_RUDDER_POSITION_2 : UINT;
  END_VAR
  VAR_IN_OUT
    GOVERNOR : REAL;
  END_VAR
  VAR
    MAX_DEG : REAL;
    DELTA_POSITION : REAL;
  END_VAR
  VAR_INPUT
    PUMP_ON : BOOL;
  END_VAR

  IF (PUMP_ON) THEN
    DESIRED_POS := Registers_as_Real(DESIRED_RUDDER_POSITION_1, DESIRED_RUDDER_POSITION_2);
    CURRENT_POS := Registers_as_Real(CURRENT_RUDDER_POSITION_1, CURRENT_RUDDER_POSITION_2);
    
    IF (DESIRED_POS < 0.0) THEN
      MAX_DEG := -35.0;
    ELSE
      MAX_DEG := 35.0;
    END_IF;

    DELTA_POSITION := ABS(DESIRED_POS - CURRENT_POS);

    IF (DELTA_POSITION > 2.0) THEN
      GOVERNOR := 1.0;
    ELSE
      GOVERNOR := DESIRED_POS / MAX_DEG;
    END_IF;
  END_IF;
END_FUNCTION_BLOCK

FUNCTION_BLOCK setMaxDeg
  VAR_EXTERNAL
    DESIRED_RUDDER_POSITION_1 : UINT;
    DESIRED_RUDDER_POSITION_2 : UINT;
  END_VAR
  VAR_OUTPUT
    DESIRED_RUDDER_POSITION : REAL;
  END_VAR
  VAR_EXTERNAL
    LOW_LEVEL_EXPANSION_TANK_ALARM : UINT;
    LOW_LEVEL_STOP_STEERING_PUMP_ALARM_1 : UINT;
    LOW_LEVEL_STOP_STEERING_PUMP_ALARM_2 : UINT;
    OIL_FILTER_HIGH_DIFFERENTIAL_PRESSURE_ALARM_P1 : UINT;
    OIL_FILTER_HIGH_DIFFERENTIAL_PRESSURE_ALARM_P2 : UINT;
    HIGH_OIL_TEMPERATURE_ALARM_P1 : UINT;
    HIGH_OIL_TEMPERATURE_ALARM_P2 : UINT;
  END_VAR

  DESIRED_RUDDER_POSITION := Registers_as_Real(DESIRED_RUDDER_POSITION_1, DESIRED_RUDDER_POSITION_2);
  IF (UINT_TO_BOOL(LOW_LEVEL_EXPANSION_TANK_ALARM) OR UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_1) OR UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_2) OR UINT_TO_BOOL(OIL_FILTER_HIGH_DIFFERENTIAL_PRESSURE_ALARM_P1) OR UINT_TO_BOOL(OIL_FILTER_HIGH_DIFFERENTIAL_PRESSURE_ALARM_P2) OR UINT_TO_BOOL(HIGH_OIL_TEMPERATURE_ALARM_P1) OR UINT_TO_BOOL(HIGH_OIL_TEMPERATURE_ALARM_P2)) THEN  
    IF (DESIRED_RUDDER_POSITION >=15.0) THEN
      DESIRED_RUDDER_POSITION := 15.0;
      
    ELSIF (DESIRED_RUDDER_POSITION <= -15.0) THEN
      DESIRED_RUDDER_POSITION := -15.0;
    END_IF;
  END_IF;
END_FUNCTION_BLOCK

FUNCTION Real_as_Registers : REAL
  VAR_INPUT
    NUMERO : REAL;
  END_VAR
  VAR_OUTPUT
    LW : UINT;
    HW : UINT;
  END_VAR

  {{
  union words_to_real {
    uint16_t i[2];
    float f;
  }w2r;

  w2r.f = NUMERO;
  LW = w2r.i[0];
  HW = w2r.i[1];
  }}
END_FUNCTION

PROGRAM rudder
  VAR_EXTERNAL
    CURRENT_RUDDER_POSITION_1 : UINT;
    CURRENT_RUDDER_POSITION_2 : UINT;
    RPM_P1_1 : UINT;
    RPM_P1_2 : UINT;
    LPS_P1_1 : UINT;
    LPS_P1_2 : UINT;
    PRES_VALVE_FLOW_P1_1 : UINT;
    PRES_VALVE_FLOW_P1_2 : UINT;
    PRESSURE_P1_1 : UINT;
    PRESSURE_P1_2 : UINT;
    TEMPERATURE_P1_1 : UINT;
    TEMPERATURE_P1_2 : UINT;
    PRESSURE_VALVE_OPEN_P1 : UINT;
    OIL_FILTER_HIGH_DIFFERENTIAL_PRESSURE_ALARM_P1 : UINT;
    HIGH_OIL_TEMPERATURE_ALARM_P1 : UINT;
    RPM_P2_1 : UINT;
    RPM_P2_2 : UINT;
    LPS_P2_1 : UINT;
    LPS_P2_2 : UINT;
    PRES_VALVE_FLOW_P2_1 : UINT;
    PRES_VALVE_FLOW_P2_2 : UINT;
    PRESSURE_P2_1 : UINT;
    PRESSURE_P2_2 : UINT;
    TEMPERATURE_P2_1 : UINT;
    TEMPERATURE_P2_2 : UINT;
    PRESSURE_VALVE_OPEN_P2 : UINT;
    OIL_FILTER_HIGH_DIFFERENTIAL_PRESSURE_ALARM_P2 : UINT;
    HIGH_OIL_TEMPERATURE_ALARM_P2 : UINT;
    OIL_P1_1 : UINT;
    OIL_P1_2 : UINT;
    LOW_LEVEL_STOP_STEERING_PUMP_ALARM_1 : UINT;
    OIL_P2_1 : UINT;
    OIL_P2_2 : UINT;
    LOW_LEVEL_STOP_STEERING_PUMP_ALARM_2 : UINT;
    OIL_TANK_1 : UINT;
    OIL_TANK_2 : UINT;
    LOW_LEVEL_EXPANSION_TANK_ALARM : UINT;
    GOVERNOR_SWITCH_P1 : UINT;
    GOVERNOR_SWITCH_P2 : UINT;
    GOVERNOR_P1_1 : UINT;
    GOVERNOR_P1_2 : UINT;
    GOVERNOR_P2_1 : UINT;
    GOVERNOR_P2_2 : UINT;
    DESIRED_RUDDER_POSITION_1 : UINT;
    DESIRED_RUDDER_POSITION_2 : UINT;
    GOVERNOR_P1_OUT_1 : UINT;
    GOVERNOR_P1_OUT_2 : UINT;
    GOVERNOR_P2_OUT_1 : UINT;
    GOVERNOR_P2_OUT_2 : UINT;
    DESIRED_RUDDER_POSITION_OUT_1 : UINT;
    DESIRED_RUDDER_POSITION_OUT_2 : UINT;
    GOVERNOR_SWITCH_P1_OUT : UINT;
    GOVERNOR_SWITCH_P2_OUT : UINT;
  END_VAR
  VAR
    PUMP1_ON : BOOL;
    PUMP2_ON : BOOL;
    PUMPS_ON : BOOL;
    turnOnPumps0 : turnOnPumps;
    slowShutDown0 : slowShutDown;
    slowShutDown1 : slowShutDown;
    tuneGovernors0 : tuneGovernors;
    tuneSingleGovernor1 : tuneSingleGovernor;
    tuneSingleGovernor0 : tuneSingleGovernor;
    setMaxDeg0 : setMaxDeg;
    Real_as_Registers86_OUT : REAL;
    Real_as_Registers86_LW : UINT;
    Real_as_Registers86_HW : UINT;
    Registers_as_Real1_OUT : REAL;
    Real_as_Registers17_OUT : REAL;
    Real_as_Registers17_LW : UINT;
    Real_as_Registers17_HW : UINT;
    Registers_as_Real2_OUT : REAL;
    Real_as_Registers24_OUT : REAL;
    Real_as_Registers24_LW : UINT;
    Real_as_Registers24_HW : UINT;
    Registers_as_Real34_OUT : REAL;
    Registers_as_Real31_OUT : REAL;
    Real_as_Registers38_OUT : REAL;
    Real_as_Registers38_LW : UINT;
    Real_as_Registers38_HW : UINT;
    Real_as_Registers41_OUT : REAL;
    Real_as_Registers41_LW : UINT;
    Real_as_Registers41_HW : UINT;
    Registers_as_Real59_OUT : REAL;
    Real_as_Registers65_OUT : REAL;
    Real_as_Registers65_LW : UINT;
    Real_as_Registers65_HW : UINT;
    Registers_as_Real6_OUT : REAL;
    Real_as_Registers73_OUT : REAL;
    Real_as_Registers73_LW : UINT;
    Real_as_Registers73_HW : UINT;
  END_VAR

  turnOnPumps0();
  PUMP1_ON := turnOnPumps0.PUMP1_ON;
  PUMP2_ON := turnOnPumps0.PUMP2_ON;
  PUMPS_ON := turnOnPumps0.PUMPS_ON;
  setMaxDeg0();
  Real_as_Registers86_OUT := Real_as_Registers(NUMERO := setMaxDeg0.DESIRED_RUDDER_POSITION, LW => Real_as_Registers86_LW, HW => Real_as_Registers86_HW);
  DESIRED_RUDDER_POSITION_1 := Real_as_Registers86_LW;
  DESIRED_RUDDER_POSITION_OUT_1 := DESIRED_RUDDER_POSITION_1;
  DESIRED_RUDDER_POSITION_2 := Real_as_Registers86_HW;
  DESIRED_RUDDER_POSITION_OUT_2 := DESIRED_RUDDER_POSITION_2;
  GOVERNOR_P1_OUT_1 := GOVERNOR_P1_1;
  Registers_as_Real1_OUT := Registers_as_Real(GOVERNOR_P1_1, GOVERNOR_P1_2);
  slowShutDown0(GOVERNOR := Registers_as_Real1_OUT, PUMP_ON := PUMP1_ON, SWITCH := GOVERNOR_SWITCH_P1_OUT);
  Real_as_Registers17_OUT := Real_as_Registers(NUMERO := slowShutDown0.GOVERNOR, LW => Real_as_Registers17_LW, HW => Real_as_Registers17_HW);
  GOVERNOR_P1_1 := Real_as_Registers17_LW;
  GOVERNOR_P1_2 := Real_as_Registers17_HW;
  GOVERNOR_P1_OUT_2 := GOVERNOR_P1_2;
  GOVERNOR_SWITCH_P1_OUT := GOVERNOR_SWITCH_P1;
  GOVERNOR_P2_OUT_1 := GOVERNOR_P2_1;
  Registers_as_Real2_OUT := Registers_as_Real(GOVERNOR_P2_1, GOVERNOR_P2_2);
  slowShutDown1(GOVERNOR := Registers_as_Real2_OUT, PUMP_ON := PUMP2_ON, SWITCH := GOVERNOR_SWITCH_P2_OUT);
  Real_as_Registers24_OUT := Real_as_Registers(NUMERO := slowShutDown1.GOVERNOR, LW => Real_as_Registers24_LW, HW => Real_as_Registers24_HW);
  GOVERNOR_P2_1 := Real_as_Registers24_LW;
  GOVERNOR_P2_2 := Real_as_Registers24_HW;
  GOVERNOR_P2_OUT_2 := GOVERNOR_P2_2;
  GOVERNOR_SWITCH_P2_OUT := GOVERNOR_SWITCH_P2;
  Registers_as_Real34_OUT := Registers_as_Real(GOVERNOR_P1_1, GOVERNOR_P1_2);
  Registers_as_Real31_OUT := Registers_as_Real(GOVERNOR_P2_1, GOVERNOR_P2_2);
  tuneGovernors0(GOVERNOR1 := Registers_as_Real34_OUT, GOVERNOR2 := Registers_as_Real31_OUT, PUMPS_ON := PUMPS_ON);
  Real_as_Registers38_OUT := Real_as_Registers(NUMERO := tuneGovernors0.GOVERNOR1, LW => Real_as_Registers38_LW, HW => Real_as_Registers38_HW);
  GOVERNOR_P1_1 := Real_as_Registers38_LW;
  GOVERNOR_P1_OUT_1 := GOVERNOR_P1_1;
  GOVERNOR_P1_2 := Real_as_Registers38_HW;
  GOVERNOR_P1_OUT_2 := GOVERNOR_P1_2;
  Real_as_Registers41_OUT := Real_as_Registers(NUMERO := tuneGovernors0.GOVERNOR2, LW => Real_as_Registers41_LW, HW => Real_as_Registers41_HW);
  GOVERNOR_P2_1 := Real_as_Registers41_LW;
  GOVERNOR_P2_OUT_1 := GOVERNOR_P2_1;
  GOVERNOR_P2_2 := Real_as_Registers41_HW;
  GOVERNOR_P2_OUT_2 := GOVERNOR_P2_2;
  GOVERNOR_P1_OUT_1 := GOVERNOR_P1_1;
  Registers_as_Real59_OUT := Registers_as_Real(GOVERNOR_P1_1, GOVERNOR_P1_2);
  tuneSingleGovernor0(GOVERNOR := Registers_as_Real59_OUT, PUMP_ON := PUMP1_ON);
  Real_as_Registers65_OUT := Real_as_Registers(NUMERO := tuneSingleGovernor0.GOVERNOR, LW => Real_as_Registers65_LW, HW => Real_as_Registers65_HW);
  GOVERNOR_P1_1 := Real_as_Registers65_LW;
  GOVERNOR_P1_2 := Real_as_Registers65_HW;
  GOVERNOR_P1_OUT_2 := GOVERNOR_P1_2;
  GOVERNOR_P2_OUT_1 := GOVERNOR_P2_1;
  Registers_as_Real6_OUT := Registers_as_Real(GOVERNOR_P2_1, GOVERNOR_P2_2);
  tuneSingleGovernor1(GOVERNOR := Registers_as_Real6_OUT, PUMP_ON := PUMP2_ON);
  Real_as_Registers73_OUT := Real_as_Registers(NUMERO := tuneSingleGovernor1.GOVERNOR, LW => Real_as_Registers73_LW, HW => Real_as_Registers73_HW);
  GOVERNOR_P2_1 := Real_as_Registers73_LW;
  GOVERNOR_P2_2 := Real_as_Registers73_HW;
  GOVERNOR_P2_OUT_2 := GOVERNOR_P2_2;
END_PROGRAM

FUNCTION_BLOCK turnOnPumps
  VAR
    DESIRED_POS : REAL;
  END_VAR
  VAR_EXTERNAL
    LOW_LEVEL_EXPANSION_TANK_ALARM : UINT;
    LOW_LEVEL_STOP_STEERING_PUMP_ALARM_1 : UINT;
    LOW_LEVEL_STOP_STEERING_PUMP_ALARM_2 : UINT;
    MANUAL_MODE : UINT;
    DESIRED_RUDDER_POSITION_1 : UINT;
    DESIRED_RUDDER_POSITION_2 : UINT;
    GOVERNOR_SWITCH_P1 : UINT;
    GOVERNOR_SWITCH_P2 : UINT;
  END_VAR
  VAR_OUTPUT
    PUMP1_ON : BOOL;
    PUMP2_ON : BOOL;
    PUMPS_ON : BOOL;
  END_VAR

  DESIRED_POS := Registers_as_Real(DESIRED_RUDDER_POSITION_1, DESIRED_RUDDER_POSITION_2);

  IF (UINT_TO_BOOL(LOW_LEVEL_EXPANSION_TANK_ALARM) AND NOT UINT_TO_BOOL(MANUAL_MODE)) THEN
    IF (UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_1) AND UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_2)) THEN
      GOVERNOR_SWITCH_P1 := BOOL_TO_UINT(FALSE);
      GOVERNOR_SWITCH_P2 := BOOL_TO_UINT(FALSE);
    ELSIF (UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_1) AND NOT UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_2)) THEN
      GOVERNOR_SWITCH_P1 := BOOL_TO_UINT(FALSE);
      GOVERNOR_SWITCH_P2 := BOOL_TO_UINT(TRUE);
    ELSIF (UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_2) AND NOT UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_1)) THEN
      GOVERNOR_SWITCH_P1 := BOOL_TO_UINT(TRUE);
      GOVERNOR_SWITCH_P2 := BOOL_TO_UINT(FALSE);
    ELSE
      GOVERNOR_SWITCH_P1 := BOOL_TO_UINT(TRUE);
      GOVERNOR_SWITCH_P2 := BOOL_TO_UINT(TRUE);
    END_IF;

  ELSIF (UINT_TO_BOOL(MANUAL_MODE)) THEN
    IF (UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_1)) THEN
      GOVERNOR_SWITCH_P1 := BOOL_TO_UINT(FALSE);
    END_IF;
    IF (UINT_TO_BOOL(LOW_LEVEL_STOP_STEERING_PUMP_ALARM_2)) THEN
      GOVERNOR_SWITCH_P2 := BOOL_TO_UINT(FALSE);
    END_IF;
  END_IF;

  IF (NOT (DESIRED_POS = 0.0)) THEN
    IF (UINT_TO_BOOL(GOVERNOR_SWITCH_P1) AND UINT_TO_BOOL(GOVERNOR_SWITCH_P2)) THEN
      PUMP1_ON := FALSE;
      PUMP2_ON := FALSE;
      PUMPS_ON := TRUE;
    ELSIF (UINT_TO_BOOL(GOVERNOR_SWITCH_P1) AND NOT UINT_TO_BOOL(GOVERNOR_SWITCH_P2)) THEN
      PUMP1_ON := TRUE;
      PUMP2_ON := FALSE;
      PUMPS_ON := FALSE;
    ELSIF (UINT_TO_BOOL(GOVERNOR_SWITCH_P2) AND NOT UINT_TO_BOOL(GOVERNOR_SWITCH_P1)) THEN
      PUMP1_ON := FALSE;
      PUMP2_ON := TRUE;
      PUMPS_ON := FALSE;
    ELSE
      PUMP1_ON := FALSE;
      PUMP2_ON := FALSE;
      PUMPS_ON := FALSE;
    END_IF;

  ELSE
    PUMP1_ON := FALSE;
    PUMP2_ON := FALSE;
    PUMPS_ON := FALSE;
  END_IF;
END_FUNCTION_BLOCK


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    VAR_GLOBAL
      CURRENT_RUDDER_POSITION_1 AT %IW100 : UINT;
      CURRENT_RUDDER_POSITION_2 AT %IW101 : UINT;
      RPM_P1_1 AT %IW102 : UINT;
      RPM_P1_2 AT %IW103 : UINT;
      LPS_P1_1 AT %IW104 : UINT;
      LPS_P1_2 AT %IW105 : UINT;
      PRES_VALVE_FLOW_P1_1 AT %IW106 : UINT;
      PRES_VALVE_FLOW_P1_2 AT %IW107 : UINT;
      PRESSURE_P1_1 AT %IW108 : UINT;
      PRESSURE_P1_2 AT %IW109 : UINT;
      TEMPERATURE_P1_1 AT %IW110 : UINT;
      TEMPERATURE_P1_2 AT %IW111 : UINT;
      PRESSURE_VALVE_OPEN_P1 AT %IW112 : UINT;
      OIL_FILTER_HIGH_DIFFERENTIAL_PRESSURE_ALARM_P1 AT %IW113 : UINT;
      HIGH_OIL_TEMPERATURE_ALARM_P1 AT %IW114 : UINT;
      RPM_P2_1 AT %IW115 : UINT;
      RPM_P2_2 AT %IW116 : UINT;
      LPS_P2_1 AT %IW117 : UINT;
      LPS_P2_2 AT %IW118 : UINT;
      PRES_VALVE_FLOW_P2_1 AT %IW119 : UINT;
      PRES_VALVE_FLOW_P2_2 AT %IW120 : UINT;
      PRESSURE_P2_1 AT %IW121 : UINT;
      PRESSURE_P2_2 AT %IW122 : UINT;
      TEMPERATURE_P2_1 AT %IW123 : UINT;
      TEMPERATURE_P2_2 AT %IW124 : UINT;
      PRESSURE_VALVE_OPEN_P2 AT %IW125 : UINT;
      OIL_FILTER_HIGH_DIFFERENTIAL_PRESSURE_ALARM_P2 AT %IW126 : UINT;
      HIGH_OIL_TEMPERATURE_ALARM_P2 AT %IW127 : UINT;
      OIL_P1_1 AT %IW128 : UINT;
      OIL_P1_2 AT %IW129 : UINT;
      LOW_LEVEL_STOP_STEERING_PUMP_ALARM_1 AT %IW130 : UINT;
      OIL_P2_1 AT %IW131 : UINT;
      OIL_P2_2 AT %IW132 : UINT;
      LOW_LEVEL_STOP_STEERING_PUMP_ALARM_2 AT %IW133 : UINT;
      OIL_TANK_1 AT %IW134 : UINT;
      OIL_TANK_2 AT %IW135 : UINT;
      OIL_TANK_P1_1 AT %IW136 : UINT;
      OIL_TANK_P1_2 AT %IW137 : UINT;
      OIL_TANK_P2_1 AT %IW138 : UINT;
      OIL_TANK_P2_2 AT %IW139 : UINT;
      LOW_LEVEL_EXPANSION_TANK_ALARM AT %IW140 : UINT;
      GOVERNOR_SWITCH_P1 AT %MW100 : UINT := 1;
      GOVERNOR_SWITCH_P2 AT %MW101 : UINT := 0;
      GOVERNOR_P1_1 AT %MW102 : UINT;
      GOVERNOR_P1_2 AT %MW103 : UINT;
      GOVERNOR_P2_1 AT %MW104 : UINT;
      GOVERNOR_P2_2 AT %MW105 : UINT;
      DESIRED_RUDDER_POSITION_1 AT %MW106 : UINT;
      DESIRED_RUDDER_POSITION_2 AT %MW107 : UINT;
      MANUAL_MODE AT %MW108 : UINT;
      GOVERNOR_P1_OUT_1 AT %QW100 : UINT;
      GOVERNOR_P1_OUT_2 AT %QW101 : UINT;
      GOVERNOR_P2_OUT_1 AT %QW102 : UINT;
      GOVERNOR_P2_OUT_2 AT %QW103 : UINT;
      DESIRED_RUDDER_POSITION_OUT_1 AT %QW104 : UINT;
      DESIRED_RUDDER_POSITION_OUT_2 AT %QW105 : UINT;
      GOVERNOR_SWITCH_P1_OUT AT %QW115 : UINT;
      GOVERNOR_SWITCH_P2_OUT AT %QW116 : UINT;
    END_VAR
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : rudder;
  END_RESOURCE
END_CONFIGURATION
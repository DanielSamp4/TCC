 
// retry_interval ::= 20
// retries ::= 2
// volt_resolution/float ::= 3.3
// _ADC_Bit_Resolution ::= 12
// A_CO ::= 605.18
// B_CO ::= -3.937
// A_Alcohol ::= 77.255
// B_Alcohol ::= -3.18
// A_CO2 ::= 110.47
// B_CO2 ::= -2.862
// A_Toluen ::= 44.947
// B_Toluen ::= -3.445
// A_NH4 ::= 102.2
// B_NH4 ::= -2.473
// A_Aceton ::= 34.668
// B_Aceton ::= -3.369
// _R0/float :=?
// _sensor_volt/float := 0.0
// _RL/float := 10.0
// RatioMQ135CleanAir := 3.6

import math
import gpio.adc show Adc

class MQ135 :

    // static ADC_RESOLUTION ::= 10 // for 10bit analog to digital converter.
    // static retries ::= 2
    // static retry_interval ::= 20
    retry_interval ::= 20
    retries ::= 2
    volt_resolution/float ::= 3.3
    _ADC_Bit_Resolution ::= 12
    A_CO ::= 605.18
    B_CO ::= -3.937
    A_Alcohol ::= 77.255
    B_Alcohol ::= -3.18
    A_CO2 ::= 110.47
    B_CO2 ::= -2.862
    A_Toluen ::= 44.947
    B_Toluen ::= -3.445
    A_NH4 ::= 102.2
    B_NH4 ::= -2.473
    A_Aceton ::= 34.668
    B_Aceton ::= -3.369
    _R0/float := 0.0
    _sensor_volt/float := 0.0
    _RL/float := 10.0
    RatioMQ135CleanAir := 3.6
    getVoltage MQ/Adc -> float:

        voltage/float :=?
        avg/float := 0.0
        adc/float := 0.0
        
        for i := 0; i < retries; i++:
            adc = MQ.get
            avg += adc
            sleep --ms=retry_interval

        
        voltage = ((avg/retries) * volt_resolution)/  ((math.pow 2 _ADC_Bit_Resolution) - 1.0)
        _sensor_volt = voltage
        //MQ.close
        return voltage

    calibrate ratioInCleanAir/float ->float:
        R0/float := 0.0
        RS_air/float := 0.0

        RS_air = volt_resolution*_RL
        RS_air = RS_air/_sensor_volt 
        RS_air = RS_air-_RL
        
        if RS_air < 0.0:
            RS_air = 0.0

        R0 = RS_air/ratioInCleanAir
        
        if R0 <0.0: 
            R0 = 0.0

        return R0

    readSensor _A/float _B/float -> float:
        PPM/float :=?
        ratio/float := 0.0
        RS_Calc/float := 0.0


        RS_Calc = volt_resolution*_RL
        RS_Calc = RS_Calc/_sensor_volt
        RS_Calc = RS_Calc-_RL

        ratio = RS_Calc / _R0
        PPM = _A * (math.pow ratio _B)
        return PPM



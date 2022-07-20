/**
Blinking LED example code.

This example prints 'blink' and makes the LED blink with a 1 second frequency.

How to wire the LED:
    - Place a 220ohm resistor in between the anode of the LED and GPIO19 and connect the cathode to ground.
    - The resistor limits the current that flows through the LED and the ESP32, increasing their life.
*/

import gpio
import math
import gpio.adc show Adc

LED ::= 2
MQ135 ::= 34
retry_interval ::= 20
retries ::= 2
volt_resolution/float ::= 3.3
_ADC_Bit_Resolution ::= 12
A ::= 34.668
B ::= -3.369
_R0/float :=?
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

readSensor -> float:
  PPM/float :=?
  ratio/float := 0.0
  RS_Calc/float := 0.0


  RS_Calc = volt_resolution*_RL
  RS_Calc = RS_Calc/_sensor_volt
  RS_Calc = RS_Calc-_RL

  ratio = RS_Calc / _R0
  PPM = A * (math.pow ratio B)
  return PPM





main:
  //led := gpio.Pin LED --output
  //gas := Adc (gpio.Pin MQ135)
  MQ := Adc (gpio.Pin MQ135)
  calcR0/float := 0.0
  for i := 0; i < 10; i++:
    _sensor_volt = getVoltage MQ
    calcR0 += calibrate RatioMQ135CleanAir
    print "."

  _R0 = calcR0/10
  print "done"

  while true:
    //print "blink"
    // led.set 1
    //print "Valor do gassssss é: "
    _sensor_volt = getVoltage MQ // checar pra ver se essa função é valida de transformação para ppm
    print readSensor 
    //gas.close

    sleep --ms=500
    // led.set 0
    // sleep --ms=500
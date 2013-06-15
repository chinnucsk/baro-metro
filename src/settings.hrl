%
-define(I2C_CONTROL, "/sys/class/i2c-adapter/i2c-1/new_device").
-define(BMP_INIT, "bmp085 0x77").
-define(BMP_TEMP, "/sys/bus/i2c/devices/1-0077/temp0_input").
-define(BMP_PRES, "/sys/bus/i2c/devices/1-0077/pressure0_input").

-define(QUERY_LEN, 180).
-define(TIMEOUT, 3000).
import processing.serial.*;

Serial myPort;  // Create object from Serial class
String myString = null;
int datadimension = 7; // e.g., there are 6 sensor values per line
PrintWriter output; // write data into files
long starttime = 0;
int timeduration = 60; //time duration of the recording in seconds

void setup() {
  size(640, 360);
  background(color(255,255,255));
  printArray(Serial.list());
  String portName = Serial.list()[1]; // change to your port 
  myPort = new Serial(this, portName, 115200);
  output = createWriter("FSR_GROUNDTRUTH_IMUData_" + year() + "_" + month() + "_" + day() + "_" + hour() + "_" + minute() + "_" + second() + ".csv");
  
  // Write header with timestamp
  output.println("timestamp,value1,value2,value3,value4,value5,value6");
}

void draw() {
  while (myPort.available() > 0) {
    if (starttime == 0) starttime = millis(); // record the starting time
    myString = myPort.readStringUntil('\n');
    println("Raw serial input: " + myString);
    if (myString != null) {
      String[] list = split(myString.trim(), ','); // Clean and split
      if (list.length == datadimension) {
        long unixTime = System.currentTimeMillis()/10; // Unix timestamp in miliseconds
        String timestampedLine = unixTime + "," + join(list, ",");
        output.println(timestampedLine);
        println(timestampedLine);
      }
      
      // Stop after timeduration
      if (millis() - starttime > timeduration * 1000) {
        output.flush();
        output.close();
        exit();
      }
    }
  }
}

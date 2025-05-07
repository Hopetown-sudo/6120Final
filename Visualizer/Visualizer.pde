PImage footImg;
Table table, pred_table;
int rowIdx = 0;
float[] fsrTrue = new float[7];
float[] fsrPred = new float[7];
int startTime;

// Normalizing foot sensor positions
float[][] fsrPositions = {
  //{0.30, 0.18}, //1 
  //{0.265, 0.35}, //2 
  //{0.710, 0.3}, //3
  //{0.345, 0.6},  //4
  //{0.695, 0.463}, //5
  //{0.675, 0.7}, //6
  //{0.498, 0.891} //7
  
  {0.30, 0.18}, //1
  {0.265, 0.35}, //2 
  {0.695, 0.463}, //5
  {0.345, 0.6},  //4
  {0.675, 0.7}, //6
  {0.498, 0.891}, //7
    {0.710, 0.3}, //3


 
  
  
};

int maxPoints = 500;

float[][] sensorHistory = new float[19][maxPoints];

color[] sockColors = {
  color(255, 69, 0), color(255, 99, 71),
  color(255, 140, 0), color(255, 0, 0),
  color(255, 80, 0)
};

color[] fsrColors = {
  color(0, 180, 0), color(0, 150, 0), color(0, 120, 0),
  color(0, 100, 0), color(0, 80, 0),  color(0, 60, 0),
  color(0, 40, 0)
};


color[] predColors = {
  color(0, 100, 255, 180), color(0, 120, 255, 180),
  color(0, 140, 255, 180), color(0, 160, 255, 180),
  color(0, 180, 255, 180), color(0, 200, 255, 180),
  color(0, 220, 255, 180)
};

void setup() {
  size(1000, 1200);
  footImg    = loadImage("Foot.png");
  table      = loadTable("processed_sensor_data_ma5_with_timestamp.csv", "header");
  pred_table = loadTable("knn_full_predictions.csv",       "header");
  frameRate(60);
  textAlign(CENTER);
  startTime  = millis();
}

void draw() {
  background(255);

  if (rowIdx < table.getRowCount() && rowIdx < pred_table.getRowCount()) {
    TableRow row     = table.getRow(rowIdx);
    TableRow predRow = pred_table.getRow(rowIdx);

    for (int i = 0; i < sensorHistory.length; i++) {
      for (int j = 0; j < maxPoints-1; j++) {
        sensorHistory[i][j] = sensorHistory[i][j+1];
      }
    }


    for (int i = 0; i < 7; i++) {
      float v    = row.getFloat("value"+(i+1));
      float pred = predRow.getFloat("pred_value"+(i+1));
      fsrTrue[i] = v;
      fsrPred[i] = pred;
      sensorHistory[i][maxPoints-1]      = v;
      sensorHistory[12+i][maxPoints-1]   = pred;
    }


    for (int i = 0; i < 5; i++) {
      float s = row.getFloat("sock_reading_"+(i+1));
      sensorHistory[7+i][maxPoints-1] = s;
    }

    rowIdx++;
  } else {
    noLoop();  
  }

  fill(30);
  textSize(20);
  text("Ground Truth", 250, 40);
  text("Prediction",   750, 40);
  image(footImg,  50,  80, 400, 600);
  image(footImg, 550,  80, 400, 600);

  for (int i = 0; i < 7; i++) {
    float gx = 50  + fsrPositions[i][0] * 400;
    float gy = 80  + fsrPositions[i][1] * 600;
    float px = 550 + fsrPositions[i][0] * 400;
    float py = 80  + fsrPositions[i][1] * 600;
    float gtSize   = map(fsrTrue[i], 2.3, 6, 10, 70);
    float predSize = map(fsrPred[i], 2.3, 6, 10, 70);

    // True
    fill(0, 255, 100, 180);
    ellipse(gx, gy, gtSize, gtSize);

    // Predicted
    fill(predColors[i]);
    ellipse(px, py, predSize, predSize);
  }

  float graphTop    = 700;
  float graphBottom = height - 20;
  float graphLeft   = 50;
  float graphRight  = width - 50;

  fill(245);
  noStroke();
  rect(graphLeft, graphTop, graphRight-graphLeft, graphBottom-graphTop);

  fill(30);
  textAlign(LEFT);
  textSize(14);
  text(
    "Filtered Sensor Readings:  FSR True (Green) & FSR Pred (Blue)",
    graphLeft, graphTop - 8
  );

  //// Sock values
  //for (int i = 0; i < 5; i++) {
  //  stroke(sockColors[i]);
  //  noFill();
  //  beginShape();
  //  for (int j = 0; j < maxPoints; j++) {
  //    float x = map(j, 0, maxPoints-1, graphLeft, graphRight);
  //    float y = map(sensorHistory[7+i][j], -3, 2, graphBottom, graphTop);
  //    vertex(x, y);
  //  }
  //  endShape();
  //}

  // FSR ground truth
  for (int i = 0; i < 7; i++) {
    stroke(fsrColors[i]);
    noFill();
    beginShape();
    for (int j = 0; j < maxPoints; j++) {
      float x = map(j, 0, maxPoints-1, graphLeft, graphRight);
      float y = map(sensorHistory[i][j], -3, 3, graphBottom, graphTop);
      vertex(x, y);
    }
    endShape();
  }

  // FSR predicted
  for (int i = 0; i < 7; i++) {
    stroke(predColors[i]);

    noFill();
    beginShape();
    for (int j = 0; j < maxPoints; j++) {
      float x = map(j, 0, maxPoints-1, graphLeft, graphRight);
      float y = map(sensorHistory[12+i][j], -3, 3, graphBottom, graphTop);
      vertex(x, y);
    }
    endShape();

  }
}

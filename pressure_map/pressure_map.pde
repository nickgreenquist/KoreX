import processing.serial.*;
import cc.arduino.*;

Arduino arduino; //creates arduino object

color back = color(64, 218, 255); //variables for the 2 colors

int read;

float value;

Serial myPort;  // The serial port

//heat map variables
int r = 4;  // number of rows in input array
int c = 4;  // number of columns in input array
int t = 25;  // parameter (array resize factor)
int rows = (r-1)*t;  // height of the heat map
int cols = (c-1)*t;  // width of the heat map

float[][] array = new float[r][c];
float[][] array_temp = new float[r][c];
float[][] interp_array = new float[rows][cols]; // interpolated array


//change these values to change how sensitive the sensors are
//l = low, m = medium, mh = mediumHigh, h = high
//max value from a sensor is 1024

//max 200
int l1 = 20;
int m1 = 80;
int mh1 = 120;
int h1 = 150;

//max 30
int l2 = 3;
int m2 = 5;
int mh2 = 12;
int h2 = 20;

//max 150
int l3 = 20;
int m3 = 60;
int mh3 = 100;
int h3 = 120;

//max 400
int l4 = 250;
int m4 = 275;
int mh4 = 300;
int h4 = 350;

//max 10
int l5 = 2;
int m5 = 2;
int mh5 = 3;
int h5 = 4;

//max 1000
int l6 = 600;
int m6 = 700;
int mh6 = 800;
int h6 = 900;

void setup() {
  size(800, 800);
   
  background(back);
  
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 9600); //the 1 means USB on the right of your Mac...if you use the usb to the left, 1 should be changed to 0...i think
  noStroke();
}

void draw() {
  
  background(back);  
  
  String message;
 
  //check for data from arduino at every frame loop of Processing app
  
  
    if(myPort.available() > 0) //we got something over the port (ie usb channel)
    {
      //1. read in entire array from arduino
      // get message till line break (ie whole array has been spit out by arduino
      message = myPort.readStringUntil('\n'); 
      print(message);
      
      
      
      //check if message actually contained any data
      if(message != null){
        message = message.trim();
          //2. split up string into array of values (16 values)
          String[] parts = message.split("-");
          
          //3. store all parts of the string split by '-' into array values
          for(int i = 0; i < parts.length; i++)
          {
              parts[i] = parts[i].trim();
              
              if(i >= r * r || parts[i].length() < 1)
              {
                break;
              }
              
              int x = i / r;
              int y = i % r;
             read = Integer.parseInt(parts[i]);
             
             
             //4. turn voltage readings into numbers useful for heat map
             if(i == 0 || i == 3 || i == 4 || i == 5 || i == 13) //200
             {
               if(read < l1) { read = 1;}
               if(read >= l1 && read < m1) { read = 2; }
               if(read >= m1 && read < mh1) { read = 3; }
               if(read >= mh1 && read < h1) { read = 4; }
               if(read > h1) { read = 4; }
             }
             else if(i == 1 || i == 2)//30
             {
               if(read < l2) { read = 1;}
               if(read >= l2 && read < m2) { read = 2; }
               if(read >= m2 && read < mh2) { read = 3; }
               if(read >= mh2 && read < h2) { read = 4; }
               if(read > h2) { read = 4; }
             }
             else if(i == 6 || i == 7) //150
             {
               if(read < l3) { read = 1;}
               if(read >= l3 && read < m3) { read = 2; }
               if(read >= m3 && read < mh3) { read = 3; }
               if(read >= mh3 && read < h3) { read = 4; }
               if(read > h3) { read = 4; }
             }
             else if(i == 8) //400
             {
               if(read < l6) { read = 1;}
               if(read >= l6 && read < m6) { read = 2; }
               if(read >= m6 && read < mh6) { read = 3; }
               if(read >= mh6 && read < h6) { read = 4; }
               if(read > h6) { read = 4; }
             }
             else if(i == 9) //10
             {
               if(read < l5) { read = 1;}
               if(read >= l5 && read < m5) { read = 2; }
               if(read >= m5 && read < mh5) { read = 3; }
               if(read >= mh5 && read < h5) { read = 4; }
               if(read > h5) { read = 4; }
             }
             else if(i == 10 || i == 11 || i == 12 || i == 14 || i == 15) //1000
             {
               if(read < l6) { read = 1;}
               if(read >= l6 && read < m6) { read = 2; }
               if(read >= m6 && read < mh6) { read = 3; }
               if(read >= mh6 && read < h6) { read = 4; }
               if(read > h6) { read = 4; }
             }
             
             array[x][y] = read;
        }
      }
    }
    else
    {
      //we didn't recieve any new values so leave array values the same, heat map won't change at all unless we recieve new values
    }
        
    bilinearInterpolation();
    applyColor();
  }
  
  void bilinearInterpolation() {  // Bi-linear Interpolation algorithm

  for (int i=0; i<r; i++) {
    for (int j=0; j<c; j++) {
      int x = j*t - 1;
      int y = i*t - 1;
      if (x<0)
        x=0;
      if (y<0)
        y=0;
      interp_array[y][x] = array[i][j];
    }
  }

  for (int y=0; y<rows; y++){
    int dy1 = floor(y/(t*1.0));
    int dy2 = ceil(y/(t*1.0)); 
    int y1 = dy1*t - 1;
    int y2 = dy2*t - 1;
    if (y1<0)
      y1 = 0;
    if (y2<0)
      y2 = 0;
    for (int x=0; x<cols; x++) {
      int dx1 = floor(x/(t*1.0));
      int dx2 = ceil(x/(t*1.0));
      int x1 = dx1*t - 1;
      int x2 = dx2*t - 1;
      if (x1<0)
        x1 = 0;
      if (x2<0)
        x2 = 0;
      float q11 = array[dy1][dx1];
      float q12 = array[dy2][dx1];
      float q21 = array[dy1][dx2];
      float q22 = array[dy2][dx2];

      int count = 0;
      if (q11>0)
        count++;
      if (q12>0)
        count++;
      if (q21>0)
        count++;
      if (q22>0)
        count++;

      if (count>2) {
        if (!(y1==y2 && x1==x2)) {

          float t1 = (x-x1);
          float t2 = (x2-x);
          float t3 = (y-y1);
          float t4 = (y2-y);
          float t5 = (x2-x1);
          float t6 = (y2-y1);

          if (y1==y2) {
            interp_array[y][x] = q11*t2/t5 + q21*t1/t5;
          } else if (x1==x2) {
            interp_array[y][x] = q11*t4/t6 + q12*t3/t6;
          } else {
            float diff = t5*t6;
            interp_array[y][x] = (q11*t2*t4 + q21*t1*t4 + q12*t2*t3 + q22*t1*t3)/diff;
          }
        } else {
          interp_array[y][x] = q11;
        }
      } else {
        interp_array[y][x] = 0;
      }
    }
  }
}

 void applyColor() {  // Generate the heat map 
  
  color c1 = color(0, 255, 156);  // light green color
  color c2 = color(255, 255, 0);  // yellow color
  color c3 = color(255, 156, 0);  // orange color
  color c4 = color(255,0,0);  // red color
  
  int resize = height/rows;
  scale(resize);
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      float value = interp_array[i][j];
      color c;
      float fraction;
      
      if (value>=1 && value<2) {
        fraction = (value-1)/1.0;
        c = lerpColor(c1, c2, fraction);
      } else if (value>=2 && value<3) {
        fraction = (value-2)/1.0;
        c = lerpColor(c2, c3, fraction);
      } else if (value>=3 && value<5) {
        fraction = (value-3)/2.0;
        c = lerpColor(c3, c4, fraction);
      } else 
        c = c4;
      stroke(c);
      point(j, i);
    }
  }

}
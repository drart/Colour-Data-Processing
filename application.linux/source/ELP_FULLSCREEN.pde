// ERROR/LOSSLESS PROCESSING
// Adam Tindale 2010
//
//-------------------
// REQUIRES
// PROCESSING + FULLSCREEN + VIDEO Libraries
// 640x480 RESOLUTION ON TWO MONITORS/PROJECTORS
// 
// DEVELOPED AT TINTartslab Residency +
// Banff Centre for the Arts New Media Institute Self-Directed Residency

// V.WHITEISRIGHT

float threshold = 130;
String filename = "64rev.csv";

import fullscreen.*; 
import processing.video.*;

int numPixels;

color mycolors[]; // colors of
int numberOfColors; // length of color array

float distances[]; // distances of pixesl from color array
int closest; 

int[] ryanr; // convert to rgb vals for slightly faster computation
int[] ryang;
int[] ryanb;

PImage sorted; // sorted image
PImage imgdif; // image with pixel thresholding

SoftFullScreen fs; 
Capture video;

void setup(){
  size(640*2, 480);

  video = new Capture(this, 640, 480, 15);
  
  numPixels = video.width * video.height;
  
  sorted = createImage(640,480, RGB);
  imgdif = createImage(640,480, RGB);
  
  loadColors(filename);
  numberOfColors = mycolors.length;
  distances = new float[numberOfColors];
  
  fs = new SoftFullScreen(this); 
  //fs.enter(); 
  noCursor();
 
  // precompute rgb values of the colors ryan selected 
  ryanr = new int[numberOfColors];
  ryang = new int[numberOfColors];
  ryanb = new int[numberOfColors];

  for (int j = 0 ; j < numberOfColors; j++){
     ryanr[j] = (mycolors[j] >> 16) & 0xFF; 
     ryang[j] = (mycolors[j] >> 8) & 0xFF;
     ryanb[j] = mycolors[j] & 0xFF;     
  }
}

public void captureEvent(Capture c) {
  c.read();
}

void draw(){
  //background(0);
  imgdif = createImage(640,480, RGB);
  imgdif.loadPixels();
  sorted.loadPixels();
  for (int i = 0; i < numPixels; i++) {

    for (int j = 0 ; j < numberOfColors; j++){

      int r1 = (video.pixels[i] >> 16) & 0xFF; 
      int g1 = (video.pixels[i] >> 8) & 0xFF;
      int b1 = video.pixels[i] & 0xFF;          

      /*
         int r2 = (mycolors[j] >> 16) & 0xFF; 
         int g2 = (mycolors[j] >> 8) & 0xFF;
         int b2 = mycolors[j] & 0xFF;   
       */
      int r2 = ryanr[j]; 
      int g2 = ryang[j];
      int b2 = ryanb[j];   

      r1 = r1 - r2;
      g1 = g1 - g2;
      b1 = b1 - b2;

      r1 = r1 * r1;
      g1 = g1 * g1;
      b1 = b1 * b1;

      distances[j] = r1 + g1 + b1 ; // euclidean distance but without sqrt
      // be sure to change threshold knowing that the scaling will be off
    }//iterate through colors

    closest = 0;

    for (int j = 1; j < numberOfColors; j++){
      if (distances[j] < distances[closest])
        closest = j;  
    }//iterate through colors to find closest distance

    sorted.pixels[i] = mycolors[closest];    
    
    /*
    if (distances[closest] > threshold)
      imgdif.pixels[i] = #FFFFFF; //#FFFFFF
    else
      imgdif.pixels[i] = video.pixels[i];
    */
    if (distances[closest] < threshold)
      imgdif.pixels[i] = #FFFFFF;
    else
      imgdif.pixels[i] = video.pixels[i]; 
  }// iterate through pixels

  imgdif.updatePixels();
  sorted.updatePixels();

  image(sorted, 0,0, width/2, height);
  image(imgdif, width/2,0, width/2, height);
}

void mouseClicked(){
 println(frameRate); 
}

void loadColors(String filename){
  // laod the csv file
  String[] lines = loadStrings(filename);
  // one color per line so use that to set the length of destination color array
  mycolors = new color[lines.length];
  
  for ( int i = 0 ; i < lines.length; i++){
    String[] rgbvals = split(lines[i], ',');
    // assume it all worked out and there are only 3 values per row
    // no alpha or b/w pixels for now
    mycolors[i] = color ( Integer.valueOf(rgbvals[0]) , Integer.valueOf(rgbvals[1]) , Integer.valueOf(rgbvals[2]) );
  }
}

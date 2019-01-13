/*program takes a few seconds to start as I am loading my images in to train with as not entirely certain how to save
a wekinator project at time of writing comment. If I figure it out and it's probably not hard, I'll put a copy of THIS version
of the code in with the final version*/

import oscP5.*; //all of the OSC related code is pulled from the example inputs and outputs for wekinator, adapted to fit this code. TODO: link to examples
import netP5.*;

OscP5 oscP5;
NetAddress dest;

//variables to define the training data
int numImgs = 18;
String[] imgStrings = {"Training_photos/IMG_20181222_082225.jpg",  //I'll be honest, this was painful
                        "Training_photos/IMG_20181222_082227.jpg", //because the images have the date and time on them they're easy to identify but I can't think of a way to do all this aside from manually
                        "Training_photos/IMG_20181222_115249.jpg", 
                        "Training_photos/IMG_20181222_115252.jpg", 
                        "Training_photos/IMG_20181222_122607.jpg", 
                        "Training_photos/IMG_20181222_142446.jpg", 
                        "Training_photos/IMG_20181222_142448.jpg", 
                        "Training_photos/IMG_20181222_142450.jpg", 
                        "Training_photos/IMG_20181222_174401.jpg", 
                        "Training_photos/IMG_20181224_081934.jpg", 
                        "Training_photos/IMG_20181224_163048.jpg",
                        "Training_photos/IMG_20181224_163050.jpg", 
                        "Training_photos/IMG_20181224_165155.jpg", 
                        "Training_photos/IMG_20181226_104959.jpg", 
                        "Training_photos/IMG_20181226_105002.jpg",
                        "Training_photos/MVIMG_20181222_090949.jpg",
                        "Training_photos/MVIMG_20181222_091318.jpg",
                        "Training_photos/MVIMG_20181224_090102.jpg"};
PImage[] testingImageData = new PImage [numImgs];
int[] imageTime = new int [numImgs];
boolean[] isCloudy = {false, false, true, true, true, true, true, true, true, false, false, false, false, false, true, true, false, false, false}; //had to be done by hand

float[] colour = new float [3];
float time = 0;

void setup() {
  createTrainingData();
  size(500, 500);
  background(255);
  colour[0] = 0;
  colour[1] = 0;
  colour[2] = width;
  colorMode(HSB, width);
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  dest = new NetAddress("127.0.0.1",6448);
  
  sendOscNames();
}

void draw() {
  background(colour[0], colour[1], colour[2]);
  pushStyle();
  fill(255);
  popStyle();
  rect(0,height-100,width,height-100);
  for (int i = 0; i < width; i++) {
    for (int j = height-100; j < height; j++) {
      float jcol = map (j, height-100, height, 0, width);
      stroke(i, width, jcol);
      point(i,j);
    }
  }
  if(frameCount % 2 == 0) {
    sendOsc();
  }
  drawTime();
}

void createTrainingData () { 
  for (int i = 0; i < numImgs; i++) {
    testingImageData[i] = loadImage(imgStrings[i]);
    imageTime[i] = extractTimeFromString(imgStrings[i]);
  }
}

void mousePressed() {
  if (mouseY >= 400) {
    colour[0] = mouseX;
    colour[1] = width;
    colour[2] = map(mouseY, 400, 500, 0, width);
  }
}

void drawTime() {
  pushStyle();
  stroke(0);
  textFont(createFont("Arial", 14));
  textAlign(LEFT, TOP);
  fill(255);
  text(time + "% of the way bewtween sunrise and sunset", 10, 10);
  popStyle();
}

void sendOsc() {
  OscMessage msg = new OscMessage("/wek/inputs");
  msg.add(colour[0]);
  msg.add(colour[1]);
  msg.add(colour[2]);
  oscP5.send(msg, dest);
}

void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("f")) { // looking for 1 control value
        float receivedTime = theOscMessage.get(0).floatValue();
        time = receivedTime*100;
     } else {
        println("Error: unexpected OSC message received by Processing: ");
        theOscMessage.print();
      }
 }
}

void averageColour() {
  loadPixels();
  float h = 0;
  float s = 0;
  float b = 0;
  for (int i = 0; i < pixels.length; i++) {
    h += hue(i);
    s += saturation(i);
    b += brightness(i);
  }
  h = h/pixels.length;
  s = s/pixels.length;
  b = b/pixels.length;
}

void sendOscNames() {
  OscMessage msg = new OscMessage("/wekinator/control/setOutputNames");
  msg.add("time"); //Now send all 5 names
  oscP5.send(msg, dest);
}

//functions to change hours and minutes to seconds - looks nicer than a bunch of copy pasted arithmetic

int extractTimeFromString (String name) {
  int end = name.length()-1; //all the strings end in the format HHMMSS.jpg
  int indexofendofseconds = end - 3; //go behind the .jpg
  int indexofstartofseconds = indexofendofseconds - 2;
  int indexofstartofminutes = indexofstartofseconds - 2;
  int indexofstartofhours = indexofstartofminutes -2;
  
  int hours = int(name.substring(indexofstartofhours, indexofstartofminutes));
  int minutes = int(name.substring(indexofstartofminutes, indexofstartofseconds));
  int seconds = int(name.substring(indexofstartofseconds, indexofendofseconds));
  
  return hourMod(hours) + minMod(minutes) + seconds;
}

int hourMod (int a) {
  return a*60*60;
}

int minMod (int a) {
  return a*60;
}

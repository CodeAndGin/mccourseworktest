import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;

float[] colour = new float [3];
float time = 0;

void setup() {
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

void sendOscNames() {
  OscMessage msg = new OscMessage("/wekinator/control/setOutputNames");
  msg.add("time"); //Now send all 5 names
  oscP5.send(msg, dest);
}

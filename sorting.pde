/*

 ** SIMPLE TOTAL PIXEL SORTING
 **
 ** Inspired by Pixel Sorting by Kim Asendorf
 ** https://github.com/kimasendorf/ASDFPixelSort
 **
 ** Cartesian-to-Polar image coordinates conversion made by Amnon Owed
 ** https://amnonp5.wordpress.com/2011/08/21/striate-cortex-advanced-pixel-manipulation/
 **
 ** Kesson Dalef (Giovanni Muzio) Copyleft - Creative Commons 3.0 Share-Alike license
 ** Date: December 2016
 **
 ** Please have fun modifying it and share any improvements, as the open source philosphy teaches to all of us.
 **

 */

// Sorting mode
// 0: cartesian
// 1: polar
// 2: random
// 3: Noise
// 4: circular
int mode = 4;
String[] modes = {"cartesian", "polar", "random", "noise", "circular"};

// Input image
PImage input;

// Density and factor for the polar conversion
// Feel free to play with these numbers
float density = 0.25;
float factor = 0.5;

// Output processed image
PImage output;
color averageColor;

// textfont
PFont f;

int index = 1;

int thisimage = 1;

void settings() {
  // Window size
  size(600, 800);
}

void setup() {
  // Input image
  input = loadImage("input" + thisimage + ".jpg");

  // Create an empty image with the same size an input image
  output = createImage(input.width, input.height, RGB);

  f = loadFont("SourceCodePro-Light-8.vlw");
  textFont(f);

  // If mode is Circular, make the sketch running on a square windows
  // So the circular shape will fit better
  if (mode == 4) surface.setSize(800, 800);
}

void draw() {

  background(255);

  noStroke();

  sortng(); // pixel sorting

  averageColor();  // Caltulate average color

  drawText();  // Draw text on the render

  saveFrame("./lol/processed_circular_" + thisimage + ".jpg");
  thisimage++;
  setup();

  // No loop, since it is useless
  //noLoop();
}

void sortng() {

  // Create an array of colors that stores the colors of all pixels of the image
  color[] c = new color[input.pixels.length];

  // Stores all the pixels colors
  c = input.pixels;

  // Sort the entire colors of the pixels by values
  c = sort(c);

  if (mode == 0) {
    // Make the output image pixels equals to the sorted pixels array
    output.pixels = c;
  } else if (mode == 1) {
    // Amnon Owed algorithm for Cartesian-to-Polar conversion on image
    // Link on the description
    for (float y=0; y<input.height; y+=density) {
      float r = y * factor;
      for (float x=0; x<input.width; x+=density) {
        float q = map(x, output.width, 0, 0, TWO_PI)-HALF_PI;
        int polarX = int(r * cos(q)) + output.width/2;
        int polarY = int(r * sin(q)) + output.height/2;
        polarX = constrain(polarX, 0, output.width-1);
        polarY = constrain(polarY, 0, output.height-1);
        int outputIndex = polarX + polarY * output.width;
        int inputIndex = int(x) + int(y) * input.width;
        output.pixels[outputIndex] = c[inputIndex];
      }
    }
  } else if (mode == 2) {
    // Random pixel sorting
    for (int i = 0; i < c.length; i++) {
      output.pixels[i] = c[int(random(c.length))];
    }
  } else if (mode == 3) {
    // Perlin noise pixel sorting
    float rand = 0;
    for (int i = 0; i < c.length; i++) {
      output.pixels[i] = c[int(noise(rand)*(c.length)-1)];
      rand+=0.01;
    }
  } else if (mode == 4) {
    beginShape(TRIANGLE_FAN);
    vertex(width/2, height/2);
    for (int i = 0; i <= 360; i++) {
      int index = int(map(i, 0, 360, 0, c.length));
      //int ind = abs(int(cos(map(index, 0, c.length, 0, PI)*c.length-1)));
      int ind = int(sin(map(index, 0, c.length, 0, PI))*(c.length-1));
      println(ind);
      float x = width/2 + cos(radians(i))*width*0.4;
      float y = height/2+sin(radians(i))*height*0.4;
      fill(c[ind]);
      vertex(x, y);
    }
    endShape();
  }

  // Show output processed picture
  if (mode != 4) {  // If the mode is not Circular, show the image, otherwise we have the shape drawed
    imageMode(CENTER);
    image(output, width/2, height/2, width*0.9, height*0.9);
  }
}

// Calculate the average color of the input image
void averageColor() {
  int avgR = 0;
  int avgG = 0;
  int avgB = 0;

  for (int i = 0; i < input.pixels.length; i++) {
    avgR += red(input.pixels[i]);
    avgG += green(input.pixels[i]);
    avgB += blue(input.pixels[i]);
  }

  avgR /= input.pixels.length;
  avgG /= input.pixels.length;
  avgB /= input.pixels.length;

  averageColor = color(avgR, avgG, avgB);
}

// Draw the text
void drawText() {
  textAlign(LEFT, CENTER);
  fill(100);
  text("average color: " + hex(averageColor), width*0.05, height*0.975);

  text("mode: " + modes[mode], width*0.05, height*0.025);

  textAlign(RIGHT, CENTER);
  text("simple total pixel sorting", width*0.95, height*0.975);
}

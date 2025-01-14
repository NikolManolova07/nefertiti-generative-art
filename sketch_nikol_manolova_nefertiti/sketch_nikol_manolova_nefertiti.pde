PImage image;
// We set a timer to control the construction and destruction phase.
float time = 0;
// Flag for construction phase.
boolean constructing = true;
// Set tile count for more granularity of the face.
int tiles = 300;

void setup() {
  size(1500, 600);

  // We load the same image for all faces.
  image = loadImage("nefertiti_sculpture.png");
  image.resize(500, 0);

  // The number of times draw() executes in each second may be controlled with the frameRate() function.
  frameRate(50);
  println("Resized image: " + image.width + "x" + image.height);
}

void draw() {
  float elapsedTime = millis() / 1000.0;
  
  noStroke();

  // Tile size based on the fixed number of tiles (300).
  float tileSize = width / tiles;

  translate(tileSize / 2, tileSize / 2);

  // Draw the first face (Black & White) with an Egyptian blue background (1, 54, 170).
  drawFaceWithBackground(convertToGrayscale(image), 0, 0, tiles, tileSize, color(1, 54, 170));

  // Draw the second face (Pop Art Style) with a bright pink background.
  drawFaceWithBackground(applyPopArtColors(image), width / 3, 0, tiles, tileSize, color(255, 54, 120));

  // Draw the third face (Original Colors) with a black background.
  drawFaceWithBackground(image, (2 * width) / 3, 0, tiles, tileSize, color(0, 0, 0));

  // Update time and phase.
  time += 1;
  if (time > 120) {
    // We switch phases after a certain time.
    constructing = !constructing;
    // Reset timer for the next phase.
    time = 0;
  }
  
  println("Frame: " + time + ", Elapsed time: " + elapsedTime);
}

// Function to apply a colored background and render the face tiles.
void drawFaceWithBackground(PImage img, float offsetX, float offsetY, float tiles, float tileSize, color bgColor) {
  // Draw the background with the specific color.
  fill(bgColor);
  noStroke();
  rect(offsetX, offsetY, image.width, image.height);
  // Draw the tiles for the face.
  drawTiles(img, offsetX, offsetY, tiles, tileSize);
}

PImage convertToGrayscale(PImage img) {
  PImage grayImage = createImage(img.width, img.height, RGB);
  img.loadPixels();
  grayImage.loadPixels();

  // Convert each pixel to grayscale.
  for (int i = 0; i < img.pixels.length; i++) {
    color c = img.pixels[i];
    float gray = brightness(c);

    grayImage.pixels[i] = color(gray, gray, gray);
  }
  grayImage.updatePixels();
  return grayImage;
}

PImage applyPopArtColors(PImage img) {
  PImage popArtImage = createImage(img.width, img.height, RGB);
  img.loadPixels();
  popArtImage.loadPixels();

  // Apply pop art colors (strong contrasts).
  for (int i = 0; i < img.pixels.length; i++) {
    color c = img.pixels[i];

    // Apply basic thresholds to create bright contrasting colors.
    float r = red(c) > 128 ? 255 : 0;
    float g = green(c) > 32 ? 128 : 0;
    float b = blue(c) > 64 ? 255 : 0;

    popArtImage.pixels[i] = color(r, g, b);
  }
  popArtImage.updatePixels();
  return popArtImage;
}

void drawTiles(PImage img, float offsetX, float offsetY, float tiles, float tileSize) {
  for (int x = 0; x < tiles; x++) {
    for (int y = 0; y < tiles; y++) {
      // Get pixel color from the current image.
      int imgX = (int)(x * tileSize);
      int imgY = (int)(y * tileSize);
      imgX = constrain(imgX, 0, img.width - 1);
      imgY = constrain(imgY, 0, img.height - 1);

      color c = img.get(imgX, imgY);
      float brightnessValue = brightness(c);

      // Refine scatter effect for clearer destruction phase.
      float scatterX = constructing ? 0 : random(-tileSize * 0.5, tileSize * 0.5);
      float scatterY = constructing ? 0 : random(-tileSize * 0.5, tileSize * 0.5);

      // Determine size based on construction or destruction phase.
      // Normalize time for smooth interpolation.
      float phase = map(time, 0, 120, 0, 1);
      phase = constrain(phase, 0, 1);

      float size = constructing
        ? lerp(0, tileSize, phase) // Gradually grow tiles during construction.
        : lerp(tileSize, 0, phase); // Gradually shrink tiles during destruction.

      // Scale size based on brightness for better detail.
      size *= map(brightnessValue, 0, 255, 0.5, 1.0);

      drawShadedEllipseBottomUp(x * tileSize + offsetX + scatterX, y * tileSize + offsetY + scatterY, size, c, 0); // Bottom-up recursion.
    }
  }
}

void drawShadedEllipseBottomUp(float x, float y, float size, color c, int level) {
  // Base case to stop recursion once size is too small.
  if (size <= 1) return;

  // Randomly modify the size to add variety.
  float randomnessFactor = random(0.8, 1.2);
  float newSize = size * randomnessFactor;

  // Calculate shading based on new size.
  float gradientFactor = map(newSize, 0, size, 0, 1);

  // Draw the ellipse at the current level of recursion.
  fill(lerpColor(color(0), c, gradientFactor));
  ellipse(x, y, newSize, newSize);

  // Recursively call for the next level, reducing the size further.
  drawShadedEllipseBottomUp(x, y, newSize * 0.8, c, level + 1); // Recursive call to draw smaller ellipses.
}

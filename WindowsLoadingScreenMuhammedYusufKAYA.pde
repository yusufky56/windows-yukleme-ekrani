// Windows 10/11 Boot Screen - 2 Turlu Örüntü
// Kaybolma ve doğma noktası = Saat 6 (en alt, HALF_PI)

// === GENEL AYARLAR ===
int startTime;
float textAlpha = 0;

// === SPINNER AYARLARI ===
int numDots = 5;
float radius = 20;
float dotSize = 4;
float dotDelay = 0.15;

// === 2 TURLU ÖRÜNTÜ ===
float turn1Duration = 2.0;
float turn2Duration = 1.8;
float waitDuration = 1.5;
float totalCycleDuration;

// === AÇILAR ===
float startAngle = PI;
float disappearAngle = HALF_PI;

// === RENKLER ===
color bgColor = color(0);
color dotColor = color(255);
color textColor = color(230);

// === LOGO AYARLARI ===
float logoWidth = 90;
float logoHeight = 62;
float lineThickness = 6;

PFont font;

void setup() {
  fullScreen();
  //size(800, 600);
  
  smooth(8);
  frameRate(60);
  noCursor();
  
  font = createFont("Segoe UI", 14);
  if (font == null) font = createFont("Arial", 14);
  textFont(font);
  
  totalCycleDuration = turn1Duration + turn2Duration + waitDuration;
  startTime = millis();
}

void draw() {
  background(bgColor);
  
  int elapsed = millis() - startTime;
  
  float centerX = width / 2;
  float centerY = height / 2;
  
  // Logo
  drawPerspectiveLogo(centerX, centerY - 50);
  
  // Spinner
  drawSpinner(centerX, centerY + 90);
  
  // Text fade in
  if (elapsed > 500) {
    textAlpha = min(255, textAlpha + 4);
  }
  drawText(centerX, centerY + 160);
}

void drawPerspectiveLogo(float x, float y) {
  pushMatrix();
  translate(x, y);
  
  // Windows mavi rengi (#00adef)
  fill(0, 173, 239);
  noStroke();
  
  // CSS rotateY(-30deg) TERSİ: Üst sağa, alt sola kayar
  float skew = 0.18;
  
  float w = logoWidth / 2;
  float h = logoHeight / 2;
  float gap = lineThickness / 2;
  
  // Y pozisyonuna göre X kayması (üst sağa, alt sola)
  // y = -h → xShift = +skew * h (sağa)
  // y = +h → xShift = -skew * h (sola)
  
  // Sol üst kare
  beginShape();
  vertex(-w + skew * h, -h);
  vertex(-gap + skew * h, -h);
  vertex(-gap + skew * gap, -gap);
  vertex(-w + skew * gap, -gap);
  endShape(CLOSE);
  
  // Sağ üst kare
  beginShape();
  vertex(gap + skew * h, -h);
  vertex(w + skew * h, -h);
  vertex(w + skew * gap, -gap);
  vertex(gap + skew * gap, -gap);
  endShape(CLOSE);
  
  // Sol alt kare
  beginShape();
  vertex(-w - skew * gap, gap);
  vertex(-gap - skew * gap, gap);
  vertex(-gap - skew * h, h);
  vertex(-w - skew * h, h);
  endShape(CLOSE);
  
  // Sağ alt kare
  beginShape();
  vertex(gap - skew * gap, gap);
  vertex(w - skew * gap, gap);
  vertex(w - skew * h, h);
  vertex(gap - skew * h, h);
  endShape(CLOSE);
  
  popMatrix();
}

void drawSpinner(float x, float y) {
  pushMatrix();
  translate(x, y);
  
  float currentTime = millis() / 1000.0;
  
  for (int i = 0; i < numDots; i++) {
    float dotStartTime = i * dotDelay;
    float dotTime = currentTime - dotStartTime;
    
    if (dotTime < 0) continue;
    
    drawDot(dotTime, i);
  }
  
  popMatrix();
}

void drawDot(float time, int dotIndex) {
  float cycleTime = time % totalCycleDuration;
  
  float angle;
  float opacity = 255;
  
  // === TUR 1: Saat 9'dan başla, tam tur, saat 9'da bitir ===
  if (cycleTime < turn1Duration) {
    float progress = cycleTime / turn1Duration;
    float eased = easeInOutSine(progress);
    
    angle = startAngle + (eased * TWO_PI);
    
    float absoluteCycle = floor(time / totalCycleDuration);
    if (absoluteCycle == 0 && progress < 0.3) {
      opacity = 255 * (progress / 0.3);
    }
  }
  // === TUR 2: Saat 9'dan saat 6'ya (3/4 tur = 270°) ===
  else if (cycleTime < turn1Duration + turn2Duration) {
    float turnTime = cycleTime - turn1Duration;
    float progress = turnTime / turn2Duration;
    
    float speedProgress = calculateTurn2Speed(progress);
    
    float rotationAmount = speedProgress * (PI + HALF_PI);
    angle = startAngle + rotationAmount;
    
    float normalizedAngle = angle % TWO_PI;
    
    float diff = normalizedAngle - HALF_PI;
    while (diff > PI) diff -= TWO_PI;
    while (diff < -PI) diff += TWO_PI;
    float distanceToBottom = abs(diff);
    
    if (distanceToBottom < 0.3) {
      opacity = 255 * (distanceToBottom / 0.3);
    }
  }
  // === BEKLEME: En altta görünmez, sonra doğuş ===
  else {
    float waitTime = cycleTime - turn1Duration - turn2Duration;
    float waitProgress = waitTime / waitDuration;
    
    angle = HALF_PI;
    
    if (waitProgress > 0.7) {
      float fadeInProgress = (waitProgress - 0.7) / 0.3;
      angle = HALF_PI + (fadeInProgress * HALF_PI);
      opacity = 255 * easeOutCubic(fadeInProgress);
    } else {
      opacity = 0;
    }
  }
  
  if (opacity > 5) {
    fill(dotColor, opacity);
    noStroke();
    float dotX = cos(angle) * radius;
    float dotY = sin(angle) * radius;
    ellipse(dotX, dotY, dotSize, dotSize);
  }
}

float calculateTurn2Speed(float t) {
  if (t < 0.4) {
    float p = t / 0.4;
    return p * p * 0.5;
  } 
  else if (t < 0.7) {
    float p = (t - 0.4) / 0.3;
    return 0.5 + (easeOutCubic(p) * 0.35);
  } 
  else {
    float p = (t - 0.7) / 0.3;
    return 0.85 + (easeOutCubic(p) * 0.15);
  }
}

void drawText(float x, float y) {
  fill(textColor, textAlpha);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("Lütfen Bekleyiniz", x, y);
}

float easeInOutCubic(float t) {
  if (t < 0.5) return 4 * t * t * t;
  return 1 - pow(-2 * t + 2, 3) / 2;
}

float easeInOutSine(float t) {
  return (1 - cos(t * PI)) / 2.0;
}

float easeInCubic(float t) {
  return t * t * t;
}

float easeOutCubic(float t) {
  return 1 - pow(1 - t, 3);
}

void keyPressed() {
  if (key == ESC || key == 'q' || key == 'Q') exit();
  
  if (key == 'r' || key == 'R') {
    startTime = millis();
    textAlpha = 0;
  }
}

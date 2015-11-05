/** 
 Assignment 2
 Author:          Bao Yuchen
 Student Number:  103254021
 Update:          2015/10/21
 */

final int FIGHTER_WIDTH = 50, FIGHTER_HEIGHT  = 50;         // the size of fighter (width and height)
final int ENEMY_WIDTH = 60, ENEMY_HEIGHT = 60;              // the size of enemy (width and height)
final int TREASUEE_WIDTH = 40, TREASUEE_HEIGHT = 40;        // the size of treasure (width and height)

PImage view_bg1Img, view_bg2Img;                            // views of background
PImage view_fighterImg, view_enemyImg, view_treasureImg;    // views of components
PImage view_hpImg;                                          // views of infomation
PImage view_end1, view_end2;                                // views of ending
PImage view_start1, view_start2;                            // views of starting

ArrayList<Integer> enemyX, enemyY, enemySpeed;              // list about enemy (position and moving speed)
ArrayList<Integer> xKeyStack, yKeyStack;                    // sequence of key pressed
int enemyCount;                                             // the number of enemy

int fightX, fightY;                                         // variables about fight (position of fight)

boolean hitting, healing;                                   // if buff effections is show (healing effection and hitting effection)
int healRange;                                              // range of healing effection

int bg1x= 0, bg2x = 640, bgSpeed = 5;                       // variables about background images (position of each background and moving speed)
int curHP, level;                                           // variables about players (hp and level)

int rdtrx, rdtry;                                           // variables about treasure  
int gameState;                                              // the state of game 0-logo; 1-game; 2-final

int xKeyPressedTime=1, yKeyPressedTime=1;                   // how long did user pressed a key
/**
 * to initialize system
 */
void setup () {
  size(640, 480) ;  
  xKeyStack = new ArrayList();
  yKeyStack = new ArrayList();
  loadResources();
  gameState = 0;
}

/**
 * to load pictures
 */
void loadResources() {
  view_hpImg = loadImage("img/hp.png");
  view_end1 = loadImage("img/end1.png");
  view_end2 = loadImage("img/end2.png");
  view_bg1Img = loadImage("img/bg1.png");
  view_bg2Img = loadImage("img/bg2.png");
  view_start1 = loadImage("img/start1.png");
  view_start2 = loadImage("img/start2.png");
  view_enemyImg = loadImage("img/enemy.png");
  view_fighterImg = loadImage("img/fighter.png");
  view_treasureImg = loadImage("img/treasure.png");
  enemyX = new ArrayList();
  enemyY = new ArrayList();
  enemySpeed = new ArrayList();
}

/**
 * add a new enemy into screen (max 5)
 */
void addEnemy() {
  if (enemyCount < 5) {
    enemyX.add(0);
    enemyY.add(0);
    enemySpeed.add(0);
    randomEnemy(true, enemyCount);
    enemyCount ++;
  }
}

/**
 * to start game or restart
 */
void startGame() {
  gameState = 1;
  enemyCount = 0;
  fightX = 600;
  fightY = 240;
  enemyX.clear();
  enemyY.clear();
  enemySpeed.clear();
  addEnemy();
  randomTreasure();
  curHP = 20;
  level = 0;
  hitting = false;
  healRange = 50;
}

/**
 * to calculate if fighter is hit the t@paramet
 *
 * @param int t@parametX        the location x of t@paramet
 * @param int t@parametY        the location y of t@paramet
 * @param int t@parametWidth    the width of t@paramet
 * @param int t@parametHeight   the height of t@paramet
 * @param errorX             set fault tolerant of location x 
 * @param errorY             set fault tolerant of location y
 * @return boolean         if fighter is hit t@paramet
 */
boolean isFighterHitTarget(int targetX, int targetY, int targetWidth, int targetHeight, int errorX, int errorY) {
  int xOffset = FIGHTER_WIDTH / 2 - errorX, yOffset = FIGHTER_HEIGHT/2 - errorY;
  int left = fightX - xOffset, right = fightX + xOffset;
  int top = fightY + yOffset, bottom = fightY - yOffset;
  int tl = targetX, tr = targetX + targetWidth;
  int tt = targetY, tb = targetY+targetHeight;
  if ((left< tr) && (right > tl)) {
    if ((top > tt)&&(bottom < tb)) {
      return true;
    }
  }
  return false;
}

/**
 * to calculate if fighter is hit on enemy
 *
 * @param boolean isCalculateX   set if consider location x while calculate hit algorithm
 * @param int index              to select whitch enemy will be calculated        
 * @return boolean             if fighter is hit on enemy
 */
boolean isHitEnemy(boolean isCalculateX, int index) {
  boolean ret = false;
  if (index < 0 ) {
    for (int i=0; i<enemyCount; i++) {
      int xx = enemyX.get(i), yy = enemyY.get(i);
      if (!ret) {
        if (isCalculateX) {
          ret = isFighterHitTarget(xx, yy, ENEMY_WIDTH, ENEMY_HEIGHT, 10, 10);
        } else {
          ret = isFighterHitTarget(0, yy, 640, ENEMY_HEIGHT, 10, 10);
        }
      } else {
        return true;
      }
    }
    return false;
  } else {
    int xx = enemyX.get(index), yy = enemyY.get(index);
    if (isCalculateX) {
      return isFighterHitTarget(xx, yy, ENEMY_WIDTH, ENEMY_HEIGHT, 10, 10);
    } else {
      return isFighterHitTarget(0, yy, 640, ENEMY_HEIGHT, 10, 10);
    }
  }
}

/**
 * to calculate if fighter is hit on treasure
 *
 * @return boolean if fighter is hit on treasure
 */
boolean isHitTreasure() {
  return isFighterHitTarget(rdtrx, rdtry, TREASUEE_WIDTH, TREASUEE_HEIGHT, 20, 20);
}

/**
 * to caltulate the new location x of background image
 *
 * @param int curX   input cuurrent location x of background image
 * @return int     new location x of backgroud image
 */
int moveBG(int curX) {
  // the more level the more quick background moves
  int speedOffset = level/10;
  int maxOffset = bgSpeed<<1;
  if (speedOffset> maxOffset) {
    speedOffset = maxOffset;
  }
  curX +=640 + bgSpeed + speedOffset;
  curX %= 1280;
  curX -= 640;
  return curX;
}

/**
 * to draw text with stroke effection
 *
 * @param String str           set the string value to print
 * @param color textColor      set the color of text
 * @param color strokeColor    set the color of stroke effection
 * @param int textx            set location x
 * @param int texty            set location y
 * @param int strokeWidth      set the width of stroke effection
 */
void drawStrokeText(String str, color textColor, color strokeColor, int textx, int texty, int strokeWidth) {
  fill(strokeColor);
  text(str, textx-strokeWidth, texty);
  text(str, textx+strokeWidth, texty);
  text(str, textx, texty-strokeWidth);
  text(str, textx, texty+strokeWidth);
  text(str, textx-strokeWidth, texty-strokeWidth);
  text(str, textx-strokeWidth, texty+strokeWidth);
  text(str, textx+strokeWidth, texty-strokeWidth);
  text(str, textx+strokeWidth, texty+strokeWidth);
  fill(textColor);
  text(str, textx, texty);
}

/**
 * to random an enemy to hit the fighter
 *
 * @param ind index                to select whitch enemy will be reset
 * @param boolean isAvoidFighter   set if the new fighter avoid fighter's position y
 */
void randomEnemy(boolean isAvoidFighter, int index) {
  enemyX.set(index, -100-ENEMY_WIDTH);
  enemySpeed.set(index, floor(random(1, 5)));
  do {
    enemyY.set(index, floor(random(0, 450)));
    // if need avoid fighter and enemy is in fighter line then random again
  } while (isAvoidFighter && isHitEnemy(false, index));
}

/**
 * to random an treasure
 */
void randomTreasure() {
  // x is from 20 to 620
  // y is from 20 to 460
  rdtrx = floor(random(600)+20);
  rdtry = floor(random(440)+20);
}

/**
 * to draw enemy and then calculate if fighter is hit on enemy, and cost hp
 */
void drawEnemy() {
  // if need add new enemy;
  float angle = 0;
  if (floor(level/5 + 1) > enemyCount) {
    addEnemy();
  }
  for (int i = 0; i < enemyCount; i ++) {
    angle = 0;
    int eSpeed = enemySpeed.get(i);
    int eX = enemyX.get(i), eY = enemyY.get(i);
    int sp = floor(eSpeed * (level/50f+1));
    if (sp > 20) {
      sp = 20;
    }
    if (eX < -ENEMY_WIDTH) {
      // wait 100 times, show warning and speed 
      int tSize = floor(20 * (1 - (- ENEMY_WIDTH - eX) / 100f) + 5);
      textAlign(LEFT);
      textSize(16);
      // draw different color with different speed
      if (sp > 10) {
        // 10 - 20 yellow to red
        drawStrokeText("" + sp, color(255, 255 - floor((sp-10)/10f * 255), 0), #ffffff, 25, eY+ 8 + ENEMY_HEIGHT/2, 1);
      } else {
        // 1 - 10 green to yellow
        drawStrokeText("" + sp, color(floor((sp)/10f * 255), 255, 0), #ffffff, 25, eY+ 8 + ENEMY_HEIGHT/2, 1);
      }
      textSize(tSize);
      drawStrokeText("!", #ff0000, #ffffff, 10, eY+ (tSize >> 1) + ENEMY_HEIGHT/2, 1);
      eX += 1;
      enemyX.set(i, eX);
    } else {
      // normal moves
      eX += sp;
      if (eX<fightX) {
        int yMove = (fightY-eY)>>6;// (fightY-eY)/2^6 fast calculate
        if (yMove>10) {
          yMove =10;
        }
        eY += yMove;
        enemyY.set(i, eY);
        angle = atan(float(yMove)/sp);
      }
      enemyX.set(i, eX);
    }
    if (eX>= 640) {
      // if enemy move out then make a new one
      randomEnemy(true, i);
    }
    if (hitting) { 
      // draw hitting effection
      hitting = false;
      stroke(#ff0000);
      fill(#ff0000);
      rect(0, 0, 640, 480);
    }
    if (isHitEnemy(true, i)) {
      // if enemy hit on fighter avoid to hit again
      randomEnemy(false, i); 
      curHP -= 20;
      hitting = true;
      stroke(#ff0000);
      fill(#ff0000);
      rect(0, 0, 640, 480);
    }
    pushMatrix();
    int half_height = ENEMY_HEIGHT>>1;
    int half_width = ENEMY_WIDTH>>1;
    translate(eX+half_width, eY + half_height);
    rotate(angle);
    image(view_enemyImg, -half_width, -half_height);
    popMatrix();
  }
}
/**
 * to draw treasure and then calculate if fighter is hit on treasure, and add hp, level
 */
void drawTreasure() {
  if (isHitTreasure()) {
    level += 1;
    if (curHP < 100) {
      curHP += 10;
    }
    do {
      randomTreasure();
      // random a new location avoid to hit again
    } while (isHitTreasure());
  }
  image(view_treasureImg, rdtrx, rdtry);
}

/**
 * to draw hp image
 *
 * @param int percent input the percent of hp, the percent will fixed from 0 to 100
 */
void drawHP(int percent) {
  if (percent< 0 ) {
    percent = 0;
  } else if (percent>100) {
    percent = 100;
  }
  int curhp = floor(194 * percent / 100);
  float hpVal = curHP;
  color hp;
  if (curHP > 50) {
    int val = 255 - floor((hpVal - 50f) / 50f * 255f);
    hp = color(val, 255, 0);
  } else {
    int val = floor(hpVal / 50f * 255f);
    hp = color(255, val, 0);
  }
  stroke(hp);
  fill(hp);
  rect(32, 24, curhp, 16);

  textSize(15);
  textAlign(CENTER);
  drawStrokeText(percent+"", #ffffff, #000000, 132, 37, 1);
  image(view_hpImg, 20, 20);
}

/**
 * to draw auto moving background image
 */
void drawBackground() {
  image(view_bg1Img, bg1x, 0);
  image(view_bg2Img, bg2x, 0);
  bg1x = moveBG(bg1x);
  bg2x = moveBG(bg2x);
}

/**
 * to draw fighter and hp ellipse
 */
void drawFighter() {
  int x = fightX - (FIGHTER_WIDTH >> 1), y = fightY - (FIGHTER_HEIGHT >> 1);
  float hpVal = curHP;
  color hp = #ffffff;
  if (curHP>66) {
    int val = floor((hpVal - 66f) / 33f * 255f);
    hp = color(val, 255, val);
  } else if (curHP>33) {
    int val = 255 - floor((hpVal - 33f) / 33f * 255f);
    hp = color(val, 255, 0);
  } else {
    int val = floor(hpVal / 33f * 255f);
    hp = color(255, val, 0);
  }
  stroke(hp);
  fill(hp);
  ellipse(fightX, fightY, 45 + floor(hpVal/4), 50);
  if (healing) {
    healRange +=10;
    ellipse(fightX, fightY, healRange, healRange);
    if (healRange >= 90) {
      healing = false;
    }
  } else if (healRange > 30) {
    healRange -= 5;
    ellipse(fightX, fightY, healRange, healRange);
  }
  image(view_fighterImg, x, y);
}

/**
 * to draw the value of level
 */
void drawLV() {
  textSize(15);
  textAlign(RIGHT);
  drawStrokeText("Level:"+level, #ffffff, #000000, 620, 20, 1);
}

/**
 * to show the final mark when game over
 * 
 * @param boolean isPressed if draw key pressed image
 */
void drawFinal(boolean isPressed) {
  if (isPressed) {
    image(view_end2, 0, 0);
  } else {
    image(view_end1, 0, 0);
  }
  textAlign(CENTER);
  textSize(30);
  drawStrokeText("Final Level:"+level, #ffffff, #ff0000, 320, 220, 2);
}

/**
 * if mouse is in area
 * 
 * @param int x         the position x of area
 * @param int y         the position y of area
 * @param int w         the width of area
 * @param int h         the height of area
 * @return boolean      return if mouse is in the area
 */
boolean isMouseHitArea(int x, int y, int r, int b) {
  return (mouseX>x && mouseX<r && mouseY>y && mouseY<b);
}

/**
 * to show logo
 * 
 * @param boolean isPressed if draw key pressed image
 */
void drawLogo(boolean isPressed) {
  if (isPressed) {
    image(view_start2, 0, 0);
  } else {
    image(view_start1, 0, 0);
  }
}

/**
 * handle key press events
 */
void scanInput() {
  switch(gameState) {
  case 0:    // key down from logo
    if (mousePressed && isMouseHitArea(210, 380, 450, 410)) {
      gameState = 11;
    }
    break;
  case 1:                    // key down from normal game
    if (xKeyStack.size()>0) {
      xKeyPressedTime ++;
      if (xKeyPressedTime>20) {
        xKeyPressedTime = 20;
      }
      switch(xKeyStack.get(xKeyStack.size()-1)) {
      case LEFT:
        fightX-=xKeyPressedTime>>1;
        break;
      case RIGHT:
        fightX+=xKeyPressedTime>>1;
      }
      int offset = FIGHTER_WIDTH >> 1;
      if (fightX < offset) {
        fightX = offset;
      } else if (fightX > (640 - offset)) {
        fightX = 640 - offset;
      }
    }
    if (yKeyStack.size()>0) {
      yKeyPressedTime ++; 
      if (yKeyPressedTime > 20) {
        yKeyPressedTime = 20;
      }
      switch(yKeyStack.get(yKeyStack.size()-1)) {
      case UP:
        fightY -= yKeyPressedTime >> 1;
        break;          
      case DOWN:
        fightY += yKeyPressedTime >> 1;
      }
      int offset = FIGHTER_HEIGHT >> 1;
      if (fightY < offset) {
        fightY = offset;
      } else if (fightY>(480 - offset)) {
        fightY = 480 - offset;
      }
    }
    break;
  case 2:  
    if (mousePressed && isMouseHitArea(210, 310, 435, 345)) {
      gameState = 22;
    }
  }
  if (mousePressed==false) {
    switch(gameState) {
    case 11:                 // key up from logo screen
      startGame();
      break;
    case 22:                 // key up from final screen
      gameState = 0;
      break;
    }
  }
}

/**
 * to draw components on screen
 */
void draw() {
  // print current position of the mouse
  // println(String.format("%d,%d",mouseX,mouseY));
  if (gameState == 0) {
    drawLogo(!isMouseHitArea(210, 380, 450, 410));
  } else if (gameState ==11) {
    drawLogo(true);
  } else if (curHP>0) {
    drawBackground();
    drawTreasure();
    drawFighter();
    drawEnemy();
    drawHP(curHP);
    drawLV();
  } else {
    if (gameState == 1) {
      gameState = 2;        // enter a null state until key up
    }
    drawFinal(gameState == 22 || !isMouseHitArea(210, 310, 435, 345));
  }
  scanInput();
}

/**
 * when key released
 */
void keyReleased() {
  if (keyCode == LEFT || keyCode == RIGHT) {
    xKeyPressedTime = 1;
    for (int i=0; i<xKeyStack.size(); i++) {
      if (xKeyStack.get(i)==keyCode) {
        xKeyStack.remove(i);
        break;
      }
    }
  }
  if (keyCode == UP||keyCode == DOWN) {
    yKeyPressedTime = 1;
    for (int i=0; i<yKeyStack.size(); i++) {
      if (yKeyStack.get(i)==keyCode) {
        yKeyStack.remove(i);
        break;
      }
    }
  }
}

/**
 * when key pressed
 */
void keyPressed() {
  if (keyCode == LEFT || keyCode == RIGHT) {
    if (xKeyStack.size()==0 || xKeyStack.get(xKeyStack.size()-1)-keyCode != 0) {
      xKeyStack.add(keyCode);
    }
  }
  if (keyCode == UP||keyCode == DOWN) {
    if (yKeyStack.size()==0 || yKeyStack.get(yKeyStack.size()-1)-keyCode != 0) {
      yKeyStack.add(keyCode);
    }
  }
}

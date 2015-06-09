import L3D.*;

L3D cube;

float ripple_offset=0;
float fade=0.8;
float temp = 1;                                  // tempature: from 0 to 1
color temp_meter_color = color(230,0,40);        // tempature meter: redish
float p15 = .5;                                  // phosphorus: from 0 to 1 
color p15_meter_color = color(230, 40, 230);     // phosphorus meter: purpleish
color defaultWaterColor = color(50, 100, 255);    // light blue
float animateSpeed = .0005;

void setup()
{
   size(500, 500, P3D);
  //size(displayWidth, displayHeight, P3D);
  cube=new L3D(this);
//  cube=new L3D(this, "rhooper@echovermont.org", "tothefuture", "echo3");
}

void draw()
{
  background(0);
  cube.background(0);
  
  // still water
  initStillWater();
  
  // surface animation
  rippleSurface();
  
  // Tempature meter
  meterTemp();
  
  // Phosphorus meter
  meterP15();
  
}

void initStillWater()
{
  for (float x=0; x<cube.side; x++)
    for (float z=0; z<cube.side; z++)
      for (float y=0; y<8; y++)
      {
        PVector point=new PVector(x, y, z);
        color c = defaultWaterColor;
        cube.setVoxel(point, getWaterColor(point, c) );
      }
    
}


void meterTemp()
{
  /*for (float x=0; x<(temp*cube.side); x++) {
    PVector point=new PVector(x, 1, (cube.side-1) );
    cube.setVoxel(point, temp_meter_color);
  }*/
     
  // update phosphorus
  if ((temp*cube.side) > cube.side) temp=0;
  else temp += (animateSpeed);
}


void meterP15()
{
  for (float x=0; x<(p15*cube.side); x++) {
    PVector point=new PVector(x, 0, (cube.side-1) );
    cube.setVoxel(point, p15_meter_color);
  }
     
  // update phosphorus
  if ((p15*cube.side) > cube.side) p15=.5;
  else p15 += (animateSpeed*2);
}

void rippleSurface()
{
  // set leds
  for (float x=0; x<cube.side; x++)
    for (float z=0; z<cube.side; z++)
      for (float y=7; y<8; y++)
      {
        PVector point=new PVector(x, y, z);
        float fade = sin(10*(pow((x-cube.center.x), 2)+pow((z-cube.center.z), 2))+ripple_offset)+7;
        color c = cube.colorMap(4/fade, 0, cube.side); 
        cube.setVoxel(point, getWaterColor(point, c));
      }
     
  // update offset
  if (ripple_offset>8*PI) ripple_offset=0;
  else ripple_offset+=0.03;
}

color getWaterColor(PVector p, color c){
  // algae color range
  int algae = 150;
  
  // get intial color parts
  int cr = (int) red(c);
  int cg = (int) green(c);
  int cb = (int) blue(c);
  
  // surface proximity
  float surfaceProx =  p.y / cube.side;  // 0 to 1 range
  
  // surface proximity % impact
  float surfaceProxImpact = -cos( (pow(surfaceProx,2) * 1.5) +1 );   // graph: https://www.desmos.com/calculator/obz7rq1eud
  
  // 0% + 90% temp = 0%
  // 0% + 80% p15 = 50%
  // 0% + 80% p15 + 90% temp = 70%
  // 0% + 80% p15 + 90% temp + 90% surfaceProx = 90%
  
  // phosphorus % impact
  float p15Impact = -cos(pow(p15,3) * 3);   // graph: https://www.desmos.com/calculator/vp05mzzkps
  
  
  int newG = cg + (int) (p15Impact * (algae*.6) ) + (int) (surfaceProxImpact * (algae*.4) );
  int newB = cb - (int) (p15Impact * (algae*.6) ) - (int) (surfaceProxImpact * (algae*.4) );
  
  color newWaterColor = color( cr, newG, newB ); 
  return newWaterColor;
}





#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "imgProcessing.h"



#define PI 3.141592654

void gaussianFilter(uint8_t *image, int numberOfRows, int numberOfColumns){

  int index,idx;

  double G[3][3] = { {0.0113, 0.0838, 0.0113},
                     {0.0838, 0.6193, 0.0838},
                     {0.0113, 0.0838, 0.0113}, };

  //uint8_t *filteredImage = malloc(sizeof(uint8_t) * (numberOfColumns * numberOfRows));
  //memcpy(filteredImage,image, sizeof(uint8_t) * (numberOfColumns * numberOfRows));

  double sum = 0;
  double conversion;

  for(int currentRow = 1; currentRow < numberOfRows-1; currentRow++){
    for(int currentColumn = 1; currentColumn < numberOfColumns-1; currentColumn++){
      sum = 0;
      index = currentRow*numberOfColumns + currentColumn;

      for(int m = 0; m < 3; m++){
        for(int n = 0; n < 3; n++){
          idx = (currentRow + m - 1)*numberOfColumns + (currentColumn + n - 1);
          conversion = image[idx];
          sum = sum + conversion*G[m][n];
        }
      }

      // arrondissement
      if((sum - ((long) sum)) >= 0.5){
        image[index] = (uint8_t) sum + 1;
      }
      else{
        image[index] = (uint8_t) sum;
      }
      
    }
  }
}

void binarizeImage(uint8_t *image, int numberOfRows, int numberOfColumns, int thresh){
  int index;
  for(int currentRow = 0; currentRow < numberOfRows; currentRow++){
    for(int currentColumn = 0; currentColumn < numberOfColumns; currentColumn++){

      index = currentRow*numberOfColumns + currentColumn;

      if(image[index] > thresh){
        image[index] = 255; //todo change for 1
      }
      else{
        image[index] = 0;
      }
    }
  }
}

uint32_t *houghCircularTransform(uint8_t *image, int numberOfRows, int numberOfColumns, double minRadius, double maxRadius, double step){
  int index,idx;
  int numberOfRadius = (maxRadius - minRadius)/step + 1;

  double a,b;
  int ar,br;

  int x,y;
  int max;

  uint16_t *accumulator = malloc(sizeof(uint16_t) * (numberOfColumns * numberOfRows));
  memset(accumulator,0, sizeof(uint16_t) * (numberOfColumns * numberOfRows));

  uint32_t *result = malloc(sizeof(uint32_t) * 2);

  for(int currentRow = 0; currentRow < numberOfRows; currentRow++){
    for(int currentColumn = 0; currentColumn < numberOfColumns; currentColumn++){
      index = currentRow*numberOfColumns + currentColumn;
      if(image[index] == 255){ //todo change for 1
        for(int i = 0; i < numberOfRadius; i++){
          for(int teta = 0; teta <= 360; teta++){
            a = currentRow + (minRadius + i*step)*cos(teta*PI/180);
            b = currentColumn + (minRadius + i*step)*sin(teta*PI/180);
            ar = round(a);
            br = round(b);

            if(ar > 0 && ar < numberOfRows && br > 0 && br < numberOfColumns){
              idx = ar*numberOfColumns + br;
              accumulator[idx] = accumulator[idx] + 1;
            }
          }
        }
      }
    }
  }
  
  // find the max
  max = 0;

  for(int currentRow = 0; currentRow < numberOfRows; currentRow++){
    for(int currentColumn = 0; currentColumn < numberOfColumns; currentColumn++){
      index = currentRow*numberOfColumns + currentColumn;
      if(accumulator[index] > max){
        x = currentColumn + 1;
        y = currentRow + 1;
        max = accumulator[index];
      }
    }
  }

  result[0] = x;
  result[1] = y;

  return result;
}

uint8_t *imageOfInterest(uint8_t *image, int numberOfRows, int numberOfColumns, int rangeValues){

  int index;

  int maxRows = round(numberOfRows/2);
  int maxCols = round(numberOfColumns/2);

  uint8_t *resizedImg = malloc(sizeof(uint8_t) * (maxCols * maxRows));
  memset(resizedImg,0, sizeof(uint8_t) * (maxCols * maxRows));

  for(int currentRow = 0; currentRow < maxRows; maxRows++){
    for(int currentColumn = 0; currentColumn < maxCols; maxCols++){
      index = currentRow*numberOfColumns + currentColumn;
      resizedImg[index] = image[index];
    }
  }
}




void gaussianFilter(uint8_t *image, int numberOfRows, int numberOfColumns);
void binarizeImage(uint8_t *image, int numberOfRows, int numberOfColumns, int thresh);
void erodeImage(uint8_t *image, int numberOfRows, int numberOfColumns);
uint32_t *houghCircularTransform(uint8_t *image, int numberOfRows, int numberOfColumns, double minRadius, double maxRadius, double step);
uint8_t *imageOfInterest(uint8_t *image, int numberOfRows, int numberOfColumns, int rangeValues);


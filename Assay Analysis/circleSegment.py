import sys
import numpy as np
from scipy import stats as sp
import cv2

# Set numpy's print options
np.set_printoptions(threshold=np.nan, linewidth=300)

# Get the image and show it
img = cv2.imread(str(sys.argv[1]))
cv2.imshow("Original", img)
cv2.moveWindow("Original", 0, 0)
cv2.waitKey(0)
cv2.destroyAllWindows()

cimg = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Crops of all tubes found
croppedTubes = []

# dp=1   1 ... 20
# minDist=10 log 1...1000
# param1=100
# param2=30  10 ... 50
# minRadius=1   1 ... 500
# maxRadius=30  1 ... 500
circles = cv2.HoughCircles(cimg, cv2.HOUGH_GRADIENT, 1, 20,
    param1=100, param2=30, minRadius=1, maxRadius=30)
circles = np.uint16(np.around(circles))

# Code for user corrections starts here
# 
# 1. use opencv api for detecting mouse clicks
# 2. crop a large region around mouse click
# 3. apply hough circle transform in cropped region with looser parameters
# 4. append new hough circle to list of circles w/ numpy stuff
# 5. loop as neccesary

# Click correction callback function
def clickCorrect(event, x, y, flags, param):
    global refPt, circles, newCircle

    # Obtain sum of radii and number of circles
    sumRad = 0
    numCircles = 0
    for i in circles[0, :]:
        sumRad = sumRad + i[2]
        numCircles = numCircles + 1

    # Radius for correction based on average radius of detected circles
    radius = sumRad / numCircles

    # Print coodinates -- this is for testing purposes only
    print("Coordinates: ", x, y)
    
    # When user clicks on the picture, their coordinates are saved.
    # A crop of the area to place the circle is shown.
    # Circle data is saved to a global to be used in the outside code
    # Might need to check edge cases later
    if event == cv2.EVENT_LBUTTONDOWN :
       # x and y seem to be inverted (x = vertical, y = horizontal)
       croppedImg = img[(y - radius):(y + radius), (x - radius):(x + radius)]
       cv2.imshow("Click Crop", croppedImg)
       newCircle = [x, y, radius]

# Draw detected circles on img
for i in circles[0,:]:
    # draw the outer circle
    cv2.circle(img,(i[0],i[1]),i[2],(0,255,0),2)
    # draw the center of the circle
    cv2.circle(img,(i[0],i[1]),2,(0,0,255),3)

# Display detected circles
cv2.namedWindow("img")

# Set mouse callback function
cv2.setMouseCallback("img", clickCorrect)

# Declaration of circle to be added by user
newCircle = [0, 0, 0]

# Loop of user correction
# Left click will start correction process
# 'w' will confirm user's correction circle, draw it, and add it to list
# 'q' will quit loop and move on to rest of the code 
while True:
    # Display image and wait for click
    cv2.imshow("img", img)
    key = cv2.waitKey(1) & 0xFF

    # Quit correcting, break out of loop
    if key == ord("q"):
       break

    # "Write" new circle
    if key == ord("w"):
       x = newCircle[0]
       y = newCircle[1]
       rad = newCircle[2]

       # draw the outer circle
       cv2.circle(img,(x,y),rad,(0,255,0),2)
       # draw the center of the circle
       cv2.circle(img,(x,y),2,(0,0,255),3)
       croppedTubes.append(img[(x-rad):(x+rad), (y-rad):(y+rad)])



# Note: moved the array declaration above so newly detected tubes can also be included
# Crop the tubes based on hough circle radius and centers
for i in circles[0,:]:
    # print("x:",i[0], "y:",i[1], "r:",i[2])
    # print("x1:",i[0]-i[2], "x2:",i[0]+i[2], "y1:",i[1]-i[2], "y2:",i[1]+i[2])
    croppedTubes.append(img[i[1]-i[2]:i[1]+i[2], i[0]-i[2]:i[0]+i[2]])

# Convert the cropped tubes to grayscale
grayTubes = []
for i in croppedTubes:
    grayTubes.append(cv2.cvtColor(i, cv2.COLOR_BGR2GRAY))

# Do otsu's binarization on the tubes to get masks, then erode masks
threshTubes = []
kernel = np.ones((3,3),np.uint8)
for i in grayTubes:
    ret, thresh = cv2.threshold(i, 0, 255, cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)
    thresh = cv2.erode(thresh, kernel, iterations=1)
    threshTubes.append(thresh)

# Perform the mask
maskedTubes = []
bmean = [] #mean of the blue values, ignoring pure black spots
gmean = [] #mean of the green values, ignoring pure black spots
rmean = [] #mean of the red values, ignoring pure black spots
bmedian = [] #median of the blue values, ignoring pure black spots
gmedian = [] #median of the green values, ignoring pure black spots
rmedian = [] #median of the red values, ignoring pure black spots
bmode = [] #mode of the blue values, ignoring pure black spots
gmode = [] #mode of the green values, ignoring pure black spots
rmode = [] #mode of the red values, ignoring pure black spots
for i in range(len(croppedTubes)):
    masked = cv2.bitwise_and(croppedTubes[i], croppedTubes[i], mask=threshTubes[i])
    maskedTubes.append(masked)

    #Print tube # so it's easier to collect data
    print("Tube #: ", i + 1)
    blue, green, red = masked[:,:,0], masked[:,:,1], masked[:,:,2]
    massiveOr = np.logical_or(np.logical_or(blue, green), red)
    nz0, nz1 = np.where(massiveOr > 0)
    bmean.append(np.mean(blue[nz0, nz1]))
    gmean.append(np.mean(green[nz0, nz1]))
    rmean.append(np.mean(red[nz0, nz1]))
    print("Mean (b,g,r):", bmean[-1], gmean[-1], rmean[-1])
    bmedian.append(np.median(blue[nz0, nz1]))
    gmedian.append(np.median(green[nz0, nz1]))
    rmedian.append(np.median(red[nz0, nz1]))
    print("Median (b,g,r):", bmedian[-1], gmedian[-1], rmedian[-1])
    bmode.append(sp.mode(blue[nz0, nz1])[0][0])
    gmode.append(sp.mode(green[nz0, nz1])[0][0])
    rmode.append(sp.mode(red[nz0, nz1])[0][0])
    print("Mode (b,g,r):", bmode[-1], gmode[-1], rmode[-1])
    print("")

    cv2.imshow("Crop", cv2.resize(masked, (4*masked.shape[0], 4*masked.shape[1])))
    cv2.waitKey(0)

#Print circle coordinates
print circles
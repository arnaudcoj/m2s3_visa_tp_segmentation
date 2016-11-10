// Une macro-squelette pour la color.
// Version: 0.1
// Date: 14/09/2011
// Author: L. Macaire

macro "segmentation" {

// recuperation du ID de l'image
image = getImageID();
selectImage (image);

value = getNumber ("quel nombre de classes", value);

Dialog.create("Debut");
Dialog.addMessage(" Cliquer sur OK pour commencer le traitement ");
Dialog.show();


//setBatchMode(true);

run("k-means Clustering ...", "number_of_clusters=" + value + " cluster_center_tolerance=0.00010000 enable_randomization_seed randomization_seed=48 show_clusters_as_centroid_value");

// recuperation de la taille W x H de l'image
W = getWidth();
H = getHeight();
K = value;

R_centres = newArray(K);
Array.fill(R_centres, -1);
G_centres = newArray(K);
Array.fill(G_centres, -1);
B_centres = newArray(K);
Array.fill(B_centres, -1);

//run("Duplicate...", "title=image_dup");
//image_dup = getImageID();
selectImage ("Cluster centroid values");

//for each pixel
for (j=0; j<H; j++) {
  for (i=0; i<W; i++) {
    //fetch the colors of the current pixel
    color = getPixel(i,j);
    R = (color & 0xff0000) >> 16;
    G = (color & 0x00ff00) >> 8;
    B = (color & 0x0000ff) ;
    centre_exists = false;
    k = 0;

    //for each class
    while (!centre_exists && k < K) {

      //if we find an empty class we break the loop to append the color to the loop
      if (R_centres[k] == -1) {
        break;
      }

      //if we find the same color, we end the loop and set the centre_exists flag to true;
      if (R_centres[k] == R
        && G_centres[k] == G
        && B_centres[k] == B) {
          centre_exists = true;
      }

      k++;
    }

    //out of the k loop, if k == K, we have all our colors so we step out of the i loop
    if(k >= K) {
      break;
    }

    //here k < K, if the centre doesn't exist, we add it to the array
    if (!centre_exists) {
      R_centres[k] = R;
      G_centres[k] = G;
      B_centres[k] = B;
    }
  }

  //out of the i loop, if k == K, we have all our colors so we step out of the j loop
  if(k >= K) {
    break;
  }
}

//print the centres
for (k=0; k<K; k++) {
  print(k, ". R=", R_centres[k], ", G=", G_centres[k],", B=", B_centres[k]);
}

//ask to open a new image
Dialog.create("Segmentation automatique");
Dialog.addMessage("Veuillez choisir une nouvelle image à segmenter automatiquement.");
Dialog.show();

run("Open...");
new_image = getImageID();
selectImage (new_image);

//for each pixel
for (j=0; j<H; j++) {
  for (i=0; i<W; i++) {

    //fetch color from the pixel of the new image
    color = getPixel(i,j);
    R = (color & 0xff0000) >> 16;
    G = (color & 0x00ff00) >> 8;
    B = (color & 0x0000ff) ;

    //compute the distance between current pixel and centroide k = 0 to set it as current min
    k_min_dist = 0;
    min_dist = pow(R - R_centres[0], 2) + pow(G - G_centres[0], 2) + pow(B - B_centres[0], 2);

    //for each k (k > 1)
    for (k=1; k<K; k++) {
      //compute the distance between current pixel and centroide k
      dist = pow(R - R_centres[k], 2) + pow(G - G_centres[k], 2) + pow(B - B_centres[k], 2);

      //if the dist is lower than the min_dist, it becomes the min_dist
      if (dist < min_dist) {
        k_min_dist = k;
        min_dist = dist;
      }
    }

    //we concatenate the centroide's R,G,B in order to create the future pixel color
    k_color = ((R_centres[k_min_dist] & 0xff ) << 16) + ((G_centres[k_min_dist] & 0xff) << 8) + B_centres[k_min_dist] & 0xff;

    //set the pixel of the new image to the centroide color
    setPixel(i,j,k_color);

  }
}

//setBatchMode(false);

Dialog.create("Fin");
Dialog.addMessage(" Cliquer sur OK pour terminer le traitement");
Dialog.show();


}

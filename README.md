# Vesicle Unwrapper
A clumsy attempt to analyse vesicle fusion data using ImageJ Macro

## In an nutshell
This macro takes the vesicle membrane and stresches it flat. After that it slices the iamge to analyze the fluorescent intensity of the membrane.


## Usage

Noted that so far

### Membrane selection
This is an example of vesicle

![Screenshot 2021-03-03 at 14 12 45](https://user-images.githubusercontent.com/9105574/189682885-1472d86f-1876-451d-bef8-e7cb89cf30be.png) 

Vesicle after selctions of the membrane

![Screenshot 2021-03-03 at 14 26 34](https://user-images.githubusercontent.com/9105574/189682927-c99985a5-83aa-48f6-9765-0416e473315c.png)

### Unwrapping
 ![VesicleUnwrapped](https://user-images.githubusercontent.com/9105574/189683398-d0b23277-5498-4649-b284-12d1d0b34023.png)

### Background removal
![maskedGUV](https://user-images.githubusercontent.com/9105574/189683469-23b01e97-7e70-4f6a-9e47-cd38cf12fa3c.png)

### Runnning Average
![running average](https://user-images.githubusercontent.com/9105574/189683525-6f162865-e132-4fcc-8c86-9ec0f4a9ee15.png)

### Scanning the vesicle



https://user-images.githubusercontent.com/9105574/189682675-854d2e14-6ab6-40f7-99ef-e69a94fbe377.mov





https://user-images.githubusercontent.com/9105574/189682694-2bbbf670-d336-482c-a140-54d2360c5d16.mov






## How to cite

     Thermoplasmonic induced vesicle fusion for investigating membrane protein phase affinity
   
     Guillermo Moreno-Pescador, Mohammad R. Arastoo, Salvatore Chiantia, Robert Daniels, Poul Martin Bendix
   
     bioRxiv 2022.09.19.508467; 
   
     doi: https://doi.org/10.1101/2022.09.19.508467

## To do

- Extend the functionality to automatically select several vesicles in the same image.
- Automatically close unnecessary intermidiate images
- Optimaze the code using more functions, avoiding redundant code
- Add the intensity fits to the final plot
- Make a more user friendly dialog box
- Extend it for more than just 8 bit images
- Include the Gauss line profile snipped for the anlysis of each different domain.

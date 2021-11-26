# Bruker Sequence : Self-gating BSSFP

This repository regroups the compiled sequence and matlab reconstruction of the SG-BSSFP sequence. This repository is still in **beta** don't hesitate to open a issue and share your comments.



Sequence principle is described in this MRM publication :  [![DOI](https://zenodo.org/badge/DOI/10.1002/jmri.24688.svg)](https://doi.org/10.1002/jmri.24688)

**Source code is available as a private [submodule](https://github.com/aTrotier/SEQ_BRUKER_A_MP2RAGE_CS_PUBLIC)** if you want the source code, send a request to : <aurelien.trotier@rmsb.u-bordeaux.fr>



## Plan

- [Bruker Sequence : MP2RAGE + Compressed Sensing acceleration](#bruker-sequence--mp2rage--compressed-sensing-acceleration)
  - [Folder structure](#folder-structure)
  - [Sequence installation](#sequence-installation)
  - [Acquisition](#acquisition)
  - [Recontruction](#recontruction)

## Folder structure

* **SEQUENCE** : Binary the sequence on Bruker scanner (PV6.0.1) + example of a protocol
* **RECO** : Matlab script for reconstruction
  * **functions** supporting functions

## Sequence installation

Sequence has been developped for Paravision **PV6.0.1**. Minor modification are required for PV6.0 compatibility (feel free to contact us)

**Installation step :**

* Copy the binary sequence under the folder
  `/opt/PV6.0.1/share/`

* To install : `File -> Import -> Binary Method ` and select the sequence in the share folder.


Sequence is now installed and available under the **Palette** tab/Explorer tab/Scan Programs & Protocols :

```
Object : AnyObject
Region : AnyRegion
Application : UserMethods
```

To use it drag and drop to an exam card.

## Acquisition

We will only described the SG-BSSFP specific parameters. The other ones are standard (Sequence is based on the Bruker FLASH sequence). The parameter name in the bruker card is in **bold**. In brackets are the corresponding names in the publication.

* ROUTINE tab


  * **Repetition** is necessary to fill the motion corrupted k-space lines (usually set at 4)

  * **OffSetFreq TrueFISP**  : need to modified for each acquisition in order to move the banding artifacts. If you want to move the artifacts on N images -> $$OffSetFreq = I*1/(N*TR)$$ with TR in seconds and I the indices of image.

  * **SGPoints** correspond to the number of SGPoints read (usually 5)

## Recontruction

**Requirements :**

* Matlab (tested on version > 2019b)

* Download the bruker dataset located in `/opt/PV6.0.1/data/{USER}/`

* Add to matlab path the folder and subfolder  **PAPER_SG-BSSFP/RECO/**

* Launch and edit the script : **main_script_SG_BSSP.m**

  * A popup window ask for the bruker datasets : select the multiple scan folders you want to reconstruct (it is a number)
  * A matlab object : **OBJ_SG_BSSFP_RECO** is created (here called **param_in**) which regroup the parameter that will be used for the SG reconstruction.
  * You can change the reconstruction parameter, for example :

  ```matlab
  param_in.NavCh=4;
  param_in.SGPoints=4;
  ```

  * To run the reconstruction pass the **OBJ_SG_BSSFP_RECO** to the function **reco_multi_SG_BSSFP**

  ```matlab
  s_out = reco_multi_SG_BSSFP(param_in);
  ```

  * If all goes right, multiples figures and question dialogs will popup :
    * 1st figure is the SGSignal + peak detection of the first offset (only this one is shown). A dialog window will ask you if the peak detection is ok. If not you can change the parameters in OBJ_SG_BSSFP_RECO (generally only the NavThreshold has to be modified)
    * 2nd figure is the SGSignal + windows that show the motion corrupted echoes that will be deleted during the reconstruction . A dialog window will ask you if the window selection is ok. If not you can change the parameters in OBJ_SG_BSSFP_RECO (RespWindowPos | RespWindowNeg)
   
  * The reconstruction data are stored in matlab structure (here called **s_out**) which include
    * **imSOS** : motion corrected image after sum of squares recombinaition of each offset frequency
    * **imCor** : Each offset frequency after motion correction
    * **s_in** : parameters used for the acquisition and reconstruction

  * **opti_CNR** : set 2 T1 tissues at the beginning of the script. It will determined what is the best parameters to choose to get the highest CNR. It takes into account the acquisition time (divide by sqrt(**MP2RAGE_TR**) and/or sqrt(**Echo train**))

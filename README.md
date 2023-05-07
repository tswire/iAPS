# iAPS with autoISF

## Introduction

iAPS - an artificial pancreas system for iOS based on [OpenAPS Reference](https://github.com/openaps/oref0) algorithms (Master 0.7.1) and Ivan Valkous stale Swift repo, freeaps.git.

Thousands of commits later, with many new and unique features added, the iOS app has been renamed to iAPS under a new organisation, Artificial Pancreas.

iAPS uses lot of frameworks published by the Loop community.

# autoISF
This branch includes autoISF to adjust ISF depending on 4 different effects in glucose behaviour that autoISF checks and reacts to:
* acce_ISF is a factor derived from acceleration of glucose levels
* bg_ISF is a factor derived from the deviation of glucose from target
* delta_ISF and pp_ISF are factors derived from glucose rise, 5min, 10min and 45min deltas and postprandial time frames
* dura_ISF is a factor derived from glucose being stuck at high levels

## AIMI B30
Another new feature is an enhanced EatingSoon TT on steroids. It is derived from AAPS AIMI branch and is called B30 (as in basal 30 minutes).
B30 enables an increased basal rate after an EatingSoon TT and a manual bolus. The theory is to saturate the infusion site slowly & consistently with insulin to increase insulin absorption for SMB's following a meal with no carb counting. This of course makes no sense for users striving to go Full Closed Loop (FCL) with autoISF. But for those of you like me, who cannot use Lyumjev or FIASP this is a feature that might speed up your normal insulin and help you to not care about carb counting, using some pre-meal insulin and let autoISF handle the rest.

To use it, it needs 2 conditions besides setting all preferences:
* Setting a TT with a specific adjustable target level.
* A bolus above a specified level, which results in a drastically increased Temp Basal Rate for a short time. If one cancels the TT, also the TBR will cease.

## Screen Shots

on iPhone 13 mini:

<img src="FAX_autoISF.png"
     alt="FreeAPS-X iPhone screen"
	 width=350
	 />
<img src="FAX_autoISF2.png"
     alt="FreeAPS-X iPhone screen2"
	 width=350
	 />

Apple Watch:

<img src="FAX_appleW1.png"
     alt="AppleWatch screen"
	 width=200
	 />
<img src="FAX_appleW2.png"
     alt="AppleWatch Bolus screen"
	 width=200
	 />
<img src="FAX_appleW3.png"
     alt="AppleWatch TempTarget screen"
	 width=200
	 />

## Install
To use this branch :

git clone --branch=dev-aisf_TDD https://github.com/mountrcg/iAPS.git

The autoISF branch includes my implementation of autoISF by ga-zelle and some other extra features. autoISF is off by default.

Please understand that this version is :
- highly experimental
- not approved for therapy

# Changes

Latest version of original iAPS is maintained by Jon and the gang. It brings significant improvements for Omnipod Dash pumps and Dexcom G6 and G7sensors, Statistics, Automations with Shortcuts, Garmin watch on such a lot of cool things that make you go Uuh. Looping should be immediate and robust.

[iAPS repo github](https://github.com/artificial-pancreas/iaps.git)


## autoISF Version
Refers to the changes done to the original oref0 used in FAX, the source can be found at my [oref0-repository](https://github.com/mountrcg/oref0/tree/dev_aisf_TDD)

* 2.2.8.3
	* AIMI B30 feature
	* dev release with current mods as of Mar 23, 2023
	* documentation at https://github.com/ga-zelle/autoISF

## Release
Refers to iAPS, which is currently mainly improved by Jon & Pierre at this [github repository](https://github.com/Artificial-Pancreas/iAPS)
I had to disable dynISF and Overrides from the original iAPS, as Jon does not publish the necessary oref code - you would have to use the original with those features.

* 1.6.0
	* Garmin watch
	* Automation
	* new Statistics page
* 1.2.1
	* Loop Framework 3.2
	* TempTarget changes for Slider & Rounding
* 1.1.1
	* ExerciseMode calculation with InsulinRatio Slider
	* Tag changes in Popup
	* display ratio from TempTargets in InfoPanel
* 1.1.0
	* Meal presets
	* oref fixes
	* G7 smoothing
* 1.09
	* Allow to delete Carbs when connexion with NS is impossible - Alert the user of the issue. (#606), Pierre Avous.
	* Put back DASH strings deleted in Loop3 branch
	* Reverts oref0 commit. Scott Leibrand. Revert "fix(lib/iob): Move value checks up to index.js". Fix for too high predictions.
	* Synchronise upload readings toggle in dexcom settings with FAX settings (#608), Pierre Avous.
	* LibreView
* 1.08
	* Fat Protein conversions
	* AppleHealth Integration, good for manual BG values
	* fixes MDT and G6
* 1.07
	* Dash & G7 frameworks from Loop3
	* CoreData refactoring

## Remarks
Due to the heavy refactoring and my changes to Jon's CoreData, when moving from a version (below 1.07) to (1.07 or above) it is advised to delete FAX and install with a new clone. All current stats will be gone and build up again. All settings will be at default values, like `maxIOB = 0`. Due to deleting FAX you should do it in between pods, as you loose this information. Now with iAPS starting v1.6 and autoISF 2.2.8.3 also all settings will revert to standard.

## Exercise Modes
Exercise Mode with high TT can be combined with autoISF. The Ratio from the TT, calculated with the Half Basal target, will be adjusted with the strongest (>1) or weakest (<1) ISF-Ratio from autoISF. This can be substantial. I myself prefer to disable autoISF adjustments while exercising, relying on the TT Ratio, by setting `Exercise toggles all autoISF adjustments off` to on.

# Documentation

Most of the changes are made in oref code of OpenAPS, which is part of FreeAPS-X. But it is not really readable in FAX, so refer to my [oref0-repository](https://github.com/mountrcg/oref0/tree/dev_aisf_TDD).

[Original autoISF implementation for AAPS](https://github.com/ga-zelle/autoISF)

[Discord autoISF - FreeAPS-X channel](https://discord.com/channels/953929437894803478/1025731124615458848)

[Discord iAPS - main branch channel](https://discord.com/channels/1020905149037813862/1021041588627062854)

[Crowdin Project for translation of iAPS](https://crowdin.com/project/freeaps-x)

[Middleware code for iAPS](https://github.com/Jon-b-m/middleware)

[iAPS repo github](https://github.com/artificial-pancreas/iaps.git)

[FreeAPS-X original github](https://github.com/ivalkou/freeaps)

[ADD DASH PUMP and SETTINGS](https://loopkit.github.io/loopdocs/loop-3/omnipod/)

[Overview & Onboarding Tips on Loop&Learn](https://www.loopandlearn.org/freeaps-x/)

[OpenAPS documentation](https://openaps.readthedocs.io/en/latest/)

[iAPS documentation (under development)](https://iaps.readthedocs.io/en/latest/)

Please understand that this version is:
- highly experimental and evolving rapidly.
- not CE approved for therapy.

# Pumps

- Omnipod EROS
- Omnipod DASH
- Medtronic 515 or 715 (any firmware)
- Medtronic 522 or 722 (any firmware)
- Medtronic 523 or 723 (firmware 2.4 or lower)
- Medtronic Worldwide Veo 554 or 754 (firmware 2.6A or lower)
- Medtronic Canadian/Australian Veo 554 or 754 (firmware 2.7A or lower)

# CGM Sensors

- Dexcom G5
- Dexcom G6
- Dexcom G7
- Libre 1
- Libre 2 (European)
- Medtronic Enlite
- Nightscout as CGM

# iPhone and iPod

iAPS app runs on iPhone or iPod. An iPhone 7 or newer is recommended.


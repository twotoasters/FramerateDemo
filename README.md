# FramerateDemo

## Goals

This sample app demonstrates perceptual differences from iOS's ideal 60 frames per second (fps) and other framerates of the user's choosing. The goal is to show that 45, 50 and even 55 fps are worse than we intuitively expect.

But besides just animation (output), the app also demonstrates differences in responsiveness (input-output). So it's important to run this app on a real iOS device and see how lower framerates feel worse under your fingers.

## Usage

You can pick a framerate using the stepper. When the table on the right is scrolled, the left side of the screen will be updated at the given framerate.

- Try 50 fps first. As you scroll the right side, you'll see the left side mostly keep up but it will feel stuttery.
- Try 58 fps. The left side keeps up almost correctly, but there are two skipped frames every second. Look for them.

## Grains of Salt

- The right side table is only *assumed* to scroll at 60 fps. This was reliable on my test device, an iPhone 5. If you're unsure, profile the app in Instruments.
- The left side of the screen is a snapshot view of the right side, so it appears one frame late at best. I'd like to eliminate this latency but I haven't thought of how. Set the framerate to 60 fps to see the effect it has.

## Discussion

iOS devices' screens blink at a rate of 60 Hz. That is, every 1/60 s, the screen's pixels blink. In a given blink, the screen can either show:

- a new frame, or
- the same frame as last time.

Every frame that iOS draws will appear on the screen, but not right away. A frame appears when the hardware refresh gets around to it. Consider one second worth of screen blinks.

At 60 fps, all 60 blinks show unique frames. This is the one and only reason that 60 fps is considered to be an ideal framerate. If the hardware refreshed at 75 Hz, we would want 75 fps.

At 50 fps, 50 blinks show new frames, but 10 blinks keep the same image as last time. Or to think of it in terms of frames, there are 50 frames, 40 of which are displayed for 1/60 s and 10 of which displayed for 1/30 s. None of them are displayed for 1/50 s!

60Hz - 50 fps = 10 stuttering, double-duration frames.

It is intuitive to think of 55 fps as about 10% smoother than 50 fps, because 10% more frames are shown. But because of hardware refresh timing, 55 fps has 5 stuttering frames compared to 50 fps's 10 stuttering frames, so it is *twice as smooth*.

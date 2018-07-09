# cautious-doodle

I have a number of Keyes KY-040 rotary encoders from aliexpress that have gone untested. Using my new 7 segment VHDL module I decided to use the encoder to inc/dec a counter and drive its current value out to the display. Look to the .ucf for pin assignments.

This project brings together all of my new VHDL modules I've been working on the last few days in a pretty meaningful and non-trivial way. The encoders are horribly noisy and demanded the use of a glitch filter.

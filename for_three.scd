/*
 ____|           __ __| |
 |    _ \   __|     |   __ \   __| _ \  _ \
 __| (   | |        |   | | | |    __/  __/
_|  \___/ _|       _|  _| |_|_|  \___|\___|  */

// three oscillator additive synthesis
// lizzie davis, 3 july 2014 @ ccrma sc workshop

// used for pieces "Exercise" + "For Three"
// (very good for low frequency additive synthesis)
// GUI modeled after bruno ruviaro's FM demo interface

// to launch, select all (cmd - a) and run (cmd - enter)
// :)

s.waitForBoot({

	var win, carrFreqKnob, volumeSlider, defaultFont, defaultColor, defaultAlpha, defaultStringColor, firstFreqSpec, firstFreqKnob, firstFreqLabel, firstFreqNum, secFreqSpec, secFreqKnob, secFreqLabel, secFreqNum, thirdFreqSpec, thirdFreqKnob, thirdFreqLabel, thirdFreqNum, synth1, synth2, synth3;

	defaultFont = Font("Monaco", 12, bold: false);
	defaultColor = Color.blue(1);
	defaultAlpha = 0.87;
	defaultStringColor = Color.white;

	// Main window
	Window.closeAll;
	FreqScope.new;
	win = Window.new("For Three: 3-O-AS", Rect(20, 400, 820, 280));
	win.onClose = {s.freeAll; Window.closeAll; "goodbye!".postln; "".postln};
	win.front;
	win.background = defaultColor;
	win.alpha = defaultAlpha;

	// First Frequency Knob
	firstFreqSpec = ControlSpec(
		minval: 5,
		maxval: 5000,
		warp: 'exp',
		step: 0,
		default: 40,
		units: " Hz");
	firstFreqKnob = Knob.new(win, Rect(20, 20, 200, 200))
	.action = {arg v;
		var freq = firstFreqSpec.map(v.value);
		firstFreqNum.string = freq.round;
		synth1.set(\freq, freq)};
	firstFreqKnob.value = firstFreqSpec.unmap(firstFreqSpec.default);
	firstFreqKnob.color = [Color.white, Color.red, Color.white, Color.red ];

	// First Frequency Number
	firstFreqNum = StaticText.new(win, Rect(80, 210, 80, 25));
	firstFreqNum.background = defaultColor;
	firstFreqNum.alpha = defaultAlpha;
	firstFreqNum.align = \center;
	firstFreqNum.string = firstFreqSpec.default;
	firstFreqNum.font = defaultFont;
	firstFreqNum.stringColor = defaultStringColor;

	// First Frequency Label
	firstFreqLabel = StaticText.new(win, Rect(20, 240, 200, 25));
	firstFreqLabel.string = "First Frequency";
	firstFreqLabel.align = \center;
	firstFreqLabel.font = defaultFont;
	firstFreqLabel.stringColor = defaultStringColor;

	// Second Frequency Knob
	secFreqSpec = ControlSpec(
		minval: 5,
		maxval: 5000,
		warp: 'exp',
		step: 0,
		default: 40,
		units: " Hz");
	secFreqKnob = Knob.new(win, Rect(260, 20, 200, 200))
	.action = {arg v;
		var freq = secFreqSpec.map(v.value);
		secFreqNum.string = freq.round;
		synth2.set(\freq, freq)};
	secFreqKnob.value = secFreqSpec.unmap(secFreqSpec.default);
	secFreqKnob.color = [Color.white, Color.red, Color.white, Color.red ];


	// Second Frequency Number
	secFreqNum = StaticText.new(win, Rect(320, 210, 80, 25));
	secFreqNum.background = defaultColor;
	secFreqNum.alpha = defaultAlpha;
	secFreqNum.align = \center;
	secFreqNum.string = secFreqSpec.default;
	secFreqNum.font = defaultFont;
	secFreqNum.stringColor = defaultStringColor;

	// Second Frequency Label
	secFreqLabel = StaticText.new(win, Rect(260, 240, 200, 25));
	secFreqLabel.string = "Second Frequency";
	secFreqLabel.align = \center;
	secFreqLabel.font = defaultFont;
	secFreqLabel.stringColor = defaultStringColor;

	// Third Frequency Knob
	thirdFreqSpec = ControlSpec(
		minval: 5,
		maxval: 5000,
		warp: 'exp',
		step: 0,
		default: 40,
		units: " Hz");
	thirdFreqKnob = Knob.new(win, Rect(500, 20, 200, 200))
	.action = {arg v;
		var freq = thirdFreqSpec.map(v.value);
		thirdFreqNum.string = freq.round;
		synth3.set(\freq, freq)};
	thirdFreqKnob.value = thirdFreqSpec.unmap(thirdFreqSpec.default);
	thirdFreqKnob.color = [Color.white, Color.red, Color.white, Color.red ];


	// Third Frequency Number
	thirdFreqNum = StaticText.new(win, Rect(560, 210, 80, 25));
	thirdFreqNum.background = defaultColor;
	thirdFreqNum.alpha = defaultAlpha;
	thirdFreqNum.align = \center;
	thirdFreqNum.string = thirdFreqSpec.default;
	thirdFreqNum.font = defaultFont;
	thirdFreqNum.stringColor = defaultStringColor;

	// Third Frequency Label
	thirdFreqLabel = StaticText.new(win,  Rect(500, 240, 200, 25));
	thirdFreqLabel.string = "Third Frequency";
	thirdFreqLabel.align = \center;
	thirdFreqLabel.font = defaultFont;
	thirdFreqLabel.stringColor = defaultStringColor;

	// Volume Slider
	volumeSlider = EZSlider(
		parent: win,
		bounds: Rect(730, 20, 70, 230),
		label: "::Volume::",
		controlSpec: ControlSpec(-40, 0, \lin, 0.1, -40, "dB"),
		action: {|ez|
			synth1.set(\mul, ez.value.dbamp/3);
			synth2.set(\mul, ez.value.dbamp/3);
			synth3.set(\mul, ez.value.dbamp/3)
		},
		labelWidth: 80,
		unitWidth: 30,
		layout: 'vert')
	.setColors(
		stringColor: defaultStringColor,
		sliderBackground: Color.white,
		kobColor: Color.blue,

		numNormalColor: Color.black)
	.font = Font("Monaco", 12, bold: false);

	volumeSlider.numberView.align = \center;
	volumeSlider.unitView.align = \center;

	{
		SynthDef("forOne", {|freq = 40, mul = 1, gate = 1|
			var bpf, saw, snd, env;
			env = EnvGen.kr(Env.adsr(0.25, 2, 0.4, 0.25), gate: gate, doneAction: 2);
			saw = SinOsc.ar(freq, mul: mul/2);
			snd = Saw.ar(freq, mul: mul/2);
			snd = snd + saw *LFPulse.kr(SinOsc.kr(222)) * env;
			Out.ar([0, 1], snd);
		}).add;

		s.sync;

		synth1 = Synth("forOne");
		synth2 = Synth("forOne");
		synth3 = Synth("forOne");

	}.fork;

	CmdPeriod.doOnce({win.close});
});
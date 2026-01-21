state("MeetYourMaker-Win64-Shipping")
{
	byte raid : 0x09931560, 0x0100F4;
	byte genmat : 0x095EB6B0, 0x0110, 0x50, 0x0440, 0x0568, 0xE8, 0x08, 0x08;
	byte escape: 0x096A07F0, 0x0230E8, 0x08;
	byte loading: 0x09931560, 0x010034;
}

startup
{
	settings.Add("reset_completed", true, "Auto-reset timer and save splits after completed runs");
	settings.Add("reset_times", false, "Reset splits history on level load");
	settings.Add("reset_splits", false, "Fully clear splits and reconfigure the appropriate stages on startup");

	refreshRate = 120; // not sure it makes a difference... might as well try

	vars.raidRunning = 0xE1;
	vars.raidPending = 0xB8;
	vars.raidNotLoaded = 0xDB;

	vars.genmatObtained = 0x07;

	vars.escapeSuccess = 0x05;

	vars.loadingYes = 0xBB;
	vars.loadingNo = 0xC4;
}

init
{
	if (settings["reset_splits"]) {
		timer.Run.Clear();
		timer.Run.Add(new Segment("Genmat"));
		timer.Run.Add(new Segment("Escape"));
	}
}

update
{
	// workaround to allow the reset event to fire: it will not if the timer is in 'Ended' state.
	if (settings.ResetEnabled && settings["reset_completed"] && timer.CurrentPhase == TimerPhase.Ended
		&& current.loading != old.loading && current.loading == vars.loadingNo) {
		timer.CurrentPhase = TimerPhase.Paused;
	}

	if (settings["reset_times"] && old.raid == vars.raidNotLoaded && current.raid == vars.raidPending) {
		timer.Run.ClearTimes();
	}

	return true;
}

split
{
	return current.raid == vars.raidRunning
		&& ((current.genmat != old.genmat && current.genmat == vars.genmatObtained)
			|| (current.escape != old.escape && current.escape == vars.escapeSuccess));
}

start
{
	return current.raid != old.raid && current.raid == vars.raidRunning;
}

reset
{
	return current.loading != old.loading;
}

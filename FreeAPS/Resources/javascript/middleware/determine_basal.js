function middleware(iob, currenttemp, glucose, profile, autosens, meal, reservoir, clock, pumphistory, preferences, basalprofile) {
    
    const disableAcce = 0;
    
    reason = "Nothing changed";
    
    var reasonAutoISF = "";
    
    const d = new Date();
    let currentHour = d.getHours();

    // disable acceISF during the night
    if (disableAcce == 1) {
        if (currentHour < 7 || currentHour > 22) {
             profile.enable_BG_acceleration = false;
             reasonAutoISF = "acceISF deactivated";
             reason = "";
            }
        }
    reason = reason + reasonAutoISF;
    
    // return any reason what has changed.
    return reason;
}


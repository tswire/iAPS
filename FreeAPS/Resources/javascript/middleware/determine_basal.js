function middleware(iob, currenttemp, glucose, profile, autosens, meal, reservoir, clock, pumphistory, preferences, basalprofile) {
    // modify anything
    // return any reason what has changed.
    
    const popup = 0;
    var reason = "message & whatever";
    
    
    
    if (popup == 1) {
        profile.mw_Reason = "Middleware:, " + reason + ", ";}
    else {profile.mw_Reason = ""}
    
    return reason;
}


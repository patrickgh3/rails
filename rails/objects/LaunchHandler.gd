
func hit_moving_launcher(launcher, maybe_player):
	if maybe_player is Cubio:
		var cubio = maybe_player as Cubio
		if cubio.velocity.length_squared() < launcher.velocity.length_squared():
			if not cubio.launched:
				cubio.hit_moving_launchbox(launcher)
					

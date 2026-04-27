unit class Selkie::UI::Base;

submethod TWEAK(|) {
	.push: self with @*UI-NODES
}

method auto-subscribe($method, &block) {
	with $*UI-APP.obj.store {
		for %*UI-PATHS.keys -> $path {
			.subscribe-path-callback(
				"{ $.obj.WHERE }-{ self.^name }-{ $method }-{ $path }",
				[ $path ],
				&block,
				$.obj
			)
		}
	}
	block self
}

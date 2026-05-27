use Selkie::UI;

App :run{ $*TEST.not }, {
	my UInt $val := new-state 0;
	VBox {
		Button.label({ $val ?? "BLE $val" !! "BLA $val" }).on-press: { ++$val }
	}
}



This is a fork of Klipper by Artillery made for use on the Sidewinder X4 Plus.
I'm not an Artillery employee, I just ported the changes shipped by Artillery
to the latest master. In the latest update from Artillery, their changes are
based on commit 3387a9c23d940c7d449f197b272616eda11a5e3d
from Sun Jul 24 08:49:25 2022 -0400

Changelog (made by me, not Artillery):

* `klippy/configfile.py`
    * After saving the config file, firmware and host Software is restarted,
      instead of just the host
* `klippy/extras/fan.py`
    * Adds a `max_power` and `value` to the status of fans
    * `max_power` just has the internal `max_power` value of that fan
    * `value` is the value was set last with `set_speed`. The difference to the
      `speed` value is, that `value` will return the last value that
      `set_speed` was called with, ignoring if the speed that was ultimately
      set was actually different (because of other factors like `off_below` or
      `max_power`).
    * Adds `HIGH_FAN_SPEED` and `LOW_FAN_SPEED` command. Those set a max speed of
      100% and 80% respectively, and scale the current fan speed down
      accordingly. I didn't like that approach, because setting the speed
      directly after using this would brake this scaling, so I made a change
      to the M106 command that will also apply this scaling. (No idea if
      this Artillery already accounted for this in their interface, but I
      care more about this behaving as expected when a scaling is applied.
      Maybe I'll take this out again if it acts strange 🤷)
* `klippy/extras/filament_switch_sensor.py`
    * Huge increase to the default `pause_delay` and `event_delay` for the Filament
        Runout Sensor from 0.5 to 10 and 3.0 to 30.0 respectively
* `klippy/extras/gcode_move.py`
    * Adds new `GET_GCODE_STATE` handler for `GCodeMove` and a new `MKS_GET_STATE`
      command. I'm not entirely sure what those do, but I'm guessing it reads
      stuff from `/home/mks/mks_plr/gcode_move/...` to sync the state of the mcu 
      and the rpi?
* `klippy/extras/heater_bed.py`
    * `respond_info` call when starting and finishing bed heating with M190.
      (Is `respond_info` just logging or does it do stuff?)
* `klippy/extras/probe.py`
    * Instead of stopping when Probe samples exceed `samples_tolerance`, just
      ignore it, stop probing, and calculate the average whith the values that
      are already there. (wtf?) I reverted that change and put it in a comment
      (Still need to test if that breaks stuff)
    * Adds `z-offset` to `get_status` of probes
    * Adds `MKS28` and `RESET_ZOFFSET` commands to the probing stuff
      MKS28 sems to be G28, but it compensates for the probe position/offset
      RESET_ZOFFSET sets the z-offset to 0 in the config file
* `klippy/extras/virtual_sdcard.py`
    * Adds `POC_PRINT_FILE` command ("Loads a SD file and resume the print.")
      Literally just `gcmd.respond_raw("POC")`. No idea what that does though 🤷
    * Adds `MKS_LOAD_FILE_POSITION` command. Reads some files under
      `/home/mks/mks_plr/...` and then does
        ```
        G28
        G90
        G1 X<X-POS> Y<Y-POS> Z<Z-POS> (values from mks_plr/gcode_move/position)
        M109 S<mks_plr/extruder/target>
        M190 S<mks_plr/heater_bed/target>
        ```
      And sets current `file_position` to a value from
      `mks_plr/virtual_sdcard/file_position`.

      Looks like a recovery routine for interrupted prints?
    * Adds `SDCARD_SELECT_FILE` command ("Select a SD file. May include files
      in subdirectories."). Does exactly the same as `SDCARD_PRINT_FILE`, but
      it just loads the file but then doesn't try to `do_resume` (print it)
      after. I refactored that part a bit. In the Artillery code, they
      literally copy&pasted `SDCARD_PRINT_FILE` and commented out the
      `self.do_resume()` at the end.
    * They also left a `# logging.info("%s", lines)` for debugging. I left them
      in case someone else wants to debug stuff...
* `klippy/gcode.py`
    * they commented out `self.gcode_handlers = self.base_gcode_handlers` in
      `_handleShutdown(self)`. I'm guessing they don't want their custom
      handlers to be cleared? I don't know where they are changing anything
      with the handlers that wouldn't also change it in the base handlers, so
      I commented it in again and kept the extra commented line in the file.
* `klippy/kinematics/extruder.py`
    * Adds `K109` as an alias to `M109`?
    * Adds `respond_info`s around M109 command to log when heating starts and
      finishes
    * I'm not sure why they not either just use `M109` instead of their custom
      `K109`. The change to the `M109` command suggests that they ALWAYS
      assume `M109` be called by the MKS anyway?
* `klippy/mcu.py`
    * Doubles `TRSYNC_TIMEOUT` from 0.025 to 0.05 (in seconds I guess)


Welcome to the Klipper project!

[![Klipper](docs/img/klipper-logo-small.png)](https://www.klipper3d.org/)

https://www.klipper3d.org/

Klipper is a 3d-Printer firmware. It combines the power of a general
purpose computer with one or more micro-controllers. See the
[features document](https://www.klipper3d.org/Features.html) for more
information on why you should use Klipper.

To begin using Klipper start by
[installing](https://www.klipper3d.org/Installation.html) it.

Klipper is Free Software. See the [license](COPYING) or read the
[documentation](https://www.klipper3d.org/Overview.html). We depend on
the generous support from our
[sponsors](https://www.klipper3d.org/Sponsors.html).

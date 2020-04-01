# Open and Shut

Type in Morse code by repeatedly slamming your laptop shut

[![output](https://user-images.githubusercontent.com/8890878/78181506-882c1a80-7432-11ea-89c0-bee00e9d183f.gif)](https://youtu.be/UAQ60P61vYw)

## Setup
### Dependencies
* [xdotool](http://manpages.ubuntu.com/manpages/trusty/man1/xdotool.1.html)
* [acpid](https://wiki.archlinux.org/index.php/Acpid)

### Installation
Clone this repository and copy files into `/etc/acpi`
```
git clone git@github.com:veggiedefender/open-and-shut.git
sudo cp morse_code_close.sh morse_code_open.sh morse_code_acpi.sh /etc/acpi/
```

### Configure acpid
Acpid needs to know how and when to run our scripts. Create a file `/etc/acpi/events/lm_lid` with the following contents:
```
event=button/lid.*
action=/etc/acpi/morse_code_acpi.sh
```

### Disable screen lock
**Temporarily:** Run `systemd-inhibit --what=handle-lid-switch cat` and press Ctrl+C when you're done.

**Permanently:** Add `HandleLidSwitch=ignore` to `/etc/systemd/logind.conf` and either run `sudo systemctl restart systemd-logind.service` (this will log you out), or reboot your computer.

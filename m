From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 08 Apr 2009 14:34:02 +0200
Subject: [PATCH] Udev integration: udev rules 1/3
Message-ID: <49DC99BA.8000205@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is the basic udev rule for DM. It creates nodes in /dev/mapper directory.
The permission for devices are defined here. This one is parsed as the first
one. If we detect LVM-* prefix in DM UUID, we skip the cookie notification,
because this is handled in another rule (similarly, we do this for other
subsystems, if we need to do more actions -- create more symlinks etc.)

(this rule should have the highest priority of all LVM/DM udev rules)

Peter


# udev rules for DM devices
# This will create nodes in /dev/mapper directory.

KERNEL=="device-mapper", NAME=="mapper/control"

SUBSYSTEM!="block", GOTO="dm_end"
KERNEL!="dm-[0-9]*", GOTO="dm_end"
ACTION!="change|remove", GOTO="dm_end"

# "dm" sysfs subdirectory is available in newer DM versions only.
# We have to check for its existence and use dmsetup tool instead
# to get the DM name and UUID if this subdirectory is not present.
ACTION=="change", TEST=="dm", ENV{DM_NAME}="$attr{dm/name}", ENV{DM_UUID}="$attr{dm/uuid}"
ACTION=="change", TEST!="dm", IMPORT{PROGRAM}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name"

# Default permissions for DM devices.
KERNEL=="dm-[0-9]*", OWNER="root", GROUP="root", MODE="0600"

# You can define your own permissions for DM devices here.
# ENV{DM_NAME}=="my_device", OWNER="peter", GROUP="peter", MODE="0644"


ACTION=="change", NAME="mapper/$env{DM_NAME}"

# We won't send notifications for known subsystems since
# these have their own dedicated rules and the notification
# will be done after they finish their own actions.
ENV{DM_UUID}=="LVM-?*", GOTO="dm_end"

ENV{COOKIE}=="[0-9]*", RUN+="/sbin/dmsetup notify $env{COOKIE}", OPTIONS+="last_rule"

LABEL="dm_end"



From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 23 Apr 2009 13:26:38 +0200
Subject: [PATCH] Udev integration: udev rules - another approach
Message-ID: <49F0506E.8050509@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I'm sending a prototype of the second approch for udev rules. These
are not final, just for discussion! The rules are separated in files now,
we separate the defintion of permissions and the place where we can register
DM subsystems. 

The rules create nodes in /dev/exp_mapper and /dev/exp dirs -- "experimental",
so I could see which ones are created by the devmapper and which ones by
udev itself. We still keep the old way of creating nodes if udev fails to
do so.

(Mind the priority of the rules given by its name/number.)

Any comments are welcome... Thanks.

Peter


These rules are supposed to be installed in /lib/udev dir:
==========================================================

10-dm-getname.rules:
--------------------
SUBSYSTEM!="block", GOTO="dm_end"
KERNEL!="dm-[0-9]*", GOTO="dm_end"
ACTION!="change|remove", GOTO="dm_end"

# "dm" sysfs subdirectory is available in kernels 2.6.29 and later.
# We have to check for its existence and use dmsetup tool instead
# to get the DM name and UUID if this subdirectory is not present.
# We use DM_NAME and DM_UUID in rules later.
ACTION=="change", TEST=="dm", ENV{DM_NAME}="$attr{dm/name}", ENV{DM_UUID}="$attr{dm/uuid}"
ACTION=="change", TEST!="dm", IMPORT{program}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid"

LABEL="dm_end"


12-dm.rules:
------------
KERNEL=="device-mapper", NAME="exp_mapper/control"

SUBSYSTEM!="block", GOTO="dm_end"
KERNEL!="dm-[0-9]*", GOTO="dm_end"
ACTION!="change|remove", GOTO="dm_end"

ACTION=="change", NAME="exp_mapper/$env{DM_NAME}"

# If any DM subsystem is registered, we don't do any notificatons here.
# It's the responsibility of the subsystem's rules to do this notification,
# so the waiting process is notified after all the required actions are done.
# We use the "last_rule" functionality, so we are sure that no other rule is
# processed afterwards.
ENV{DM_SUBSYS}=="?*", GOTO="dm_end"
ENV{DM_COOKIE}=="?*", RUN+="/sbin/dmsetup udevnotify $env{DM_COOKIE}", OPTIONS+="last_rule"

LABEL="dm_end"


13-lvm.rules:
-------------
SUBSYSTEM!="block", GOTO="lvm_end"
KERNEL!="dm-[0-9]*", GOTO="lvm_end"
ACTION!="change|remove", GOTO="lvm_end"
ENV{DM_SUBSYS}!="LVM", GOTO="lvm_end"

# lvmsplit command will be added to dmsetup later...
#ACTION=="change", IMPORT{program}="/sbin/dmsetup lvmsplit $env{DM_NAME} --nameprefixes --noheadings --rows"
# ...this is the same, but uses ioctls
ACTION=="change", TEST!="dm", IMPORT{program}="/sbin/dmsetup info $env{DM_NAME} -c --nameprefixes --noheadings --rows -o vg_name,lv_name,lv_layer"

# Do not create symlinks for hidden subdevices.
ENV{DM_LV_NAME}=="?*_mlog", GOTO="notify"
ENV{DM_LV_NAME}=="?*_mimage_[0-9]*", GOTO="notify"

# Create symlinks for top level devices only.
ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", ENV{DM_LV_LAYER}!="?*", SYMLINK+="exp/$env{DM_VG_NAME}/$env{DM_LV_NAME}"

LABEL="notify", ENV{DM_COOKIE}=="?*", RUN+="/sbin/dmsetup udevnotify $env{DM_COOKIE}", OPTIONS+="last_rule"

LABEL="lvm_end"


95-dm-fallback.rules:
---------------------
SUBSYSTEM!="block", GOTO="dm_end"
KERNEL!="dm-[0-9]*", GOTO="dm_end"
ACTION!="change|remove", GOTO="dm_end"

# Just in case there is any unsent notification.
ENV{DM_COOKIE}=="?*", RUN+="/sbin/dmsetup udevnotify $env{DM_COOKIE}", OPTIONS+="last_rule"

LABEL="dm_end"


These rules are supposed to be installed in /etc/udev dir:
==========================================================

11-dm-permissions.rules:
------------------------
SUBSYSTEM!="block", GOTO="dm_end"
KERNEL!="dm-[0-9]*", GOTO="dm_end"
ACTION!="change", GOTO="dm_end"

# Default permissions for DM devices.
KERNEL=="dm-[0-9]*", OWNER="root", GROUP="root", MODE="0600"

# You can define your own permissions for DM devices here.
# There are two environment variables set for you which you
# can use in your permission rules - DM_NAME and DM_UUID.
ENV{DM_NAME}=="my_device", OWNER:="peter", GROUP:="peter", MODE:="644"

LABEL="dm_end"


11-dm-subsystem.rules:
----------------------
SUBSYSTEM!="block", GOTO="dm_end"
KERNEL!="dm-[0-9]*", GOTO="dm_end"
ACTION!="change|remove", GOTO="dm_end"

# Every DM subsystem registers its own prefixes here.
# This is required so the notification is sent at right
# time and after the subsystem's udev rules are processed.
# We send the notification from the subsystem's rules then.
# (if we forget to do so, there is still a fallback rule
# that will send any residual notifications later)
ENV{DM_UUID}=="LVM-?*", ENV{DM_SUBSYS}="LVM"
ENV{DM_UUID}=="mpath-?*", ENV{DM_SUBSYS}="mpath"

LABEL="dm_end"


40-multipath.rules (these ones are already here in the system, but
I edited them a little):
------------------------------------------------------------------
# multipath wants the devmaps presented as meaninglful device names
# so name them after their devmap name
SUBSYSTEM!="block", GOTO="end_mpath"

RUN+="socket:/org/kernel/dm/multipath_event"

KERNEL!="dm-[0-9]*", GOTO="end_mpath"
ENV{DM_SUBSYS}!="mpath", GOTO="end_mpath"

ACTION=="add", PROGRAM!="/sbin/mpath_wait %M %m", GOTO="end_mpath"
ACTION=="add", RUN+="/sbin/dmsetup ls --target multipath --exec '/sbin/kpartx -a -p p' -j %M -m %m" 

LABEL="end_mpath"



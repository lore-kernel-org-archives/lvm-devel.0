From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 08 Apr 2009 14:35:35 +0200
Subject: [PATCH] Udev integration: udev rules 2/3
Message-ID: <49DC9A17.9010705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This one is for LVM -- to create symlinks under /dev directory.
That's all :)

# udev rules for LVM 
# This will create LVM symlinks in /dev directory.

SUBSYSTEM!="block", GOTO="lvm_end"
KERNEL!="dm-[0-9]*", GOTO="lvm_end"
ACTION!="change|remove", GOTO="lvm_end"

ACTION=="change", IMPORT{PROGRAM}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,subsystem,vg_name,lv_name,lv_layer"
ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"

# Do not create symlinks for hidden subdevices.
ENV{DM_LV_NAME}=="?*_mlog", GOTO="notify"
ENV{DM_LV_NAME}=="?*_mimage_[0-9]*", GOTO="notify"

# Create symlinks for top level devices only.
ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", ENV{DM_LV_LAYER}!="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}"

LABEL="notify", ENV{COOKIE}=="[0-9]*", RUN+="/sbin/dmsetup notify $env{COOKIE}", OPTIONS+="last_rule"

LABEL="lvm_end"



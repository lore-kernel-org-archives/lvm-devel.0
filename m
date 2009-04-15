From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 15 Apr 2009 19:12:53 +0100
Subject: [PATCH] Udev integration: udev rules 2/3
In-Reply-To: <49DC9A17.9010705@redhat.com>
References: <49DC9A17.9010705@redhat.com>
Message-ID: <20090415181253.GK7843@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 08, 2009 at 02:35:35PM +0200, Peter Rajnoha wrote:
> # udev rules for LVM 
> # This will create LVM symlinks in /dev directory.
 
Again, describe in more detail what the script is doing.
Needs (C) notices too.

> SUBSYSTEM!="block", GOTO="lvm_end"
> KERNEL!="dm-[0-9]*", GOTO="lvm_end"
> ACTION!="change|remove", GOTO="lvm_end"
> 
> ACTION=="change", IMPORT{PROGRAM}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,subsystem,vg_name,lv_name,lv_layer"

If we already have the name (e.g. from sysfs), I think we talked about adding
a 'split up this name' command to dmsetup which does not perform any ioctls.

> ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"

Seems to be some repetition here.  Does udev support including files inline
within other files?
 
> # Do not create symlinks for hidden subdevices.
> ENV{DM_LV_NAME}=="?*_mlog", GOTO="notify"
> ENV{DM_LV_NAME}=="?*_mimage_[0-9]*", GOTO="notify"

I think the rule was based on lv_layer: if it exists, don't create symlink, otherwise do.
- Don't think mirrors need to be singled out, do they?
 
Alasdair
-- 
agk at redhat.com



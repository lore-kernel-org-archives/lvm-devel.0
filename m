From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Feb 2011 21:39:15 -0000
Subject: LVM2/scripts lvmdump.sh
Message-ID: <20110201213915.29342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2011-02-01 21:39:15

Modified files:
	scripts        : lvmdump.sh 

Log message:
	Add "dmsetup ls --tree" output to lvmdump.
	
	It would be most useful to add "dmsetup ls --tree" to the commands run.
	This command helps in answering the question "which devices are actually
	underneath a given LV?"
	
	Although the info is available with other existing dmsetup commands,
	adding this command gives a much clearer summary of complex setups.
	
	Here's an example of an LVM mirror, with mirror images on partitions
	created on top of multipath devices.  The multipath devices are on
	simple block devices.  As you can see, it is easy to see the stacking
	from the "dmsetup ls --tree" output:
	
	vgmpathtest-lvmpathmir (253:14)
	??????vgmpathtest-lvmpathmir_mimage_1 (253:13)
	???  ??????mpath5p1 (253:5)
	???     ??????mpath5 (253:2)
	???        ?????? (8:16)
	???        ?????? (8:0)
	??????vgmpathtest-lvmpathmir_mimage_0 (253:12)
	???  ??????mpath6p1 (253:6)
	???     ??????mpath6 (253:3)
	???        ?????? (8:48)
	???        ?????? (8:32)
	??????vgmpathtest-lvmpathmir_mlog (253:11)
	??????mpath7 (253:4)
	?????? (8:80)
	?????? (8:64)
	VolGroup00-LogVol01 (253:1)
	?????? (202:2)
	vgtest-lvmir (253:10)
	??????vgtest-lvmir_mimage_1 (253:9)
	???  ?????? (7:1)
	??????vgtest-lvmir_mimage_0 (253:8)
	???  ?????? (7:0)
	??????vgtest-lvmir_mlog (253:7)
	?????? (7:3)
	VolGroup00-LogVol00 (253:0)
	?????? (202:2)
	
	But it is much harder to see the stacking with only the commands today
	("dmsetup info", "dmsetup status", and "dmsetup table").  We could
	piece together the stacking from "dmsetup table" but it requires
	further processing (take output from "dmsetup info to get
	map name to major/minor, then parse "dmsetup table", etc).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmdump.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/scripts/lvmdump.sh	2010/04/14 20:03:46	1.15
+++ LVM2/scripts/lvmdump.sh	2011/02/01 21:39:15	1.16
@@ -183,6 +183,7 @@
 log "\"$DMSETUP\" info -c > \"$dir/dmsetup_info\" 2>> \"$log\""
 log "\"$DMSETUP\" table > \"$dir/dmsetup_table\" 2>> \"$log\""
 log "\"$DMSETUP\" status > \"$dir/dmsetup_status\" 2>> \"$log\""
+log "\"$DMSETUP\" ls --tree > \"$dir/dmsetup_ls_tree\" 2>> \"$log\""
 
 myecho "Gathering process info..."
 log "$PS alx > \"$dir/ps_info\" 2>> \"$log\""



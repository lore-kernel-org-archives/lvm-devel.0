From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 24 Jul 2012 23:26:31 -0500
Subject: [PATCH] Allow 'vgextend' when PVs are missing?
Message-ID: <1343190391.11083.8.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There seems to be a catch-22 when trying to solve the problem of a
failed device in a RAID LV when there are currently no spares in the VG.
The problem is articulated here:
https://www.redhat.com/archives/linux-lvm/2012-July/msg00018.html

In summary, if a 3-device RAID5 array was created in a 3-PV volume group
and one device goes bad, there is no way to fix it.  Normally, a spare
from the VG could be used to restore the missing PV and fix the RAID LV.
If there is no spare, one must be added before the RAID LV can be
repaired.  You cannot add a spare while the VG is missing PVs.

I propose that we should not forbid the addition of PVs while the VG is
missing PVs.  This solves the catch-22:
[root at hayes-01 lvm2]# lvconvert --repair vg/lv -y
  Couldn't find device with uuid NTkGoo-0OrB-4n75-F4RJ-stXm-4ydi-z0uPXD.
  Insufficient suitable allocatable extents for logical volume : 129 more required
  Failed to allocate replacement images for vg/lv
  Failed to replace faulty devices in vg/lv.
[root at hayes-01 lvm2]# vgextend vg /dev/loop3
  Couldn't find device with uuid NTkGoo-0OrB-4n75-F4RJ-stXm-4ydi-z0uPXD.
  Volume group "vg" successfully extended
[root at hayes-01 lvm2]# lvconvert --repair vg/lv -y
  Couldn't find device with uuid NTkGoo-0OrB-4n75-F4RJ-stXm-4ydi-z0uPXD.
  Faulty devices in vg/lv successfully replaced.

Thoughts,
 brassow

Index: lvm2/tools/vgextend.c
===================================================================
--- lvm2.orig/tools/vgextend.c
+++ lvm2/tools/vgextend.c
@@ -66,8 +66,13 @@ int vgextend(struct cmd_context *cmd, in
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, restoremissing_ARG))
-		cmd->handles_missing_pvs = 1;
+	/*
+	 * It is always ok to add new PVs to a VG - even if there are
+	 * missing PVs.  No LVs are affected by this operation, but
+	 * repair processes - particularly for RAID segtypes - can
+	 * be facilitated.
+	 */
+	cmd->handles_missing_pvs = 1;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);




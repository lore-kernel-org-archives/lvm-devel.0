From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 26 Jul 2012 22:12:21 +0000 (UTC)
Subject: master - vgextend: Allow PVs to be added to VGs that have PVs missing
Message-ID: <20120726221221.9AE7B3166@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=186a2772e8ac3c2088bdfc833c32d773464d666b
Commit:        186a2772e8ac3c2088bdfc833c32d773464d666b
Parent:        45db25817ff342a86b2ddf000b4b3a4d59be8848
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Jul 26 17:06:06 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Jul 26 17:06:06 2012 -0500

vgextend:  Allow PVs to be added to VGs that have PVs missing

Allowing people to add devices to a VG that has PVs missing helps
people avoid the inability to repair RAID LVs in certain cases.
For example, if a user creates a RAID 4/5/6 LV using all of the
available devices in a VG, there will be no spare devices to
repair the LV with if a device should fail.  Further, because the
VG is missing a device, new devices cannot be added to allow the
repair.  If 'vgreduce --removemissing' were attempted, the
"MISSING" PV could not be removed without also destroying the RAID
LV.

Allowing vgextend to operate solves the circular dependency.

When the PV is added by a vgextend operation, the sequence number is
incremented and the 'MISSING' flag is put on the PVs which are missing.
---
 WHATS_NEW        |    1 +
 tools/vgextend.c |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 735bdba..32ebf15 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Allow vgextend to add PVs to a VG that is missing PVs.
   Recognise Micron PCIe SSDs in filter and move array out to device-types.h.
   Fix segfault when attempting to replace RAID 4/5/6 device (2.02.97).
   Fix dumpconfig <node> to print only <node> without its siblings (2.02.89).
diff --git a/tools/vgextend.c b/tools/vgextend.c
index d1adf21..161796c 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -66,8 +66,13 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
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



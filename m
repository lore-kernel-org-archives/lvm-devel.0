From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 22 Sep 2017 13:35:57 -0400
Subject: master - vgsplit: Fix intermediate metadata corruption.
Message-ID: <201709221735.v8MHZvSf010533@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8146548d25e9104f0d530d943290d448c1994c0a
Commit:        8146548d25e9104f0d530d943290d448c1994c0a
Parent:        b0f4e0fcec1a50b73fbc4f05bfd2d385895bc3bc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Sep 22 18:02:58 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Sep 22 18:34:34 2017 +0100

vgsplit: Fix intermediate metadata corruption.

Changing the VG of a PV uses the same on-disk mechanism as vgrename.
This relies on recognising both the old and new VG names.  Prior to this
patch the vgsplit code incorrectly provided the new VG name twice
instead of the old and new ones.  This lead the low-level mechanism not
to recognise the device as already belonging to a VG and so paying no
attention to the location of its existing metadata, sometimes partly
overwriting it and then later trying to read the corrupt metadata and
issuing a checksum error.
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |    5 +++--
 tools/vgsplit.c               |    3 +++
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6b88fc4..b2037a6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.175 - 
 ======================================
+  Fix metadata corruption in vgsplit intermediate state.
   Require LV name with pvmove in a shared VG.
   Allow shared active mirror LVs with lvmlockd, dlm, and cmirrord.
   Support lvconvert --repair with cache and cachepool volumes.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e974f05..c359c8a 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -448,8 +448,9 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
 
-	log_debug_metadata("Volume group name found in metadata does "
-			   "not match expected name %s.", vgname);
+	log_debug_metadata("Volume group name found in metadata on %s at %" PRIu64 " does "
+			   "not match expected name %s.", 
+			   dev_name(dev_area->dev), dev_area->start + rlocn->offset, vgname);
 
       bad:
 	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, dev_area->dev, 0)) &&
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index da9b7b1..843738b 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -705,6 +705,9 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!vg_rename(cmd, vg_to, vg_name_to))
 		goto_bad;
 
+	/* Set old VG name so the metadata operations recognise that the PVs are in an existing VG */
+	vg_to->old_name = vg_from->name;
+
 	/* store it on disks */
 	log_verbose("Writing out updated volume groups");
 



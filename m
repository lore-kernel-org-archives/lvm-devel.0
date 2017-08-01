From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 06:01:07 -0400
Subject: master - thin: warn about too big chunks size
Message-ID: <201708011001.v71A17aV011184@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8256170e6a2dbed15b790e75f5d1026e3de69a16
Commit:        8256170e6a2dbed15b790e75f5d1026e3de69a16
Parent:        3654f478e1beab950f9ee91bc2fd759d22552e1c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 21 20:58:33 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 11:52:27 2017 +0200

thin: warn about too big chunks size

lvm2 warned about zeroing and too big chunksize (>=512KiB), but
only during lvconvert, so lvcreate was creating thin-pools
without any warning about possible slowness of thin provisioning
because of zeroing.
---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |   13 ++++++++++++-
 tools/lvconvert.c         |    5 -----
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 20da268..41ddda7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Add warning when creating thin-pool with zeroing and chunk size >= 512KiB.
   Introduce exit code 4 EINIT_FAILED to replace -1 when initialisation fails.
   Add synchronization points with udev during reshape of raid LVs.
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 88dc51a..bd2d2c3 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -752,8 +752,19 @@ int update_thin_pool_params(struct cmd_context *cmd,
 	    !set_pool_discards(discards, DEFAULT_THIN_POOL_DISCARDS))
 		return_0;
 
-	if (*zero_new_blocks == THIN_ZERO_UNSELECTED)
+	if (*zero_new_blocks == THIN_ZERO_UNSELECTED) {
 		*zero_new_blocks = (DEFAULT_THIN_POOL_ZERO) ? THIN_ZERO_YES : THIN_ZERO_NO;
+		log_verbose("%s pool zeroing on default.", (*zero_new_blocks == THIN_ZERO_YES) ?
+			    "Enabling" : "Disabling");
+	}
+
+	if ((*zero_new_blocks == THIN_ZERO_YES) &&
+	    (*chunk_size >= DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2)) {
+		log_warn("WARNING: Pool zeroing and %s large chunk size slows down thin provisioning.",
+			 display_size(cmd, *chunk_size));
+		log_warn("WARNING: Consider disabling zeroing (-Zn) or using smaller chunk size (<%s).",
+			 display_size(cmd, DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2));
+	}
 
 	log_verbose("Preferred pool metadata size %s.",
 		    display_size(cmd, (uint64_t)*pool_metadata_extents * extent_size));
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d90e675..94dee9d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3088,11 +3088,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	if (!vg_write(vg) || !vg_commit(vg))
 		goto_bad;
 
-	if ((seg->zero_new_blocks == THIN_ZERO_YES) &&
-	    seg->chunk_size >= DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2)
-		log_warn("WARNING: Pool zeroing and large %s chunk size slows down provisioning.",
-			 display_size(cmd, seg->chunk_size));
-
 	if (activate_pool && !lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
 		log_error("Failed to lock pool LV %s.", display_lvname(pool_lv));
 		goto out;



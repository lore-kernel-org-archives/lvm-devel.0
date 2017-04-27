From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 26 Apr 2017 21:49:49 -0400
Subject: master - pvresize: Prompt when non-default size supplied.
Message-ID: <201704270149.v3R1nnbP004566@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cbc69f8c693edf0d1307c9447e2e66d07a04bfe9
Commit:        cbc69f8c693edf0d1307c9447e2e66d07a04bfe9
Parent:        78a0b4a08a7178250b9d0b3be7f975440975d9d4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 27 02:36:34 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 27 02:36:34 2017 +0100

pvresize: Prompt when non-default size supplied.

Seek confirmation before changing the PV size to one that differs
from the underlying block device.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/pv_manip.c          |   30 +++++++++++++++++++++++-------
 liblvm/lvm_pv.c                  |    2 +-
 tools/pvresize.c                 |    2 +-
 5 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index efcddd5..f8efd87 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.171 - 
 ==================================
+  Adjust pvresize messages and add prompt if underlying dev size differs.
   lvconvert - preserve region size on raid1 image count changes
   raid - sanely handle insufficient space on takeover
   Fix configure --enable-notify-dbus status message.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8e03e20..8b4310b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -748,7 +748,8 @@ int pvremove_many(struct cmd_context *cmd, struct dm_list *pv_names,
 int pv_resize_single(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     struct physical_volume *pv,
-			     const uint64_t new_size);
+			     const uint64_t new_size,
+			     int yes);
 
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	       uint64_t label_sector);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 5689a11..6ee4828 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -604,7 +604,7 @@ static int pv_resize(struct physical_volume *pv,
 
 		log_verbose("Resizing physical volume %s from %" PRIu32
 			    " to %" PRIu32 " extents.",
-			    pv_dev_name(pv), pv->pe_count, new_pe_count);
+			    pv_dev_name(pv), old_pe_count, new_pe_count);
 
 		if (new_pe_count > old_pe_count)
 			return _extend_pv(pv, vg, old_pe_count, new_pe_count);
@@ -618,7 +618,8 @@ static int pv_resize(struct physical_volume *pv,
 int pv_resize_single(struct cmd_context *cmd,
 		     struct volume_group *vg,
 		     struct physical_volume *pv,
-		     const uint64_t new_size)
+		     const uint64_t new_size,
+		     int yes)
 {
 	uint64_t size = 0;
 	int r = 0;
@@ -642,11 +643,26 @@ int pv_resize_single(struct cmd_context *cmd,
 	}
 
 	if (new_size) {
-		if (new_size > size)
-			log_warn("WARNING: %s: Overriding real size. "
-				  "You could lose data.", pv_name);
-		log_verbose("%s: Pretending size is %" PRIu64 " not %" PRIu64
-			    " sectors.", pv_name, new_size, pv_size(pv));
+		if (new_size > size) {
+			log_warn("WARNING: %s: Overriding real size %s. You could lose data.",
+				 pv_name, display_size(cmd, (uint64_t) size));
+			if (!yes && yes_no_prompt("%s: Requested size %s exceeds real size %s. Proceed?  [y/n]: ",
+						  pv_name, display_size(cmd, (uint64_t) new_size),
+						  display_size(cmd, (uint64_t) size)) == 'n')
+				goto_out;
+
+		}  else if (new_size < size)
+			if (!yes && yes_no_prompt("%s: Requested size %s is less than real size %s. Proceed?  [y/n]: ",
+						  pv_name, display_size(cmd, (uint64_t) new_size),
+						  display_size(cmd, (uint64_t) size)) == 'n')
+				goto_out;
+
+		if (new_size == size)
+			log_verbose("%s: Size is already %s (%" PRIu64 " sectors).",
+				    pv_name, display_size(cmd, (uint64_t) new_size), new_size);
+		else
+			log_warn("WARNING: %s: Pretending size is %" PRIu64 " not %" PRIu64 " sectors.",
+				 pv_name, new_size, size);
 		size = new_size;
 	}
 
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 3dd8433..26e3cf1 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -312,7 +312,7 @@ static int _lvm_pv_resize(const pv_t pv, uint64_t new_size)
 	if (!vg_check_write_mode(pv->vg))
 		return -1;
 
-	if (!pv_resize_single(pv->vg->cmd, pv->vg, pv, size)) {
+	if (!pv_resize_single(pv->vg->cmd, pv->vg, pv, size, 1)) {
 		log_error("PV re-size failed!");
 		return -1;
 	}
diff --git a/tools/pvresize.c b/tools/pvresize.c
index ddff520..1de1709 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -52,7 +52,7 @@ static int _pvresize_single(struct cmd_context *cmd,
 		cmd->lockd_gl_disable = 1;
 	}
 
-	if (!pv_resize_single(cmd, vg, pv, params->new_size))
+	if (!pv_resize_single(cmd, vg, pv, params->new_size, arg_is_set(cmd, yes_ARG)))
 		return_ECMD_FAILED;
 
 	params->done++;



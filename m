From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jul 2021 13:57:19 +0000 (GMT)
Subject: main - vgsplit: add support for option --poolmetadataspare
Message-ID: <20210721135719.AACA23858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2132fdc11f7bc285638765e001bef6a3e595b286
Commit:        2132fdc11f7bc285638765e001bef6a3e595b286
Parent:        5042463c5083cc71546297344058bd0fa523aa5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 20 22:33:05 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 21 15:56:33 2021 +0200

vgsplit: add support for option --poolmetadataspare

When splitting VG with thin/cache pool volume, handle pmspare during
such split and allocate new pmspare in new VG or extend existing pmspare
there and eventually drop  pmspare in original VG if is no longer needed
there.
---
 WHATS_NEW                 |  1 +
 lib/metadata/pool_manip.c | 11 +++++++++++
 man/vgsplit.8_pregen      |  9 +++++++++
 tools/command-lines.in    |  2 +-
 tools/vgsplit.c           |  8 ++++++++
 5 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b06071c42..83d780029 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.13 - 
 ===============================
+  Support --poolmetadataspare with vgsplit.
   Fix detection of active components of external origin volume.
   Add vdoimport tool to support conversion of VDO volumes.
   Support configurable allocation/vdo_pool_header_size.
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 9ceec3a7e..e451e92ae 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -722,6 +722,17 @@ int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
 		return 1;
 	}
 
+	if (!extents) {
+		/* pmspare is not needed */
+		if (lv) {
+			log_debug_metadata("Dropping unused pool metadata spare LV %s.",
+					   display_lvname(lv));
+			if (!lv_remove_single(vg->cmd, lv, DONT_PROMPT, 0))
+				return_0;
+		}
+		return 1;
+	}
+
 	if (extents > MAX_SIZE)
 		extents = MAX_SIZE;
 
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 331c6e491..8a0ae597e 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -70,6 +70,8 @@ Common options for command:
 .hy
 ]
 .br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+.br
 [    \fB--\fP[\fBvg\fP]\fBmetadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP ]
 .ad b
 .RE
@@ -235,6 +237,13 @@ Move only PVs used by the named LV.
 Disable locking.
 .
 .HP
+\fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
+.br
+Enable or disable the automatic creation and management of a
+spare pool metadata LV in the VG. A spare metadata LV is reserved
+space that can be used when repairing a pool.
+.
+.HP
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 8607305cb..a4785b38a 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1912,7 +1912,7 @@ ID: vgscan_general
 
 ---
 
-OO_VGSPLIT: --autobackup Bool
+OO_VGSPLIT: --autobackup Bool, --poolmetadataspare Bool
 
 # used only when the destination VG is new
 OO_VGSPLIT_NEW: --alloc Alloc,
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 296248e7c..a085ac2ba 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -525,6 +525,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	int existing_vg = 0;
 	int r = ECMD_FAILED;
 	const char *lv_name;
+	int poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE);
 
 	if ((arg_is_set(cmd, name_ARG) + argc) < 3) {
 		log_error("Existing VG, new VG and either physical volumes "
@@ -699,6 +700,13 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	vg_to->status |= EXPORTED_VG;
 
+
+	if (!handle_pool_metadata_spare(vg_to, 0, &vg_to->pvs, poolmetadataspare))
+		goto_bad;
+
+	if (!handle_pool_metadata_spare(vg_from, 0, &vg_from->pvs, poolmetadataspare))
+		goto_bad;
+
 	if (!archive(vg_to))
 		goto_bad;
 



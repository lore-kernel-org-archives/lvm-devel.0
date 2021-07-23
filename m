From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jul 2021 14:38:20 +0000 (GMT)
Subject: main - vgmerge: support option --poolmetadataspare
Message-ID: <20210723143820.7D23D3853836@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b856476e96777842ea6c9b42654c369a6b22db4
Commit:        4b856476e96777842ea6c9b42654c369a6b22db4
Parent:        9cbc9e8296752df35626a9b50de1cb551ff5e99e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 23 16:32:35 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 23 16:36:31 2021 +0200

vgmerge: support option --poolmetadataspare

---
 WHATS_NEW              | 2 +-
 man/vgmerge.8_pregen   | 9 +++++++++
 tools/command-lines.in | 2 +-
 tools/vgmerge.c        | 6 ++++++
 4 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 83d780029..4fcd9f3c5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.03.13 - 
 ===============================
-  Support --poolmetadataspare with vgsplit.
+  Support --poolmetadataspare with vgsplit and vgmerge.
   Fix detection of active components of external origin volume.
   Add vdoimport tool to support conversion of VDO volumes.
   Support configurable allocation/vdo_pool_header_size.
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index 1264bb565..e2292182a 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -27,6 +27,8 @@ of both VGs fit into the destination VG's limits.
 .br
 [ \fB-l\fP|\fB--list\fP ]
 .br
+[    \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -147,6 +149,13 @@ Display long help text.
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
index a4785b38a..0bc5a4989 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1847,7 +1847,7 @@ DESC: Add devices from all accessible VGs to the devices file.
 ---
 
 vgmerge VG VG
-OO: --autobackup Bool, --list
+OO: --autobackup Bool, --list, --poolmetadataspare Bool
 ID: vgmerge_general
 
 ---
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 884ad4b8d..08615cd62 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -64,6 +64,8 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	struct lv_list *lvl1, *lvl2;
 	int r = ECMD_FAILED;
 	int lock_vg_from_first = 0;
+	struct logical_volume *lv;
+	int poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE);
 
 	if (!strcmp(vg_name_to, vg_name_from)) {
 		log_error("Duplicate volume group name \"%s\"", vg_name_from);
@@ -185,6 +187,10 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	/* Flag up that some PVs have moved from another VG */
 	vg_to->old_name = vg_from->name;
 
+        /* Check whether size of pmspare is big enough now for merged VG */
+	if (!handle_pool_metadata_spare(vg_to, 0, &vg_to->pvs, poolmetadataspare))
+		goto_bad;
+
 	/* store it on disks */
 	log_verbose("Writing out updated volume group");
 	if (!vg_write(vg_to) || !vg_commit(vg_to))



From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 26 Jan 2009 14:38:57 -0500
Subject: [PATCH] Create backup_changed_vg() liblvm function to avoid clvmd needing vg_read().
Message-ID: <1232998737-12426-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Should be no functional change and should apply cleanly on Petr's patch
13 from 1/22/09:
Date:   Thu Jan 22 11:10:09 2009 +0100
    Remove now-unused vg_lock_and_read.

Move guts of lvm_do_backup() function in clvmd into the library.
This allows us to avoid having clvmd to require linking against
vg_read() symbol.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |   15 +++------------
 lib/format_text/archiver.c    |   17 +++++++++++++++++
 lib/format_text/archiver.h    |    2 ++
 3 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 5cf7eff..b377400 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -706,19 +706,10 @@ void init_lvhash()
 /* Backups up the LVM metadata if it's changed */
 void lvm_do_backup(const char *vgname)
 {
-	struct volume_group * vg;
-	int consistent = 0;
+	DEBUGLOG("Triggering backup of VG metadata for %s. suspended=%d\n",
+		 vgname, suspended);
 
-	DEBUGLOG("Triggering backup of VG metadata for %s. suspended=%d\n", vgname, suspended);
-
-	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, &consistent);
-	if (vg) {
-		if (consistent)
-			check_current_backup(vg);
-	}
-	else {
-		log_error("Error backing up metadata, can't find VG for group %s", vgname);
-	}
+	backup_changed_vg(cmd, vgname);
 }
 
 /* Called to initialise the LVM context of the daemon */
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 9234e2e..8afc0a0 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -414,3 +414,20 @@ void check_current_backup(struct volume_group *vg)
 	archive(vg);
 	backup(vg);
 }
+
+/* Backups up the LVM metadata if it's changed */
+void backup_changed_vg(struct cmd_context *cmd, const char *vgname)
+{
+	struct volume_group * vg;
+	int consistent = 0;
+
+	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, &consistent);
+	if (vg) {
+		if (consistent)
+			check_current_backup(vg);
+	}
+	else {
+		log_error("Error backing up metadata, can't find VG for group %s", vgname);
+	}
+}
+
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index eb58ae9..1ac33ac 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -59,4 +59,6 @@ int backup_to_file(const char *file, const char *desc, struct volume_group *vg);
 
 void check_current_backup(struct volume_group *vg);
 
+void backup_changed_vg(struct cmd_context *cmd, const char *vgname);
+
 #endif
-- 
1.5.5.1



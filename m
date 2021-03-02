From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:32 +0000 (GMT)
Subject: main - lvremove: backup at the end of loop
Message-ID: <20210302215832.8063C3851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eb1160ee4230e6f37707b19eb5b46d2446257500
Commit:        eb1160ee4230e6f37707b19eb5b46d2446257500
Parent:        fa64c51428ca20e860bbe21338d916329b8aaf25
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 26 01:01:29 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

lvremove: backup at the end of loop

Taking backup with each removed LV is slowing down the process
considerable and is largerly uneeded. We are supposed to take
backup only on significant points and making sure the backup
is correct when the command is finished.

TODO: check how many other commands can be improved.
---
 lib/format_text/archiver.c | 2 ++
 lib/metadata/lv_manip.c    | 2 +-
 lib/metadata/vg.h          | 1 +
 tools/toollib.c            | 3 +++
 4 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 07e9b04e4..cb8fc07de 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -267,6 +267,8 @@ int backup_locally(struct volume_group *vg)
 
 int backup(struct volume_group *vg)
 {
+	vg->needs_backup = 0;
+
 	/* Unlock memory if possible */
 	memlock_unlock(vg->cmd);
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9bcab7477..4ac95063c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6780,7 +6780,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 					display_lvname(pool_lv));
 	}
 
-	backup(vg);
+	vg->needs_backup = 1;
 
 	lockd_lv(cmd, lock_lv, "un", LDLV_PERSISTENT);
 	lockd_free_lv(cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 2e2146169..386d5b450 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -42,6 +42,7 @@ struct volume_group {
 	struct lvmcache_vginfo *vginfo;
 	uint32_t seqno;		/* Metadata sequence number */
 	unsigned skip_validate_lock_args : 1;
+	unsigned needs_backup : 1;
 	uint32_t write_count; /* count the number of vg_write calls */
 
 	/*
diff --git a/tools/toollib.c b/tools/toollib.c
index 5c9ccb6f2..9c026d9e5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3214,6 +3214,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		log_set_report_object_name_and_id(NULL, NULL);
 	}
 
+	if (vg->needs_backup)
+		backup(vg);
+
 	if (lvargs_supplied) {
 		/*
 		 * FIXME: lvm supports removal of LV with all its dependencies



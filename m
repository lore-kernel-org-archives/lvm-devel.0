From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Apr 2009 10:00:38 -0000
Subject: LVM2/lib/format_text archive.c archiver.c
Message-ID: <20090410100038.20359.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-10 10:00:38

Modified files:
	lib/format_text: archive.c archiver.c 

Log message:
	Properly release VG memory pool in archiver code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/lib/format_text/archive.c	2008/12/07 04:27:56	1.33
+++ LVM2/lib/format_text/archive.c	2009/04/10 10:00:37	1.34
@@ -326,7 +326,7 @@
 	log_print("Description:\t%s", desc ? : "<No description>");
 	log_print("Backup Time:\t%s", ctime(&when));
 
-	dm_pool_free(cmd->mem, vg);
+	vg_release(vg);
 	tf->fmt->ops->destroy_instance(tf);
 }
 
--- LVM2/lib/format_text/archiver.c	2009/04/02 21:34:41	1.22
+++ LVM2/lib/format_text/archiver.c	2009/04/10 10:00:37	1.23
@@ -326,6 +326,7 @@
 			     const char *file)
 {
 	struct volume_group *vg;
+	int r = 0;
 
 	/*
 	 * Read in the volume group from the text file.
@@ -336,10 +337,11 @@
 	/*
 	 * If PV is missing, there is already message from read above
 	 */
-	if (vg_missing_pv_count(vg))
-		return_0;
+	if (!vg_missing_pv_count(vg))
+		r = backup_restore_vg(cmd, vg);
 
-	return backup_restore_vg(cmd, vg);
+	vg_release(vg);
+	return r;
 }
 
 int backup_restore(struct cmd_context *cmd, const char *vg_name)
@@ -414,12 +416,15 @@
 	    (vg->seqno == vg_backup->seqno) &&
 	    (id_equal(&vg->id, &vg_backup->id))) {
 		log_suppress(old_suppress);
+		vg_release(vg_backup);
 		return;
 	}
 	log_suppress(old_suppress);
 
-	if (vg_backup)
+	if (vg_backup) {
 		archive(vg_backup);
+		vg_release(vg_backup);
+	}
 	archive(vg);
 	backup(vg);
 }



From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:36:00 -0000
Subject: LVM2/lib format_text/archiver.c metadata/metad ...
Message-ID: <20120227113600.31260.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:36:00

Modified files:
	lib/format_text: archiver.c 
	lib/metadata   : metadata.c 

Log message:
	Add stack traces for lock_vol failures
	
	Adding at least stack traces with some FIXMEs for cases,
	where we might want to do something cleaver - maybe fail command
	or give user hints something is not going well ?
	
	For remote_backup is stack probably 'good' enough for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.487&r2=1.488

--- LVM2/lib/format_text/archiver.c	2012/02/12 23:01:19	1.50
+++ LVM2/lib/format_text/archiver.c	2012/02/27 11:35:59	1.51
@@ -244,7 +244,8 @@
 int backup(struct volume_group *vg)
 {
 	if (vg_is_clustered(vg))
-		remote_backup_metadata(vg);
+		if (!remote_backup_metadata(vg))
+			stack;
 
 	return backup_locally(vg);
 }
--- LVM2/lib/metadata/metadata.c	2012/02/27 09:51:31	1.487
+++ LVM2/lib/metadata/metadata.c	2012/02/27 11:36:00	1.488
@@ -2708,7 +2708,8 @@
 
 	if (cache_updated) {
 		/* Instruct remote nodes to upgrade cached metadata. */
-		remote_commit_cached_metadata(vg);
+		if (!remote_commit_cached_metadata(vg))
+			stack; // FIXME: What should we do?
 		/*
 		 * We need to clear old_name after a successful commit.
 		 * The volume_group structure could be reused later.
@@ -2741,7 +2742,8 @@
 		log_error("Attempt to drop cached metadata failed "
 			  "after reverted update for VG %s.", vg->name);
 
-	remote_revert_cached_metadata(vg);
+	if (!remote_revert_cached_metadata(vg))
+		stack; // FIXME: What should we do?
 }
 
 struct _vg_read_orphan_baton {



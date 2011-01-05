From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Jan 2011 15:10:31 -0000
Subject: LVM2/lib/locking cluster_locking.c file_locking.c
Message-ID: <20110105151031.14688.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-05 15:10:30

Modified files:
	lib/locking    : cluster_locking.c file_locking.c 

Log message:
	Check result of dm_snprintf for error

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/lib/locking/cluster_locking.c	2010/11/29 11:13:12	1.47
+++ LVM2/lib/locking/cluster_locking.c	2011/01/05 15:10:30	1.48
@@ -409,12 +409,14 @@
 		}
 
 		/* If the VG name is empty then lock the unused PVs */
-		if (is_orphan_vg(resource) || is_global_vg(resource) || (flags & LCK_CACHE))
-			dm_snprintf(lockname, sizeof(lockname), "P_%s",
-				    resource);
-		else
-			dm_snprintf(lockname, sizeof(lockname), "V_%s",
-				    resource);
+		if (dm_snprintf(lockname, sizeof(lockname), "%c_%s",
+				(is_orphan_vg(resource) ||
+				 is_global_vg(resource) ||
+				 (flags & LCK_CACHE)) ?  'P' : 'V',
+				resource)  < 0) {
+			log_error("Locking resource %s too long.", resource);
+			return 0;
+		}
 
 		lock_scope = "VG";
 		clvmd_cmd = CLVMD_CMD_LOCK_VG;
--- LVM2/lib/locking/file_locking.c	2010/12/13 10:43:57	1.51
+++ LVM2/lib/locking/file_locking.c	2011/01/05 15:10:30	1.52
@@ -268,12 +268,20 @@
 		if (flags & LCK_CACHE)
 			break;
 
-		if (is_orphan_vg(resource) || is_global_vg(resource))
-			dm_snprintf(lockfile, sizeof(lockfile),
-				     "%s/P_%s", _lock_dir, resource + 1);
-		else
-			dm_snprintf(lockfile, sizeof(lockfile),
-				     "%s/V_%s", _lock_dir, resource);
+		if (is_orphan_vg(resource) || is_global_vg(resource)) {
+			if (dm_snprintf(lockfile, sizeof(lockfile),
+					"%s/P_%s", _lock_dir, resource + 1) < 0) {
+				log_error("Too long locking filename %s/P_%s.",
+					  _lock_dir, resource + 1);
+				return 0;
+			}
+		} else
+			if (dm_snprintf(lockfile, sizeof(lockfile),
+					"%s/V_%s", _lock_dir, resource) < 0) {
+				log_error("Too long locking filename %s/V_%s.",
+					  _lock_dir, resource);
+				return 0;
+			}
 
 		if (!_lock_file(lockfile, flags))
 			return_0;



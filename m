From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2012 10:33:28 -0000
Subject: LVM2 ./WHATS_NEW daemons/lvmetad/lvmetad-core.c
Message-ID: <20120323103328.2916.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-23 10:33:27

Modified files:
	.              : WHATS_NEW 
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Always free hash table
	
	also in error path

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2365&r2=1.2366
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2012/03/23 09:58:04	1.2365
+++ LVM2/WHATS_NEW	2012/03/23 10:33:26	1.2366
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Always free hash table on update_pvid_to_vgid() in lvmetad.
   Update and fix monitoring of thin pool devices.
   Check hash insert success in lock_vg clvmd.
   Check for buffer overwrite in get_cluster_type() clvmd.
--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/03/02 20:46:36	1.47
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/03/23 10:33:27	1.48
@@ -622,6 +622,7 @@
 	const char *pvid;
 	const char *vgid_old;
 	const char *check_vgid;
+	int r = 0;
 
 	if (!vgid)
 		return 0;
@@ -636,10 +637,10 @@
 		if (nuke_empty &&
 		    (vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid)) &&
 		    !dm_hash_insert(to_check, vgid_old, (void*) 1))
-			return 0;
+			goto out;
 
 		if (!dm_hash_insert(s->pvid_to_vgid, pvid, (void*) vgid))
-			return 0;
+			goto out;
 
 		debug("remap PV %s to VG %s\n", pvid, vgid);
 	}
@@ -652,9 +653,11 @@
 		unlock_vg(s, check_vgid);
 	}
 
+	r = 1;
+    out:
 	dm_hash_destroy(to_check);
 
-	return 1;
+	return r;
 }
 
 /* A pvid map lock needs to be held if update_pvids = 1. */



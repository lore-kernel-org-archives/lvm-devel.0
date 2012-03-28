From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Mar 2012 11:11:26 -0000
Subject: LVM2/lib cache/lvmcache.c log/log.c metadata/m ...
Message-ID: <20120328111126.24666.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-28 11:11:26

Modified files:
	lib/cache      : lvmcache.c 
	lib/log        : log.c 
	lib/metadata   : metadata.c 

Log message:
	Minor fixes
	
	Just small updates and remove <backtrace> after log_error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.499&r2=1.500

--- LVM2/lib/cache/lvmcache.c	2012/03/01 21:58:55	1.133
+++ LVM2/lib/cache/lvmcache.c	2012/03/28 11:11:25	1.134
@@ -125,8 +125,7 @@
 	}
 
 	_has_scanned = 1;
-};
-
+}
 
 /* Volume Group metadata cache functions */
 static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
--- LVM2/lib/log/log.c	2012/03/01 21:12:39	1.70
+++ LVM2/lib/log/log.c	2012/03/28 11:11:25	1.71
@@ -176,9 +176,10 @@
 static struct dm_hash_table *_duplicated = NULL;
 
 void reset_log_duplicated(void) {
-	if (_duplicated)
+	if (_duplicated) {
 		dm_hash_destroy(_duplicated);
-	_duplicated = NULL;
+		_duplicated = NULL;
+	}
 }
 
 void print_log(int level, const char *file, int line, int dm_errno,
@@ -231,7 +232,7 @@
 		}
 
 		locn[sizeof(locn) - 1] = '\0';
-		message = &locn[0];
+		message = locn;
 	}
 
 /* FIXME Avoid pointless use of message buffer when it'll never be read! */
--- LVM2/lib/metadata/metadata.c	2012/03/12 14:43:12	1.499
+++ LVM2/lib/metadata/metadata.c	2012/03/28 11:11:25	1.500
@@ -4035,13 +4035,13 @@
 		log_error("Volume group \"%s\" not found", vg_name);
 
 		failure |= FAILED_NOTFOUND;
-		goto_bad;
+		goto bad;
 	}
 
 	if (vg_is_clustered(vg) && !locking_is_clustered()) {
 		log_error("Skipping clustered volume group %s", vg->name);
 		failure |= FAILED_CLUSTERED;
-		goto_bad;
+		goto bad;
 	}
 
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */



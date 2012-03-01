From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 09:54:24 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20120301095424.31796.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 09:54:24

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Check for allocation error
	
	return ENOMEM when malloc fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2327&r2=1.2328
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/WHATS_NEW	2012/02/29 22:08:57	1.2327
+++ LVM2/WHATS_NEW	2012/03/01 09:54:23	1.2328
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Check for allocation failure in hold_lock() in clvmd.
   Use set_lv() (wipe initial 4KiB) for non zeroed thin volume.
   Allow cluster mirrors to handle the absence of the checkpoint lib (libSaCkpt).
   Revert free of allocated segtype in init segment error path (2.02.89).
--- LVM2/daemons/clvmd/lvm-functions.c	2012/02/23 22:50:50	1.130
+++ LVM2/daemons/clvmd/lvm-functions.c	2012/03/01 09:54:24	1.131
@@ -167,11 +167,15 @@
 	return lvi;
 }
 
-static void insert_info(const char *resource, struct lv_info *lvi)
+static int insert_info(const char *resource, struct lv_info *lvi)
 {
+	int ret;
+
 	pthread_mutex_lock(&lv_hash_lock);
-	dm_hash_insert(lv_hash, resource, lvi);
+	ret = dm_hash_insert(lv_hash, resource, lvi);
 	pthread_mutex_unlock(&lv_hash_lock);
+
+	return ret;
 }
 
 static void remove_info(const char *resource)
@@ -277,8 +281,10 @@
 		errno = saved_errno;
 	} else {
 		lvi = malloc(sizeof(struct lv_info));
-		if (!lvi)
+		if (!lvi) {
+			errno = ENOMEM;
 			return -1;
+		}
 
 		lvi->lock_mode = mode;
 		status = sync_lock(resource, mode, flags & ~LCKF_CONVERT, &lvi->lock_id);
@@ -288,7 +294,10 @@
 			DEBUGLOG("hold_lock. lock at %d failed: %s\n", mode,
 				 strerror(errno));
 		} else
-			insert_info(resource, lvi);
+			if (!insert_info(resource, lvi)) {
+				errno = ENOMEM;
+				return -1;
+			}
 
 		errno = saved_errno;
 	}



From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Sep 2011 18:15:43 -0000
Subject: LVM2 daemons/cmirrord/cluster.c ./WHATS_NEW
Message-ID: <20110906181543.7215.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-06 18:15:43

Modified files:
	daemons/cmirrord: cluster.c 
	.              : WHATS_NEW 

Log message:
	Fix memory leak of allocated bitmap in error path
	
	Found by static analyzer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2091&r2=1.2092

--- LVM2/daemons/cmirrord/cluster.c	2010/10/25 12:59:24	1.16
+++ LVM2/daemons/cmirrord/cluster.c	2011/09/06 18:15:43	1.17
@@ -619,6 +619,7 @@
 	if (rv != SA_AIS_OK) {
 		LOG_ERROR("[%s] Failed to open checkpoint: %s",
 			  SHORT_UUID(entry->name.value), str_ais_error(rv));
+		free(bitmap);
 		return -EIO; /* FIXME: better error */
 	}
 
@@ -647,6 +648,7 @@
 	if (rv != SA_AIS_OK) {
 		LOG_ERROR("[%s] Sync checkpoint section creation failed: %s",
 			  SHORT_UUID(entry->name.value), str_ais_error(rv));
+		free(bitmap);
 		return -EIO; /* FIXME: better error */
 	}
 
--- LVM2/WHATS_NEW	2011/09/06 18:11:21	1.2091
+++ LVM2/WHATS_NEW	2011/09/06 18:15:43	1.2092
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix error path bitmap leak in cmirrord import_checkpoint().
   Log unlink() error in cmirrord remove_lockfile().
   Remove incorrect requirement for -j or -m from lvchange error message.
   Fix unsafe table load when splitting off smaller mirror from a larger one.



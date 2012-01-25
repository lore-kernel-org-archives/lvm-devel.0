From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 21:54:01 -0000
Subject: LVM2/lib raid/raid.c replicator/replicator.c t ...
Message-ID: <20120125215401.559.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 21:54:00

Modified files:
	lib/raid       : raid.c 
	lib/replicator : replicator.c 
	lib/thin       : thin.c 

Log message:
	Free allocated segment type in error path

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/lib/raid/raid.c	2011/11/30 02:02:11	1.13
+++ LVM2/lib/raid/raid.c	2012/01/25 21:54:00	1.14
@@ -452,8 +452,10 @@
 
 	do {
 		if ((segtype = raid_segtype_fn[i](cmd)) &&
-		    !lvm_register_segtype(seglib, segtype))
-			return 0;
+		    !lvm_register_segtype(seglib, segtype)) {
+			dm_free(segtype);
+			return_0;
+		}
 	} while (raid_segtype_fn[++i]);
 
 	return 1;
--- LVM2/lib/replicator/replicator.c	2011/11/29 12:10:38	1.11
+++ LVM2/lib/replicator/replicator.c	2012/01/25 21:54:00	1.12
@@ -772,8 +772,10 @@
 	segtype->private = NULL;
 	segtype->flags = SEG_REPLICATOR;
 
-	if (!lvm_register_segtype(seglib, segtype))
+	if (!lvm_register_segtype(seglib, segtype)) {
+		dm_free(segtype);
 		return_0;
+	}
 
 	log_very_verbose("Initialised segtype: " REPLICATOR_MODULE);
 
@@ -785,8 +787,10 @@
 	segtype->private = NULL;
 	segtype->flags = SEG_REPLICATOR_DEV;
 
-	if (!lvm_register_segtype(seglib, segtype))
+	if (!lvm_register_segtype(seglib, segtype)) {
+		dm_free(segtype);
 		return_0;
+	}
 
 	log_very_verbose("Initialised segtype: " REPLICATOR_DEV_MODULE);
 
--- LVM2/lib/thin/thin.c	2012/01/25 09:06:43	1.44
+++ LVM2/lib/thin/thin.c	2012/01/25 21:54:00	1.45
@@ -606,8 +606,10 @@
 			segtype->flags |= SEG_MONITORED;
 #  endif /* DMEVENTD */
 #endif
-		if (!lvm_register_segtype(seglib, segtype))
+		if (!lvm_register_segtype(seglib, segtype)) {
+			dm_free(segtype);
 			return_0;
+		}
 
 		log_very_verbose("Initialised segtype: %s", segtype->name);
 	}



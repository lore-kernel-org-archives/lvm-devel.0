From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Jun 2008 17:56:54 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20080603175654.17469.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-03 17:56:54

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Drop metadata cache if update fails in vg_revert or vg_commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.879&r2=1.880
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.175&r2=1.176

--- LVM2/WHATS_NEW	2008/06/03 17:51:03	1.879
+++ LVM2/WHATS_NEW	2008/06/03 17:56:54	1.880
@@ -9,6 +9,7 @@
 
 Version 2.02.37 - 
 =================================
+  Drop metadata cache if update fails in vg_revert or vg_commit.
   Avoid spurious duplicate VG messages referring to VGs that are gone.
   Drop dev_name_confirmed error message to debug level.
   Fix setpriority error message to signed int.
--- LVM2/lib/metadata/metadata.c	2008/05/08 18:06:58	1.175
+++ LVM2/lib/metadata/metadata.c	2008/06/03 17:56:54	1.176
@@ -1363,7 +1363,8 @@
 		}
 	}
 
-	if (!drop_cached_metadata(vg))
+	/* If update failed, remove any cached precommitted metadata. */
+	if (!cache_updated && !drop_cached_metadata(vg))
 		log_error("Attempt to drop cached metadata failed "
 			  "after commit for VG %s.", vg->name);
 
@@ -1383,6 +1384,10 @@
 		}
 	}
 
+	if (!drop_cached_metadata(vg))
+		log_error("Attempt to drop cached metadata failed "
+			  "after reverted update for VG %s.", vg->name);
+
 	return 1;
 }
 



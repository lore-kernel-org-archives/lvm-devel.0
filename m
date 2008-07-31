From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2008 13:03:02 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c
Message-ID: <20080731130302.4228.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-31 13:03:02

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c 

Log message:
	Change lvchange exit status to indicate if any part of the operation failed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.939&r2=1.940
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/WHATS_NEW	2008/07/31 12:38:31	1.939
+++ LVM2/WHATS_NEW	2008/07/31 13:03:01	1.940
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Change lvchange exit status to indicate if any part of the operation failed.
   Fix pvchange and pvremove to handle PVs without mdas.
   Refactor _text_pv_read and always return mda list if requested.
   Fix configure to work w/o readline unless --enable-readline used. (2.02.39)
--- LVM2/tools/lvchange.c	2008/06/18 11:32:14	1.92
+++ LVM2/tools/lvchange.c	2008/07/31 13:03:01	1.93
@@ -545,7 +545,7 @@
 static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute((unused)))
 {
-	int doit = 0;
+	int doit = 0, docmds = 0;
 	int archived = 0;
 
 	if (!(lv->vg->status & LVM_WRITE) &&
@@ -606,6 +606,7 @@
 			return ECMD_FAILED;
 		archived = 1;
 		doit += lvchange_permission(cmd, lv);
+		docmds++;
 	}
 
 	/* allocation policy change */
@@ -614,6 +615,7 @@
 			return ECMD_FAILED;
 		archived = 1;
 		doit += lvchange_alloc(cmd, lv);
+		docmds++;
 	}
 
 	/* read ahead sector change */
@@ -622,6 +624,7 @@
 			return ECMD_FAILED;
 		archived = 1;
 		doit += lvchange_readahead(cmd, lv);
+		docmds++;
 	}
 
 	/* read ahead sector change */
@@ -630,6 +633,7 @@
 			return ECMD_FAILED;
 		archived = 1;
 		doit += lvchange_persistent(cmd, lv);
+		docmds++;
 		if (sigint_caught())
 			return ECMD_FAILED;
 	}
@@ -640,6 +644,7 @@
 			return ECMD_FAILED;
 		archived = 1;
 		doit += lvchange_tag(cmd, lv, addtag_ARG);
+		docmds++;
 	}
 
 	/* del tag */
@@ -648,6 +653,7 @@
 			return ECMD_FAILED;
 		archived = 1;
 		doit += lvchange_tag(cmd, lv, deltag_ARG);
+		docmds++;
 	}
 
 	if (doit)
@@ -674,6 +680,9 @@
 			return ECMD_FAILED;
 	}
 
+	if (doit != docmds)
+		return ECMD_FAILED;
+
 	return ECMD_PROCESSED;
 }
 



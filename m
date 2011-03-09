From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Mar 2011 12:44:45 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv.c tools/repor ...
Message-ID: <20110309124445.8910.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-03-09 12:44:43

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv.c 
	tools          : reporter.c 

Log message:
	Use empty string instead of /dev// for LV path when there's no VG.
	Don't allocate unused VG mempool in _pvsegs_sub_single.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1938&r2=1.1939
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/WHATS_NEW	2011/03/08 22:48:50	1.1938
+++ LVM2/WHATS_NEW	2011/03/09 12:44:42	1.1939
@@ -1,6 +1,8 @@
 Version 2.02.85 - 
 ===================================
-  Send 1 byte shorted fully initialised local clvmd messages.
+  Use empty string instead of /dev// for LV path when there's no VG.
+  Don't allocate unused VG mempool in _pvsegs_sub_single.
+  Remove uninitialised byte from end of local clvmd messages.
   Support --help option for clvmd and return error for unknown option.
   Use system page size and not hardcoded value in locking code check.
   Fix reading of released memory for printing segment type.
--- LVM2/lib/metadata/lv.c	2011/03/05 12:14:00	1.21
+++ LVM2/lib/metadata/lv.c	2011/03/09 12:44:43	1.22
@@ -160,6 +160,9 @@
 	char *repstr;
 	size_t len;
 
+	if (!*lv->vg->name)
+		return dm_pool_strdup(mem, "");
+
 	len = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) +
 		strlen(lv->name) + 2;
 
@@ -173,6 +176,7 @@
 		log_error("lvpath snprintf failed");
 		return 0;
 	}
+
 	return repstr;
 }
 
--- LVM2/tools/reporter.c	2011/02/18 14:47:31	1.65
+++ LVM2/tools/reporter.c	2011/03/09 12:44:43	1.66
@@ -51,7 +51,6 @@
 
 	return ECMD_PROCESSED;
 }
-
 static int _pvsegs_sub_single(struct cmd_context *cmd,
 			      struct volume_group *vg,
 			      struct pv_segment *pvseg, void *handle)
@@ -62,11 +61,9 @@
 	struct volume_group _free_vg = {
 		.cmd = cmd,
 		.name = "",
+		.vgmem = NULL,
 	};
 
-        if (!(_free_vg.vgmem = dm_pool_create("_free_vg", 10240)))
-		return ECMD_FAILED;
-
 	struct logical_volume _free_logical_volume = {
 		.vg = vg ?: &_free_vg,
 		.name = "",
@@ -109,8 +106,8 @@
 		ret = ECMD_FAILED;
                 goto_out;
 	}
+
  out:
-	free_vg(&_free_vg);
 	return ret;
 }
 



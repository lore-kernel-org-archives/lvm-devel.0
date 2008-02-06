From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Feb 2008 16:09:52 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20080206160952.1607.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-02-06 16:09:51

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Fix 'pvs -a' to detect VGs of PVs without metadata areas.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.790&r2=1.791
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/WHATS_NEW	2008/02/06 15:47:27	1.790
+++ LVM2/WHATS_NEW	2008/02/06 16:09:51	1.791
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix 'pvs -a' to detect VGs of PVs without metadata areas.
   Divide up internal orphan volume group by format type.
   Update usage message for clvmd.
   Fix clvmd man page printing <br>, clarified debug options.
--- LVM2/tools/toollib.c	2008/01/30 14:00:02	1.130
+++ LVM2/tools/toollib.c	2008/02/06 16:09:51	1.131
@@ -648,6 +648,11 @@
 	int ret_max = 0;
 	int ret = 0;
 
+	if (!scan_vgs_for_pvs(cmd)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
 		log_error("dev_iter creation failed");
 		return ECMD_FAILED;



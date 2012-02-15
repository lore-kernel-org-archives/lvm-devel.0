From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 12:30:47 -0000
Subject: LVM2/tools vgreduce.c
Message-ID: <20120215123047.26219.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 12:30:46

Modified files:
	tools          : vgreduce.c 

Log message:
	Turn a warning to an error in vgreduce --removemissing, since we exit with a
	failure status there.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/tools/vgreduce.c	2012/02/08 11:41:18	1.114
+++ LVM2/tools/vgreduce.c	2012/02/15 12:30:46	1.115
@@ -60,8 +60,8 @@
 
 	if (!r) {
 		cmd->handles_missing_pvs = 1;
-		log_warn("WARNING: There are still partial LVs in VG %s.", vg->name);
-		log_warn("To remove them unconditionally use: vgreduce --removemissing --force.");
+		log_error("There are still partial LVs in VG %s.", vg->name);
+		log_error("To remove them unconditionally use: vgreduce --removemissing --force.");
 		log_warn("Proceeding to remove empty missing PVs.");
 	}
 



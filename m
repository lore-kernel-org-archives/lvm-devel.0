From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Mar 2012 17:03:21 -0000
Subject: LVM2/tools pvscan.c
Message-ID: <20120303170321.21505.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-03 17:03:21

Modified files:
	tools          : pvscan.c 

Log message:
	Reinstate accidentally-deleted line.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/tools/pvscan.c	2012/03/02 18:09:48	1.57
+++ LVM2/tools/pvscan.c	2012/03/03 17:03:20	1.58
@@ -152,6 +152,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, exported_ARG) || arg_count(cmd, novolumegroup_ARG))
 		log_warn("WARNING: only considering physical volumes %s",
 			  arg_count(cmd, exported_ARG) ?
 			  "of exported volume group(s)" : "in no volume group");



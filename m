From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 07:08:24 -0000
Subject: LVM2/tools commands.h
Message-ID: <20080919070824.14338.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 07:08:23

Modified files:
	tools          : commands.h 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/tools/commands.h	2008/09/19 06:42:00	1.119
+++ LVM2/tools/commands.h	2008/09/19 07:08:22	1.120
@@ -857,8 +857,8 @@
    "\tVolumeGroupName\n"
    "\t[PhysicalVolumePath...]\n",
 
-   all_ARG, autobackup_ARG, mirrorsonly_ARG, removemissing_ARG,
-   force_ARG, test_ARG)
+   all_ARG, autobackup_ARG, force_ARG, mirrorsonly_ARG, removemissing_ARG,
+   test_ARG)
 
 xx(vgremove,
    "Remove volume group(s)",



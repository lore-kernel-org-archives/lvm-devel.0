From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Mar 2012 03:11:14 -0000
Subject: LVM2/tools commands.h
Message-ID: <20120306031114.23338.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-06 03:11:13

Modified files:
	tools          : commands.h 

Log message:
	close ]

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.173&r2=1.174

--- LVM2/tools/commands.h	2012/03/06 02:30:50	1.173
+++ LVM2/tools/commands.h	2012/03/06 03:11:13	1.174
@@ -663,7 +663,7 @@
    "List all physical volumes",
    PERMITTED_READ_ONLY,
    "pvscan " "\n"
-   "\t[--cache [ DevicePath | --major major --minor minor]...\n"
+   "\t[--cache [ DevicePath | --major major --minor minor]...]\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
    "\t[-h|-?|--help]" "\n"



From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jul 2010 22:56:32 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20100705225632.18217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-05 22:56:32

Modified files:
	tools          : dmsetup.c 

Log message:
	Fix dmlosetup snprintf %llu compiler warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139

--- LVM2/tools/dmsetup.c	2010/04/28 13:37:37	1.138
+++ LVM2/tools/dmsetup.c	2010/07/05 22:56:31	1.139
@@ -2942,7 +2942,7 @@
 	close(fd);
 
 	if (dm_snprintf(table, tlen, "%llu %llu loop %s %llu\n", 0ULL,
-			(long long unsigned)sectors, file, off) < 0)
+			(long long unsigned)sectors, file, (long long unsigned)off) < 0)
 		return 0;
 
 	if (_switches[VERBOSE_ARG] > 1)
@@ -2956,8 +2956,6 @@
 	return 0;
 }
 
-
-
 static int _process_losetup_switches(const char *base, int *argc, char ***argv,
 				     const char *dev_dir)
 {



From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Dec 2009 13:04:30 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20091211130430.15673.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-12-11 13:04:30

Modified files:
	tools          : dmsetup.c 

Log message:
	Fix coredump and memory leak for 'dmsetup help -c'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/tools/dmsetup.c	2009/11/13 12:43:22	1.128
+++ LVM2/tools/dmsetup.c	2009/12/11 13:04:30	1.129
@@ -2402,7 +2402,7 @@
 	size_t len = 0;
 	int r = 0;
 
-	if (!strcmp(c->name, "splitname"))
+	if (c && !strcmp(c->name, "splitname"))
 		options = (char *) splitname_report_options;
 
 	/* emulate old dmsetup behaviour */
@@ -2591,7 +2591,11 @@
 		_switches[OPTIONS_ARG] = 1;
 		_string_args[OPTIONS_ARG] = (char *) "help";
 		_switches[SORT_ARG] = 0;
-	
+
+		if (_report) {
+			dm_report_free(_report);
+			_report = NULL;
+		}
 		(void) _report_init(NULL);
 	}
 



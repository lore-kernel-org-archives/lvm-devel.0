From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Aug 2011 12:40:27 -0000
Subject: LVM2 tools/dmsetup.c ./WHATS_NEW
Message-ID: <20110804124027.30147.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-04 12:40:25

Modified files:
	tools          : dmsetup.c 
	.              : WHATS_NEW 

Log message:
	Minor memory leak fix
	
	Defer the test of the function return value after the string memory is released.
	Otherwise in this error path the string would present memory leak.
	(Thought in this case we are already out of memory...)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2049&r2=1.2050

--- LVM2/tools/dmsetup.c	2011/07/08 17:08:19	1.165
+++ LVM2/tools/dmsetup.c	2011/08/04 12:40:24	1.166
@@ -779,11 +779,13 @@
 		strcat(str, argv[i]);
 	}
 
-	if (!dm_task_set_message(dmt, str))
-		goto out;
+	i = dm_task_set_message(dmt, str);
 
 	dm_free(str);
 
+	if (!i)
+		goto out;
+
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
--- LVM2/WHATS_NEW	2011/08/04 12:13:50	1.2049
+++ LVM2/WHATS_NEW	2011/08/04 12:40:25	1.2050
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Fix memory leak in dmsetup _message() memory allocation error path.
   Add test for fcntl error in singlenode client code.
   Remove --force option from lvrename manpage.
   Add missing new line in lvrename help text.



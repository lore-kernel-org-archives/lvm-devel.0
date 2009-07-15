From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jul 2009 05:48:37 -0000
Subject: LVM2/tools lvchange.c
Message-ID: <20090715054837.5573.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-07-15 05:48:36

Modified files:
	tools          : lvchange.c 

Log message:
	Take just a read lock when activating in lvchange.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/tools/lvchange.c	2009/07/15 05:47:55	1.106
+++ LVM2/tools/lvchange.c	2009/07/15 05:48:36	1.107
@@ -732,6 +732,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, NULL,
+	return process_each_lv(cmd, argc, argv,
+			       avail_only ? 0 : READ_FOR_UPDATE, NULL,
 			       &lvchange_single);
 }



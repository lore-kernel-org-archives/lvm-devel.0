From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 4 Aug 2010 15:55:04 -0000
Subject: LVM2/lib/mirror mirrored.c
Message-ID: <20100804155504.18703.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-08-04 15:55:03

Modified files:
	lib/mirror     : mirrored.c 

Log message:
	Reduce severity of the "mirror transient status" log message (this was never
	intended to be a log_error).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/lib/mirror/mirrored.c	2010/07/21 15:21:24	1.74
+++ LVM2/lib/mirror/mirrored.c	2010/08/04 15:55:03	1.75
@@ -254,7 +254,7 @@
 	int failed = 0;
 	char *status;
 
-	log_error("Mirrored transient status: \"%s\"", params);
+	log_very_verbose("Mirrored transient status: \"%s\"", params);
 
 	/* number of devices */
 	if (!dm_split_words(params, 1, 0, &p))



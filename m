From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 07:18:04 -0000
Subject: LVM2/lib/device dev-md.c
Message-ID: <20080919071804.30698.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 07:18:03

Modified files:
	lib/device     : dev-md.c 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/lib/device/dev-md.c	2008/09/19 05:19:09	1.11
+++ LVM2/lib/device/dev-md.c	2008/09/19 07:18:03	1.12
@@ -171,7 +171,7 @@
 		goto out;
 	}
 
-	log_very_verbose("Found chunksize %u for md device %s.", chunk_size,
+	log_very_verbose("Found chunksize %lu for md device %s.", chunk_size,
 			 dev_name(dev));
 
 out:



From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Aug 2007 21:11:28 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20070806211128.21534.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-06 21:11:27

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Update a few comments

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/lib/metadata/metadata.c	2007/07/23 21:03:42	1.129
+++ LVM2/lib/metadata/metadata.c	2007/08/06 21:11:27	1.130
@@ -1792,13 +1792,8 @@
 	return 1;
 }
 
-/**
- * vg_lock_and_read - Attempt to lock a volume group, read, and check status
- * @cmd - command context
- * @vg_name - name of the volume group to lock and read
- * @lock_flags - locking flags to use
- * @status_flags - status flags to check
- * @misc_flags - function modifier flags
+/*
+ * vg_lock_and_read - consolidate vg locking, reading, and status flag checking
  *
  * Returns:
  * NULL - failure



From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Jan 2008 17:44:26 -0000
Subject: LVM2/lib/snapshot snapshot.c
Message-ID: <20080111174426.23671.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-11 17:44:26

Modified files:
	lib/snapshot   : snapshot.c 

Log message:
	Fix warning on conditional compile, unused variable

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/lib/snapshot/snapshot.c	2008/01/09 15:32:19	1.25
+++ LVM2/lib/snapshot/snapshot.c	2008/01/11 17:44:26	1.26
@@ -300,7 +300,9 @@
 #endif
 {
 	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+#ifdef DMEVENTD
 	char *dso;
+#endif
 
 	if (!segtype) {
 		stack;



From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Apr 2012 12:17:13 -0000
Subject: LVM2/lib/locking locking.h
Message-ID: <20120424121713.31199.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-24 12:17:13

Modified files:
	lib/locking    : locking.h 

Log message:
	Add some lock comments

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/lib/locking/locking.h	2012/02/27 09:52:37	1.75
+++ LVM2/lib/locking/locking.h	2012/04/24 12:17:12	1.76
@@ -67,13 +67,13 @@
  */
 #define LCK_TYPE_MASK	0x00000007U
 
-#define LCK_NULL	0x00000000U	/* LCK$_NLMODE */
-#define LCK_READ	0x00000001U	/* LCK$_CRMODE */
+#define LCK_NULL	0x00000000U	/* LCK$_NLMODE (Deactivate) */
+#define LCK_READ	0x00000001U	/* LCK$_CRMODE (Activate) */
 					/* LCK$_CWMODE */
 #define LCK_PREAD       0x00000003U	/* LCK$_PRMODE */
-#define LCK_WRITE	0x00000004U	/* LCK$_PWMODE */
-#define LCK_EXCL	0x00000005U	/* LCK$_EXMODE */
-#define LCK_UNLOCK      0x00000006U	/* This is ours */
+#define LCK_WRITE	0x00000004U	/* LCK$_PWMODE (Suspend) */
+#define LCK_EXCL	0x00000005U	/* LCK$_EXMODE (Exclusive) */
+#define LCK_UNLOCK      0x00000006U	/* This is ours (Resume) */
 
 /*
  * Lock flags - these numbers are the same as DLM



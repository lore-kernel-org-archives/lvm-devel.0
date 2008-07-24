From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jul 2008 15:39:47 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20080724153947.13776.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-24 15:39:47

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.935&r2=1.936

--- LVM2/WHATS_NEW	2008/07/24 14:54:06	1.935
+++ LVM2/WHATS_NEW	2008/07/24 15:39:47	1.936
@@ -1,8 +1,8 @@
 Version 2.02.40 - 
 ================================
-  configure no longer fails when the readline library is not available
-  Remove dead code, is_lvm_partition() - no functional change.
-  Refactor pvcreate to divide parameter parsing & validation from create logic.
+  Fix configure to work w/o readline unless --enable-readline used. (2.02.39)
+  Remove is_lvm_partition template which has not yet been coded.
+  Refactor pvcreate to separate parameter parsing from validation logic.
   Check for label_write() failure in _text_pv_write().
   Add pvcreate tests and update vgsplit tests to handle lvm1 and lvm2 metadata.
   Fix pvchange -M1 -u to preserve existing extent locations when there's a VG.



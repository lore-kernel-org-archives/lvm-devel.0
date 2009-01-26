From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2009 14:40:07 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090126144007.30597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-26 14:40:07

Modified files:
	.              : WHATS_NEW 

Log message:
	and another one missing

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1026&r2=1.1027

--- LVM2/WHATS_NEW	2009/01/26 13:34:07	1.1026
+++ LVM2/WHATS_NEW	2009/01/26 14:40:06	1.1027
@@ -1,5 +1,6 @@
 Version 2.02.44 - 26th January 2009
 ===================================
+  Fix --enable-static_link after the recent repository changes.
   Add corosync/DLM cluster interface to clvmd.
   Add --nameprefixes, --unquoted, --rows to pvs, vgs, lvs man pages.
   Fix lvresize size conversion for fsadm when block size is not 1K.



From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Jun 2009 15:09:03 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090615150903.27307.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-15 15:09:02

Modified files:
	.              : WHATS_NEW 

Log message:
	Add WHATS_NEW items.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1151&r2=1.1152

--- LVM2/WHATS_NEW	2009/06/15 13:43:15	1.1151
+++ LVM2/WHATS_NEW	2009/06/15 15:09:02	1.1152
@@ -1,5 +1,7 @@
 Version 2.02.48 - 
 ===============================
+  Ignore suspended devices during repair.
+  Call vgreduce --removemissing automatically to clean up bad PVs in dmeventd.
   Suggest use lvchange --resync when up converting not yet synced mirror.
   Destroy toolcontext on exit in clvmd (fixes memory pool leaks).
   Fix lvconvert to not poll mirror if no conversion in progress.



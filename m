From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Feb 2012 02:56:55 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120210025655.15673.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-10 02:56:55

Modified files:
	.              : WHATS_NEW 

Log message:
	What's new.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2275&r2=1.2276

--- LVM2/WHATS_NEW	2012/02/10 01:29:46	1.2275
+++ LVM2/WHATS_NEW	2012/02/10 02:56:54	1.2276
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Refactor format instances for orphan PVs (internal).
   Refactor lvmcache around an internal API.
   Stop processing lvextend if trying to extend a mirror that is being recovered.
   Add pool_below_threshold() function to check thin pool percent status.



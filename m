From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Oct 2009 11:41:55 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20091002114155.5987.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-10-02 11:41:54

Modified files:
	.              : WHATS_NEW 

Log message:
	Update distclean target for rename clogd to cmirrord. (2.02.52)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1286&r2=1.1287

--- LVM2/WHATS_NEW	2009/10/01 14:14:17	1.1286
+++ LVM2/WHATS_NEW	2009/10/02 11:41:54	1.1287
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Update distclean target for rename clogd to cmirrord. (2.02.52)
   Only do lock conversions in clvmd if we are explicitly asked for one.
   Introduce percent_range_t and centralise snapshot full/mirror in-sync checks.
   Factor out poll_mirror_progress and introduce progress_t.



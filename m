From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 24 Mar 2011 16:03:33 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110324160333.5625.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-03-24 16:03:33

Modified files:
	.              : WHATS_NEW 

Log message:
	What's new.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1957&r2=1.1958

--- LVM2/WHATS_NEW	2011/03/18 12:17:57	1.1957
+++ LVM2/WHATS_NEW	2011/03/24 16:03:32	1.1958
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fixes for lvconvert (including --repair) of temporary mirror stacks.
   Mitigate annoying error warning from device is usable check if run as non-root.
   Add missing \0 for grown debug object in _bitset_with_random_bits().
   Fix allocation of system_id buffer in volume_group structure.



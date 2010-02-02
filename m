From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 2 Feb 2010 17:48:30 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100202174830.800.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-02 17:48:30

Modified files:
	.              : WHATS_NEW 

Log message:
	move WHATS_NEW entries whose changes were made after 2.02.60 to 2.02.61

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1417&r2=1.1418

--- LVM2/WHATS_NEW	2010/02/02 16:26:35	1.1417
+++ LVM2/WHATS_NEW	2010/02/02 17:48:30	1.1418
@@ -4,15 +4,15 @@
   Remove pointless versioned symlinks to dmeventd plugin libraries.
   Fix dmeventd snapshot plugin build dependency.
   Make clvmd -V return zero status.
-
-Version 2.02.60 - 23rd January 2010
-===================================
   Fix lvconvert issue with cluster mirrors due to un'_safe' list processing
   Fix pvmove abort workaround to be cluster-aware when temporary mirror activation fails.
   Always query device by using uuid only and not name in clvmd.
   Add missing metadata reverts in pvmove error path.
   Unlock shared lock in clvmd if activation calls failed.
   Fix return code of info call for query by uuid.
+
+Version 2.02.60 - 23rd January 2010
+===================================
   Extend cmirrord man page.
   Sleep before first progress check if pvmove/lvconvert interval has prefix '+'.
   Default to checking progress before waiting in _wait_for_single_lv.



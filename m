From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 10 Feb 2010 15:56:21 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100210155621.4877.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-10 15:56:21

Modified files:
	.              : WHATS_NEW 

Log message:
	Add 'fail_if_percent_unsupported' arg to _percent() and _percent_run().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1424&r2=1.1425

--- LVM2/WHATS_NEW	2010/02/08 23:28:06	1.1424
+++ LVM2/WHATS_NEW	2010/02/10 15:56:20	1.1425
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Add 'fail_if_percent_unsupported' arg to _percent() and _percent_run().
   Remove false "failed to find tree node for" error when activating merging origin.
   Make lvconvert --repair --use-policies exit with success when no action is needed.
   Add multiple snapshot lv 'lvconvert --merge @tag' support via process_each_lv().



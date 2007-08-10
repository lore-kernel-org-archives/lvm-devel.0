From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Aug 2007 13:33:50 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20070810133350.20203.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-10 13:33:49

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Fix "lvconvert -s" from always failing with argument error message.
	Patch by Jun'ichi Nomura <j-nomura@ce.jp.nec.com>.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.680&r2=1.681
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2007/08/09 09:53:33	1.680
+++ LVM2/WHATS_NEW	2007/08/10 13:33:49	1.681
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Fix "lvconvert -s" from always failing with argument error message.
   Add more cluster info to lvmdump
   Add const attributes where possible, first cut.
   Add support for renaming mirrored LVs.
--- LVM2/tools/lvconvert.c	2007/08/09 21:25:08	1.32
+++ LVM2/tools/lvconvert.c	2007/08/10 13:33:49	1.33
@@ -101,7 +101,7 @@
 static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			int argc, char **argv)
 {
-	int count;
+	int count = 0;
 	int region_size;
 	int pagesize = lvm_getpagesize();
 



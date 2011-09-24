From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 21:19:31 -0000
Subject: LVM2 ./WHATS_NEW lib/raid/raid.c lib/unknown/u ...
Message-ID: <20110924211931.5233.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 21:19:31

Modified files:
	.              : WHATS_NEW 
	lib/raid       : raid.c 
	lib/unknown    : unknown.c 

Log message:
	Fix log_error() usage
	
	Cosmetic - skip <bactrace> when error has been just printed in raid segtype.
	Add missing log_error if allocation would fail for unknown segtype.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2137&r2=1.2138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/unknown/unknown.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2011/09/24 21:10:19	1.2137
+++ LVM2/WHATS_NEW	2011/09/24 21:19:30	1.2138
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix log_error() usage in raid and unknown segtype initialisation.
   Improve testing Makefile.
   Fix install_ocf make target when srcdir != builddir. (2.02.80)
   Support env vars LVM_CLVMD_BINARY and LVM_BINARY in clvmd.
--- LVM2/lib/raid/raid.c	2011/08/31 15:19:20	1.11
+++ LVM2/lib/raid/raid.c	2011/09/24 21:19:30	1.12
@@ -338,7 +338,7 @@
 	if (!segtype) {
 		log_error("Failed to allocate memory for %s segtype",
 			  raid_type);
-		return_NULL;
+		return NULL;
 	}
 	segtype->cmd = cmd;
 
--- LVM2/lib/unknown/unknown.c	2011/08/30 14:55:18	1.8
+++ LVM2/lib/unknown/unknown.c	2011/09/24 21:19:30	1.9
@@ -94,8 +94,10 @@
 {
 	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
 
-	if (!segtype)
-		return_NULL;
+	if (!segtype) {
+		log_error("Failed to allocate memory for unknown segtype");
+		return NULL;
+	}
 
 	segtype->cmd = cmd;
 	segtype->ops = &_unknown_ops;



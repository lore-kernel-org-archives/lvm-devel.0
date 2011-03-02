From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Mar 2011 16:56:07 -0000
Subject: LVM2 ./WHATS_NEW tools/lvresize.c tools/toollib.c
Message-ID: <20110302165607.25231.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-02 16:56:07

Modified files:
	.              : WHATS_NEW 
	tools          : lvresize.c toollib.c 

Log message:
	Use 64bit unsigned value for maximum stripe size test.
	
	While STRIPE_SIZE_LIMIT * 2 is basically UINT_MAX, 32bit integer
	value can already overflow durin arg size parsing.
	
	(This really happens in test where --stripesize 4294967291 is used,
	in s390x uint overflow and this test is ineffective.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1931&r2=1.1932
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.222&r2=1.223

--- LVM2/WHATS_NEW	2011/02/28 19:47:22	1.1931
+++ LVM2/WHATS_NEW	2011/03/02 16:56:06	1.1932
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix possible overwlow in maximum stripe size.
   Add test for failed allocation from dm_task_set_uuid() in dmeventd.
   Improve pvremove error message when PV belongs to a VG.
   Extend normal policy to allow mirror logs on same PVs as images if necessary.
--- LVM2/tools/lvresize.c	2011/01/13 14:51:34	1.128
+++ LVM2/tools/lvresize.c	2011/03/02 16:56:07	1.129
@@ -55,7 +55,7 @@
 		return 0;
 	}
 
-	if (arg_uint_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
+	if (arg_uint64_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
 		log_error("Stripe size cannot be larger than %s",
 			  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 		return 0;
--- LVM2/tools/toollib.c	2011/02/21 12:16:00	1.222
+++ LVM2/tools/toollib.c	2011/03/02 16:56:07	1.223
@@ -1541,7 +1541,7 @@
 			return 0;
 		}
 
-		if(*stripe_size > STRIPE_SIZE_LIMIT * 2) {
+		if(arg_uint64_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
 			log_error("Stripe size cannot be larger than %s",
 				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 			return 0;



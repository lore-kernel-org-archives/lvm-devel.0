From: taka@sourceware.org <taka@sourceware.org>
Date: 23 Mar 2009 21:13:38 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20090323211338.22472.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	taka at sourceware.org	2009-03-23 21:13:38

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Fix error message when adding metadata directory to internal list fails.
	
	Author: Takahiro Yasui <tyasui@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1067&r2=1.1068
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/WHATS_NEW	2009/03/17 13:59:56	1.1067
+++ LVM2/WHATS_NEW	2009/03/23 21:13:37	1.1068
@@ -7,6 +7,7 @@
   Rename liblvm.a to liblvm-internal.a and build new application library.
   Flush memory pool and fix locking in clvmd refresh and backup command.
   Fix unlocks in clvmd-corosync. Broken in 2.02.45.
+  Fix error message when adding metadata directory to internal list fails.
 
 Version 2.02.45 - 3rd March 2009
 ================================
--- LVM2/lib/format_text/format-text.c	2009/03/03 16:35:34	1.103
+++ LVM2/lib/format_text/format-text.c	2009/03/23 21:13:37	1.104
@@ -1996,8 +1996,8 @@
 			}
 
 			if (!_add_dir(cv->v.str, &mda_lists->dirs)) {
-				log_error("Failed to add %s to internal device "
-					  "cache", cv->v.str);
+				log_error("Failed to add %s to text format "
+					  "metadata directory list ", cv->v.str);
 				goto err;
 			}
 		}



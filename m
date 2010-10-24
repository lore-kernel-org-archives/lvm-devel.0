From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 24 Oct 2010 17:36:59 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20101024173659.18790.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-10-24 17:36:59

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Never scan a device which is using the error target
	
	A merged snapshot's DM device is made to use the "error" target as part
	of lvm's transaction to merge a snapshot.  This snapshot merge use-case
	aside, any device using the error target shouldn't be scanned.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1765&r2=1.1766
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.203&r2=1.204

--- LVM2/WHATS_NEW	2010/10/20 15:07:30	1.1765
+++ LVM2/WHATS_NEW	2010/10/24 17:36:58	1.1766
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Never scan a device which is using the error target.
   Fix strict-aliasing compile warning in partition table scanning.
   Add an option to automatically extend snapshots through dmeventd.
   Remove dependency on libm, floor() is replaced with integer algorithm.
--- LVM2/lib/activate/dev_manager.c	2010/10/13 21:26:37	1.203
+++ LVM2/lib/activate/dev_manager.c	2010/10/24 17:36:59	1.204
@@ -190,6 +190,12 @@
 				  dev_name(dev), name);
 			goto out;
 		}
+
+		if (target_type && !strcmp(target_type, "error")) {
+			log_debug("%s: Error device %s not usable.",
+				  dev_name(dev), name);
+			goto out;
+		}
 	} while (next);
 
 	/* FIXME Also check dependencies? */



From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Aug 2010 23:29:10 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20100816232910.28280.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-16 23:29:10

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Don't really change monitoring status when in test mode.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1704&r2=1.1705
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175

--- LVM2/WHATS_NEW	2010/08/16 22:54:35	1.1704
+++ LVM2/WHATS_NEW	2010/08/16 23:29:09	1.1705
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Don't really change monitoring status when in test mode.
   Fix some exit statuses when starting/stopping monitoring fails.
   Enable snapshot monitoring by default when dmeventd is enabled.
   Move cloned libdevmapper-event client code from segments into lib/activate.
--- LVM2/lib/activate/activate.c	2010/08/16 22:54:36	1.174
+++ LVM2/lib/activate/activate.c	2010/08/16 23:29:10	1.175
@@ -940,7 +940,12 @@
 		if (!monitor_fn)
 			continue;
 
-		log_verbose("%sonitoring %s/%s", monitor ? "M" : "Not m", lv->vg->name, lv->name);
+		log_verbose("%sonitoring %s/%s%s", monitor ? "M" : "Not m", lv->vg->name, lv->name,
+			    test_mode() ? " [Test mode: skipping this]" : "");
+
+		/* FIXME Test mode should really continue a bit further. */
+		if (test_mode())
+			continue;
 
 		/* FIXME specify events */
 		if (!monitor_fn(seg, 0)) {
@@ -964,7 +969,8 @@
 			sleep(1);
 		}
 
-		r = (monitored && monitor) || (!monitored && !monitor);
+		if (r)
+			r = (monitored && monitor) || (!monitored && !monitor);
 	}
 
 	return r;



From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Sep 2009 23:48:42 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf
Message-ID: <20090916234842.19152.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-16 23:48:42

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 

Log message:
	Enable dmeventd monitoring section of config file by default.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1268&r2=1.1269
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2009/09/16 23:22:40	1.1268
+++ LVM2/WHATS_NEW	2009/09/16 23:48:41	1.1269
@@ -1,5 +1,6 @@
 Version 2.02.53 - 
 =====================================
+  Enable dmeventd monitoring section of config file by default.
   Update lvm2 monitoring script to lvm2_monitoring_init_red_hat.in.
   Fix lvm2app test to run under test/api subdirectory only when configured.
   Add vg_is_resizeable() and cleanup reference to VG_RESIZEABLE.
--- LVM2/doc/example.conf	2009/09/15 13:49:11	1.48
+++ LVM2/doc/example.conf	2009/09/16 23:48:41	1.49
@@ -435,7 +435,7 @@
 
 # Event daemon
 #
-# dmeventd {
+dmeventd {
     # mirror_library is the library used when monitoring a mirror device.
     #
     # "libdevmapper-event-lvm2mirror.so" attempts to recover from
@@ -443,7 +443,7 @@
     # reconfigures a mirror as necessary. If no mirror library is
     # provided, mirrors are not monitored through dmeventd.
 
-    # mirror_library = "libdevmapper-event-lvm2mirror.so"
+    mirror_library = "libdevmapper-event-lvm2mirror.so"
 
     # snapshot_library is the library used when monitoring a snapshot device.
     #
@@ -452,6 +452,5 @@
     # snapshot exceedes 80%. The warning is repeated when 85%, 90% and
     # 95% of the snapshot are filled.
 
-    # snapshot_library = "libdevmapper-event-lvm2snapshot.so"
-#}
-
+    snapshot_library = "libdevmapper-event-lvm2snapshot.so"
+}



From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Sep 2011 18:11:22 -0000
Subject: LVM2 daemons/cmirrord/clogd.c ./WHATS_NEW
Message-ID: <20110906181122.6298.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-06 18:11:21

Modified files:
	daemons/cmirrord: clogd.c 
	.              : WHATS_NEW 

Log message:
	Log unlink() error

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2090&r2=1.2091

--- LVM2/daemons/cmirrord/clogd.c	2010/12/13 10:43:57	1.13
+++ LVM2/daemons/cmirrord/clogd.c	2011/09/06 18:11:21	1.14
@@ -121,7 +121,8 @@
 
 static void remove_lockfile(void)
 {
-	unlink(CMIRRORD_PIDFILE);
+	if (unlink(CMIRRORD_PIDFILE))
+		LOG_ERROR("Unable to remove \"" CMIRRORD_PIDFILE "\" %s", strerror(errno));
 }
 
 /*
--- LVM2/WHATS_NEW	2011/09/05 12:54:29	1.2090
+++ LVM2/WHATS_NEW	2011/09/06 18:11:21	1.2091
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Log unlink() error in cmirrord remove_lockfile().
   Remove incorrect requirement for -j or -m from lvchange error message.
   Fix unsafe table load when splitting off smaller mirror from a larger one.
   Use size_t return type for text_vg_export_raw() and export_vg_to_buffer().



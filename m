From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 11:40:25 -0000
Subject: LVM2/daemons/lvmetad lvmetad-client.h
Message-ID: <20120223114025.25397.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 11:40:24

Modified files:
	daemons/lvmetad: lvmetad-client.h 

Log message:
	Also use DEFAULT_RUN_DIR for the lvmetad socket on the client side.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-client.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/daemons/lvmetad/lvmetad-client.h	2012/01/16 08:25:32	1.5
+++ LVM2/daemons/lvmetad/lvmetad-client.h	2012/02/23 11:40:24	1.6
@@ -67,7 +67,7 @@
 	/* TODO configurable */
 	daemon_info lvmetad_info = {
 		.path = "lvmetad",
-		.socket = socket ?: "/var/run/lvm/lvmetad.socket",
+		.socket = socket ?: DEFAULT_RUN_DIR "/lvmetad.socket",
 		.autostart = 1
 	};
 



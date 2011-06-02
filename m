From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Jun 2011 08:58:06 -0000
Subject: LVM2/daemons/lvmetad lvmetad-client.h
Message-ID: <20110602085806.10724.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-02 08:58:06

Modified files:
	daemons/lvmetad: lvmetad-client.h 

Log message:
	Use /var/run/lvm for lvmetad socket.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-client.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/lvmetad/lvmetad-client.h	2011/05/13 08:17:26	1.1
+++ LVM2/daemons/lvmetad/lvmetad-client.h	2011/06/02 08:58:05	1.2
@@ -66,7 +66,7 @@
 	/* TODO configurable */
 	daemon_info lvmetad_info = {
 		.path = "lvmetad",
-		.socket = "/var/run/lvmetad.socket",
+		.socket = "/var/run/lvm/lvmetad.socket",
 		.autostart = 1
 	};
 



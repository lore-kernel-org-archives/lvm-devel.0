From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 22:54:18 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20120301225418.13494.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 22:54:17

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Skip zero length messages
	
	In case of zero length message, there would be a memory leak on
	return path from _do_process_request.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/daemons/dmeventd/dmeventd.c	2012/03/01 22:06:18	1.93
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/03/01 22:54:17	1.94
@@ -1504,9 +1504,10 @@
 
 	while ((reg = _initial_registrations[i])) {
 		msg.cmd = DM_EVENT_CMD_REGISTER_FOR_EVENT;
-		msg.size = strlen(reg);
-		msg.data = reg;
-		_do_process_request(&msg);
+		if ((msg.size = strlen(reg))) {
+			msg.data = reg;
+			_do_process_request(&msg);
+		}
 		++ i;
 	}
 }



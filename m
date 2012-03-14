From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Mar 2012 17:15:22 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120314171522.12113.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-14 17:15:22

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	Just move declaration

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/lib/cache/lvmetad.c	2012/03/03 18:32:54	1.18
+++ LVM2/lib/cache/lvmetad.c	2012/03/14 17:15:22	1.19
@@ -609,13 +609,14 @@
 
 int lvmetad_pv_gone(dev_t device, const char *pv_name)
 {
+	daemon_reply reply;
 	int result;
 	int found;
 
 	if (!_using_lvmetad)
 		return 1;
 
-	daemon_reply reply = daemon_send_simple(_lvmetad, "pv_gone", "device = %d", device, NULL);
+	reply = daemon_send_simple(_lvmetad, "pv_gone", "device = %d", device, NULL);
 
 	result = _lvmetad_handle_reply(reply, "drop PV", pv_name, &found);
 	/* We don't care whether or not the daemon had the PV cached. */



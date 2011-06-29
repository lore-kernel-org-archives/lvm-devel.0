From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 16:08:34 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110629160834.4818.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 16:08:33

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	debug log readonly flag with ioctls

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111

--- LVM2/libdm/ioctl/libdm-iface.c	2011/06/29 11:36:37	1.110
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/06/29 16:08:33	1.111
@@ -1963,7 +1963,7 @@
 	}
 
 	log_debug("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-		  "%s%c%c%s%s%s %.0" PRIu64 " %s [%u]",
+		  "%s%c%c%s%s%s%s %.0" PRIu64 " %s [%u]",
 		  _cmd_data_v4[dmt->type].name,
 		  dmt->new_uuid ? "UUID " : "",
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1976,6 +1976,7 @@
 		  dmt->major > 0 ? ") " : "",
 		  dmt->no_open_count ? 'N' : 'O',
 		  dmt->no_flush ? 'N' : 'F',
+		  dmt->read_only ? "R" : "",
 		  dmt->skip_lockfs ? "S " : "",
 		  dmt->secure_data ? "W " : "",
 		  dmt->query_inactive_table ? "I " : "",



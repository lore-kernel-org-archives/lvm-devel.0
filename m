From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Mar 2011 23:27:07 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20110301232707.16026.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-03-01 23:27:07

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix _create_and_load_v4 not to lose the --addnodeoncreate setting (1.02.62).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.449&r2=1.450
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/WHATS_NEW_DM	2011/02/21 16:26:23	1.449
+++ LVM2/WHATS_NEW_DM	2011/03/01 23:27:06	1.450
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Fix _create_and_load_v4 not to lose the --addnodeoncreate setting (1.02.62).
   Add inactive table query support for kernel driver >= 4.11.6 (RHEL 5.7).
   Log debug open_count in _node_has_closed_parents().
   Change dm_report_field_string() API to accept const char *const *data.
--- LVM2/libdm/ioctl/libdm-iface.c	2011/02/21 16:26:24	1.94
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/03/01 23:27:07	1.95
@@ -1753,6 +1753,7 @@
 	/* FIXME: Just for udev_check in dm_task_run. Can we avoid this? */
 	task->event_nr = dmt->event_nr & DM_UDEV_FLAGS_MASK;
 	task->cookie_set = dmt->cookie_set;
+	task->add_node = dmt->add_node;
 
 	r = dm_task_run(task);
 	dm_task_destroy(task);



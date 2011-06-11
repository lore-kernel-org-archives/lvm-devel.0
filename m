From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jun 2011 12:55:31 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20110611125531.29363.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-11 12:55:31

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Fix --mirrorlog mirrored.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/libdm/libdm-deptree.c	2011/06/11 00:03:07	1.94
+++ LVM2/libdm/libdm-deptree.c	2011/06/11 12:55:31	1.95
@@ -2210,6 +2210,10 @@
 			if (clustered)
 				log_node->props.immediate_dev_node = 1;
 
+			/* The kernel validates the size of disk logs. */
+			/* FIXME Propagate to any devices below */
+			log_node->props.delay_resume_if_new = 0;
+
 			if (!_link_tree_nodes(node, log_node))
 				return_0;
 		}



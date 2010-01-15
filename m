From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 15 Jan 2010 16:00:24 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20100115160024.22819.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-15 16:00:23

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Off-by-one count was causing not all the mirror table parameters
	that were necessary to be passed on to userspace.
	
	The cluster mirror table (log portion only) used to look like this:
	clustered-disk <parm_count> <disk> <region_size> <uuid> \
	[[no]sync] [block_on_error]
	Now it looks like this:
	userspace <parm_count> <uuid> clustered-disk <disk> <region_size> \
	[[no]sync]
	
	So, there is one extra argument in the latter case - this was
	unaccounted for.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/libdm/libdm-deptree.c	2010/01/14 10:15:23	1.70
+++ LVM2/libdm/libdm-deptree.c	2010/01/15 16:00:23	1.71
@@ -1408,6 +1408,9 @@
 
 		if (!dm_log_userspace)
 			EMIT_PARAMS(pos, "clustered-");
+		else
+			/* For clustered-* type field inserted later */
+			log_parm_count++;
 	}
 
 	if (!seg->log)



From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Dec 2007 19:24:35 -0000
Subject: LVM2 lib/activate/dev_manager.c tools/lvchange ...
Message-ID: <20071205192435.9424.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-05 19:24:32

Modified files:
	lib/activate   : dev_manager.c 
	tools          : lvchange.c lvcreate.c 

Log message:
	round readahead to multiple of page size in tools

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162

--- LVM2/lib/activate/dev_manager.c	2007/12/03 18:00:38	1.130
+++ LVM2/lib/activate/dev_manager.c	2007/12/05 19:24:31	1.131
@@ -952,10 +952,10 @@
 			max_stripe_size = seg->stripe_size;
 	}
 
-	if (read_ahead == DM_READ_AHEAD_AUTO)
+	if (read_ahead == DM_READ_AHEAD_AUTO) {
 		read_ahead = max_stripe_size;
-	else
 		read_ahead_flags = DM_READ_AHEAD_MINIMUM_FLAG;
+	}
 
 	dm_tree_node_set_read_ahead(dnode, read_ahead, read_ahead_flags);
 
--- LVM2/tools/lvchange.c	2007/11/12 20:51:54	1.83
+++ LVM2/tools/lvchange.c	2007/12/05 19:24:32	1.84
@@ -372,6 +372,7 @@
 			      struct logical_volume *lv)
 {
 	unsigned read_ahead = 0;
+	unsigned pagesize = (unsigned) lvm_getpagesize() >> SECTOR_SHIFT;
 
 	read_ahead = arg_uint_value(cmd, readahead_ARG, 0);
 
@@ -382,6 +383,13 @@
 		return 0;
 	}
 
+	if (read_ahead != DM_READ_AHEAD_AUTO &&
+	    read_ahead != DM_READ_AHEAD_NONE && read_ahead % pagesize) {
+		read_ahead = (read_ahead / pagesize) * pagesize;
+		log_verbose("Rounding down readahead to %u sectors, a multiple "
+			    "of page size %u.", read_ahead, pagesize);
+	}
+
 	if (lv->read_ahead == read_ahead) {
 		log_error("Read ahead is already %u for \"%s\"",
 			  read_ahead, lv->name);
--- LVM2/tools/lvcreate.c	2007/11/22 14:54:35	1.161
+++ LVM2/tools/lvcreate.c	2007/12/05 19:24:32	1.162
@@ -333,6 +333,7 @@
 			    int argc, char **argv)
 {
 	int contiguous;
+	unsigned pagesize;
 
 	memset(lp, 0, sizeof(*lp));
 
@@ -462,8 +463,17 @@
 	/*
 	 * Read ahead.
 	 */
-	if (arg_count(cmd, readahead_ARG))
+	if (arg_count(cmd, readahead_ARG)) {
 		lp->read_ahead = arg_uint_value(cmd, readahead_ARG, 0);
+		pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
+		if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
+		    lp->read_ahead != DM_READ_AHEAD_NONE &&
+		    lp->read_ahead % pagesize) {
+			lp->read_ahead = (lp->read_ahead / pagesize) * pagesize;
+			log_verbose("Rounding down readahead to %u sectors, a multiple "
+				    "of page size %u.", lp->read_ahead, pagesize);
+		}
+	}
 
 	/*
 	 * Permissions.



From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 18:13:34 -0000
Subject: LVM2/lib/filters filter-persistent.c
Message-ID: <20090708181334.29142.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 18:13:32

Modified files:
	lib/filters    : filter-persistent.c 

Log message:
	Fix segfault in persistent_filter_dump() if lvm init fails.
	
	Just return_0 in persistent_filter_dump() if passed a NULL filter;

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/lib/filters/filter-persistent.c	2008/11/03 22:14:28	1.37
+++ LVM2/lib/filters/filter-persistent.c	2009/07/08 18:13:32	1.38
@@ -177,7 +177,7 @@
 
 int persistent_filter_dump(struct dev_filter *f)
 {
-	struct pfilter *pf = (struct pfilter *) f->private;
+	struct pfilter *pf;
 	char *tmp_file;
 	struct stat info, info2;
 	struct config_tree *cft = NULL;
@@ -185,6 +185,10 @@
 	int lockfd;
 	int r = 0;
 
+	if (!f)
+		return_0;
+	pf = (struct pfilter *) f->private;
+
 	if (!dm_hash_get_num_entries(pf->devices)) {
 		log_very_verbose("Internal persistent device cache empty "
 				 "- not writing to %s", pf->file);



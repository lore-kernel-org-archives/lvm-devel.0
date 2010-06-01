From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jun 2010 19:02:12 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-persistent.c
Message-ID: <20100601190212.17648.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-01 19:02:12

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-persistent.c 

Log message:
	Don't merge unchanged persistent cache file before dumping if tool scanned.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1601&r2=1.1602
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2010/06/01 12:08:50	1.1601
+++ LVM2/WHATS_NEW	2010/06/01 19:02:12	1.1602
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Don't merge unchanged persistent cache file before dumping if tool scanned.
   Fix incorrect memory pool deallocation while using vg_read for files.
   Add --type parameter description to the lvcreate man page.
   Replace strncmp kernel version number checks with proper ones.
--- LVM2/lib/filters/filter-persistent.c	2010/05/13 13:04:05	1.41
+++ LVM2/lib/filters/filter-persistent.c	2010/06/01 19:02:12	1.42
@@ -295,6 +295,7 @@
 {
 	struct pfilter *pf;
 	struct dev_filter *f = NULL;
+	struct stat info;
 
 	if (!(pf = dm_malloc(sizeof(*pf))))
 		return_NULL;
@@ -314,6 +315,10 @@
 	if (!(f = dm_malloc(sizeof(*f))))
 		goto_bad;
 
+	/* Only merge cache file before dumping it if it changed externally. */
+	if (!stat(pf->file, &info))
+		pf->ctime = info.st_ctime;
+
 	f->passes_filter = _lookup_p;
 	f->destroy = _persistent_destroy;
 	f->private = pf;



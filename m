From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:33:43 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20101025133343.23659.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:33:43

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Fix constness warnings
	
	After update of device_from_pvid() API fix constness warnings
	Also fix info_from_pvid() constness warning for char* usage.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/lib/cache/lvmcache.c	2010/10/25 13:02:26	1.96
+++ LVM2/lib/cache/lvmcache.c	2010/10/25 13:33:42	1.97
@@ -514,7 +514,7 @@
 	struct lvmcache_info *info;
 	char *vgname;
 
-	if (!device_from_pvid(cmd, (struct id *)pvid, NULL)) {
+	if (!device_from_pvid(cmd, (const struct id *)pvid, NULL)) {
 		log_error("Couldn't find device with uuid %s.", pvid);
 		return NULL;
 	}
@@ -740,7 +740,7 @@
 	struct lvmcache_info *info;
 
 	/* Already cached ? */
-	if ((info = info_from_pvid((char *) pvid, 0))) {
+	if ((info = info_from_pvid((const char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
@@ -751,7 +751,7 @@
 	lvmcache_label_scan(cmd, 0);
 
 	/* Try again */
-	if ((info = info_from_pvid((char *) pvid, 0))) {
+	if ((info = info_from_pvid((const char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
@@ -767,7 +767,7 @@
 		*scan_done_once = 1;
 
 	/* Try again */
-	if ((info = info_from_pvid((char *) pvid, 0))) {
+	if ((info = info_from_pvid((const char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))



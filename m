From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jul 2007 18:18:34 -0000
Subject: LVM2/lib/report report.c
Message-ID: <20070710181834.29170.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-07-10 18:18:33

Modified files:
	lib/report     : report.c 

Log message:
	Fix pv_mda_count to cope with missing PV.
	[vgcreate vg1 pv1 pv2; pvremove -ff pv1; pvs -P -o+pv_mda_count =>segfault]

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/lib/report/report.c	2007/07/09 15:40:43	1.57
+++ LVM2/lib/report/report.c	2007/07/10 18:18:33	1.58
@@ -723,10 +723,11 @@
 			const void *data, void *private)
 {
 	struct lvmcache_info *info; 
-	uint32_t count;
+	uint32_t count = 0;
+	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 
-	info = info_from_pvid((const char *)(&((struct id *) data)->uuid));
-	count = list_size(&info->mdas);
+	info = info_from_pvid(pvid);
+	count = info ? list_size(&info->mdas) : 0;
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }



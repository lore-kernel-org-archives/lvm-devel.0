From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2010 18:34:01 -0000
Subject: LVM2 lib/report/report.c libdm/libdm-report.c
Message-ID: <20100215183401.3359.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-02-15 18:34:00

Modified files:
	lib/report     : report.c 
	libdm          : libdm-report.c 

Log message:
	* add more 'const' - fixes gcc constness warning

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/lib/report/report.c	2010/02/14 03:21:38	1.112
+++ LVM2/lib/report/report.c	2010/02/15 18:34:00	1.113
@@ -66,7 +66,7 @@
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute((unused)))
 {
-	const char *name = dev_name(*(const struct device **) data);
+	const char *name = dev_name(*(const struct device * const *) data);
 
 	return dm_report_field_string(rh, field, &name);
 }
@@ -873,7 +873,7 @@
 {
 	struct lvmcache_info *info;
 	uint64_t freespace = UINT64_MAX, mda_free;
-	const char *pvid = (const char *)(&((struct id *) data)->uuid);
+	const char *pvid = (const char *)(&((const struct id *) data)->uuid);
 	struct metadata_area *mda;
 
 	if ((info = info_from_pvid(pvid, 0)))
@@ -916,7 +916,7 @@
 {
 	struct lvmcache_info *info;
 	uint64_t min_mda_size = 0;
-	const char *pvid = (const char *)(&((struct id *) data)->uuid);
+	const char *pvid = (const char *)(&((const struct id *) data)->uuid);
 
 	/* PVs could have 2 mdas of different sizes (rounding effect) */
 	if ((info = info_from_pvid(pvid, 0)))
--- LVM2/libdm/libdm-report.c	2010/01/11 21:28:04	1.33
+++ LVM2/libdm/libdm-report.c	2010/02/15 18:34:00	1.34
@@ -819,8 +819,8 @@
  */
 static int _row_compare(const void *a, const void *b)
 {
-	const struct row *rowa = *(const struct row **) a;
-	const struct row *rowb = *(const struct row **) b;
+	const struct row *rowa = *(const struct row * const *) a;
+	const struct row *rowb = *(const struct row * const *) b;
 	const struct dm_report_field *sfa, *sfb;
 	uint32_t cnt;
 



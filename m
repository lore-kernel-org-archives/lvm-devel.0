From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2011 19:34:04 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c libdm ...
Message-ID: <20111118193404.21061.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-18 19:34:03

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Check target type name for DM_MAX_TYPE_NAME length
	
	Avoid creation of target type name when it's longer then
	DM_MAX_TYPE_NAME (noticed by static analyzer where the
	sp.target_type might be missing '\0' at the end.)
	
	Before patch:
	
	$> dmsetup create long
	0 1000 looooooooooooooooooooooooooong
	^D
	device-mapper: reload ioctl failed: Invalid argument
	
	After patch:
	
	$> dmsetup create xxx
	0 1000 looooooooooooooooooooooooooong
	Target type name looooooooooooooooooooooooooong is too long.
	Command failed

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.523&r2=1.524
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/WHATS_NEW_DM	2011/11/15 13:54:20	1.523
+++ LVM2/WHATS_NEW_DM	2011/11/18 19:34:02	1.524
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add test for max length (DM_MAX_TYPE_NAME) of target type name.
   Include a copy of kernel DM documentation in doc/kernel.
   Improve man page style for dmsetup.
   Fix _get_proc_number to be tolerant of malformed /proc/misc entries.
--- LVM2/libdm/libdm-common.c	2011/09/24 11:47:53	1.127
+++ LVM2/libdm/libdm-common.c	2011/11/18 19:34:03	1.128
@@ -407,9 +407,8 @@
 		       const char *ttype, const char *params)
 {
 	struct target *t = create_target(start, size, ttype, params);
-
 	if (!t)
-		return 0;
+		return_0;
 
 	if (!dmt->head)
 		dmt->head = dmt->tail = t;
--- LVM2/libdm/ioctl/libdm-iface.c	2011/11/08 19:02:21	1.128
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/11/18 19:34:03	1.129
@@ -853,9 +853,14 @@
 struct target *create_target(uint64_t start, uint64_t len, const char *type,
 			     const char *params)
 {
-	struct target *t = dm_zalloc(sizeof(*t));
+	struct target *t;
+
+	if (strlen(type) >= DM_MAX_TYPE_NAME) {
+		log_error("Target type name %s is too long.", type);
+		return NULL;
+	}
 
-	if (!t) {
+	if (!(t = dm_zalloc(sizeof(*t)))) {
 		log_error("create_target: malloc(%" PRIsize_t ") failed",
 			  sizeof(*t));
 		return NULL;
@@ -889,19 +894,24 @@
 	size_t sp_size = sizeof(struct dm_target_spec);
 	int len;
 
-	out += sp_size;
-	if (out >= end)
-		return_NULL;
+	if (strlen(t->type) >= sizeof(sp.target_type)) {
+		log_error("Target type name %s is too long.", t->type);
+		return NULL;
+	}
 
 	sp.status = 0;
 	sp.sector_start = t->start;
 	sp.length = t->length;
-	strncpy(sp.target_type, t->type, sizeof(sp.target_type));
+	strncpy(sp.target_type, t->type, sizeof(sp.target_type) - 1);
+	sp.target_type[sizeof(sp.target_type) - 1] = '\0';
 
+	out += sp_size;
 	len = strlen(t->params);
 
-	if ((out + len + 1) >= end)
-		return_NULL;
+	if ((out >= end) || (out + len + 1) >= end) {
+		log_error("Ran out of memory building ioctl parameter");
+		return NULL;
+	}
 
 	strcpy(out, t->params);
 	out += len + 1;
@@ -1110,10 +1120,8 @@
 	e = (char *) dmi + len;
 
 	for (t = dmt->head; t; t = t->next)
-		if (!(b = _add_target(t, b, e))) {
-			log_error("Ran out of memory building ioctl parameter");
-			goto bad;
-		}
+		if (!(b = _add_target(t, b, e)))
+			goto_bad;
 
 	if (dmt->newname)
 		strcpy(b, dmt->newname);



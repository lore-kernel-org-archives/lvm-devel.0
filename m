From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Aug 2011 17:56:49 -0000
Subject: LVM2 ./WHATS_NEW_DM ./configure ./configure.in ...
Message-ID: <20110809175649.8969.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-09 17:56:48

Modified files:
	.              : WHATS_NEW_DM configure configure.in 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 
Removed files:
	libdm/ioctl    : libdm-compat.h 

Log message:
	Remove support for the original dm ioctl interface version 1.
	Leave the basic support for multiple versions in case we have a new version
	in future.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.486&r2=1.487
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.164&r2=1.165
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-compat.h.diff?cvsroot=lvm2&r1=1.11&r2=NONE

--- LVM2/WHATS_NEW_DM	2011/08/04 17:56:11	1.486
+++ LVM2/WHATS_NEW_DM	2011/08/09 17:56:47	1.487
@@ -1,5 +1,6 @@
 Version 1.02.66 - 
 ===============================
+  Remove support for the original version 1 dm ioctls.
   Add missing check for allocation failure _create_dir_recursive().
   Add support for systemd file descriptor handover in dmeventd.
   Add support for new oom killer adjustment interface (oom_score_adj).
--- LVM2/configure	2011/08/02 22:07:20	1.150
+++ LVM2/configure	2011/08/09 17:56:47	1.151
@@ -8917,6 +8917,13 @@
 fi
 
 
+if test x$DM_COMPAT = xyes; then
+	as_fn_error $? "--enable-compat is not currently supported.
+Since device-mapper version 1.02.66, only one version (4) of the device-mapper
+ioctl protocol is supported.
+	" "$LINENO" 5
+fi
+
 ################################################################################
 # Check whether --enable-units-compat was given.
 if test "${enable_units_compat+set}" = set; then :
--- LVM2/configure.in	2011/08/02 22:07:21	1.164
+++ LVM2/configure.in	2011/08/09 17:56:47	1.165
@@ -846,6 +846,14 @@
 			     [enable support for old device-mapper versions]),
 	      DM_COMPAT=$enableval, DM_COMPAT=no)
 
+if test x$DM_COMPAT = xyes; then
+	AC_MSG_ERROR(
+                 [--enable-compat is not currently supported.
+Since device-mapper version 1.02.66, only one version (4) of the device-mapper 
+ioctl protocol is supported.]
+	)
+fi
+
 ################################################################################
 dnl -- Compatible units suffix mode
 AC_ARG_ENABLE(units-compat,
--- LVM2/libdm/ioctl/libdm-iface.c	2011/07/24 23:59:03	1.114
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/08/09 17:56:48	1.115
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -17,10 +17,6 @@
 #include "libdm-targets.h"
 #include "libdm-common.h"
 
-#ifdef DM_COMPAT
-#  include "libdm-compat.h"
-#endif
-
 #include <fcntl.h>
 #include <dirent.h>
 #include <sys/ioctl.h>
@@ -44,8 +40,7 @@
  * in the _cmd_data arrays.
  */
 
-#if !((DM_VERSION_MAJOR == 1 && DM_VERSION_MINOR >= 0) || \
-      (DM_VERSION_MAJOR == 4 && DM_VERSION_MINOR >= 0))
+#if !((DM_VERSION_MAJOR == 4 && DM_VERSION_MINOR >= 6))
 #error The version of dm-ioctl.h included is incompatible.
 #endif
 
@@ -92,16 +87,7 @@
 static int _version_ok = 1;
 static unsigned _ioctl_buffer_double_factor = 0;
 
-/*
- * Support both old and new major numbers to ease the transition.
- * Clumsy, but only temporary.
- */
-#if DM_VERSION_MAJOR == 4 && defined(DM_COMPAT)
-const int _dm_compat = 1;
-#else
 const int _dm_compat = 0;
-#endif
-
 
 /* *INDENT-OFF* */
 static struct cmd_data _cmd_data_v4[] = {
@@ -133,7 +119,6 @@
 };
 /* *INDENT-ON* */
 
-#define ALIGNMENT_V1 sizeof(int)
 #define ALIGNMENT 8
 
 /* FIXME Rejig library to record & use errno instead */
@@ -471,409 +456,6 @@
 }
 
 /*
- * Protocol Version 1 compatibility functions.
- */
-
-#ifdef DM_COMPAT
-
-static void _dm_zfree_dmi_v1(struct dm_ioctl_v1 *dmi)
-{
-	if (dmi) {
-		memset(dmi, 0, dmi->data_size);
-		dm_free(dmi);
-	}
-}
-
-static int _dm_task_get_driver_version_v1(struct dm_task *dmt, char *version,
-					  size_t size)
-{
-	unsigned int *v;
-
-	if (!dmt->dmi.v1) {
-		version[0] = '\0';
-		return 0;
-	}
-
-	v = dmt->dmi.v1->version;
-	snprintf(version, size, "%u.%u.%u", v[0], v[1], v[2]);
-	return 1;
-}
-
-/* Unmarshall the target info returned from a status call */
-static int _unmarshal_status_v1(struct dm_task *dmt, struct dm_ioctl_v1 *dmi)
-{
-	char *outbuf = (char *) dmi + dmi->data_start;
-	char *outptr = outbuf;
-	int32_t i;
-	struct dm_target_spec_v1 *spec;
-
-	for (i = 0; i < dmi->target_count; i++) {
-		spec = (struct dm_target_spec_v1 *) outptr;
-
-		if (!dm_task_add_target(dmt, spec->sector_start,
-					(uint64_t) spec->length,
-					spec->target_type,
-					outptr + sizeof(*spec))) {
-			return 0;
-		}
-
-		outptr = outbuf + spec->next;
-	}
-
-	return 1;
-}
-
-static int _dm_format_dev_v1(char *buf, int bufsize, uint32_t dev_major,
-			     uint32_t dev_minor)
-{
-	int r;
-
-	if (bufsize < 8)
-		return 0;
-
-	r = snprintf(buf, bufsize, "%03x:%03x", dev_major, dev_minor);
-	if (r < 0 || r > bufsize - 1)
-		return 0;
-
-	return 1;
-}
-
-static int _dm_task_get_info_v1(struct dm_task *dmt, struct dm_info *info)
-{
-	if (!dmt->dmi.v1)
-		return 0;
-
-	memset(info, 0, sizeof(*info));
-
-	info->exists = dmt->dmi.v1->flags & DM_EXISTS_FLAG ? 1 : 0;
-	if (!info->exists)
-		return 1;
-
-	info->suspended = dmt->dmi.v1->flags & DM_SUSPEND_FLAG ? 1 : 0;
-	info->read_only = dmt->dmi.v1->flags & DM_READONLY_FLAG ? 1 : 0;
-	info->target_count = dmt->dmi.v1->target_count;
-	info->open_count = dmt->dmi.v1->open_count;
-	info->event_nr = 0;
-	info->major = MAJOR(dmt->dmi.v1->dev);
-	info->minor = MINOR(dmt->dmi.v1->dev);
-	info->live_table = 1;
-	info->inactive_table = 0;
-
-	return 1;
-}
-
-static const char *_dm_task_get_name_v1(const struct dm_task *dmt)
-{
-	return (dmt->dmi.v1->name);
-}
-
-static const char *_dm_task_get_uuid_v1(const struct dm_task *dmt)
-{
-	return (dmt->dmi.v1->uuid);
-}
-
-static struct dm_deps *_dm_task_get_deps_v1(struct dm_task *dmt)
-{
-	log_error("deps version 1 no longer supported by libdevmapper");
-	return NULL;
-}
-
-static struct dm_names *_dm_task_get_names_v1(struct dm_task *dmt)
-{
-	return (struct dm_names *) (((void *) dmt->dmi.v1) +
-				    dmt->dmi.v1->data_start);
-}
-
-static char *_add_target_v1(struct target *t, char *out, char *end)
-{
-	char *out_sp = out;
-	struct dm_target_spec_v1 sp;
-	size_t sp_size = sizeof(struct dm_target_spec_v1);
-	int len;
-
-	out += sp_size;
-	if (out >= end)
-		return_NULL;
-
-	sp.status = 0;
-	sp.sector_start = t->start;
-	sp.length = t->length;
-	strncpy(sp.target_type, t->type, sizeof(sp.target_type));
-
-	len = strlen(t->params);
-
-	if ((out + len + 1) >= end)
-		return_NULL;
-
-	strcpy(out, t->params);
-	out += len + 1;
-
-	/* align next block */
-	out = _align(out, ALIGNMENT_V1);
-
-	sp.next = out - out_sp;
-
-	memcpy(out_sp, &sp, sp_size);
-
-	return out;
-}
-
-static struct dm_ioctl_v1 *_flatten_v1(struct dm_task *dmt)
-{
-	const size_t min_size = 16 * 1024;
-	const int (*version)[3];
-
-	struct dm_ioctl_v1 *dmi;
-	struct target *t;
-	size_t len = sizeof(struct dm_ioctl_v1);
-	char *b, *e;
-	int count = 0;
-
-	for (t = dmt->head; t; t = t->next) {
-		len += sizeof(struct dm_target_spec_v1);
-		len += strlen(t->params) + 1 + ALIGNMENT_V1;
-		count++;
-	}
-
-	if (count && dmt->newname) {
-		log_error("targets and newname are incompatible");
-		return NULL;
-	}
-
-	if (dmt->newname)
-		len += strlen(dmt->newname) + 1;
-
-	/*
-	 * Give len a minimum size so that we have space to store
-	 * dependencies or status information.
-	 */
-	if (len < min_size)
-		len = min_size;
-
-	if (!(dmi = dm_malloc(len)))
-		return NULL;
-
-	memset(dmi, 0, len);
-
-	version = &_cmd_data_v1[dmt->type].version;
-
-	dmi->version[0] = (*version)[0];
-	dmi->version[1] = (*version)[1];
-	dmi->version[2] = (*version)[2];
-
-	dmi->data_size = len;
-	dmi->data_start = sizeof(struct dm_ioctl_v1);
-
-	if (dmt->dev_name)
-		strncpy(dmi->name, dmt->dev_name, sizeof(dmi->name));
-
-	if (dmt->type == DM_DEVICE_SUSPEND)
-		dmi->flags |= DM_SUSPEND_FLAG;
-	if (dmt->read_only)
-		dmi->flags |= DM_READONLY_FLAG;
-
-	if (dmt->minor >= 0) {
-		if (dmt->major <= 0) {
-			log_error("Missing major number for persistent device");
-			return NULL;
-		}
-		dmi->flags |= DM_PERSISTENT_DEV_FLAG;
-		dmi->dev = MKDEV(dmt->major, dmt->minor);
-	}
-
-	if (dmt->uuid)
-		strncpy(dmi->uuid, dmt->uuid, sizeof(dmi->uuid));
-
-	dmi->target_count = count;
-
-	b = (char *) (dmi + 1);
-	e = (char *) dmi + len;
-
-	for (t = dmt->head; t; t = t->next)
-		if (!(b = _add_target_v1(t, b, e))) {
-			log_error("Ran out of memory building ioctl parameter");
-			goto bad;
-		}
-
-	if (dmt->newname)
-		strcpy(b, dmt->newname);
-
-	return dmi;
-
-      bad:
-	_dm_zfree_dmi_v1(dmi);
-	return NULL;
-}
-
-static int _dm_names_v1(struct dm_ioctl_v1 *dmi)
-{
-	const char *dev_dir = dm_dir();
-	int r = 1, len;
-	const char *name;
-	struct dirent *dirent;
-	DIR *d;
-	struct dm_names *names, *old_names = NULL;
-	void *end = (void *) dmi + dmi->data_size;
-	struct stat buf;
-	char path[PATH_MAX];
-
-	log_warn("WARNING: Device list may be incomplete with interface "
-		  "version 1.");
-	log_warn("Please upgrade your kernel device-mapper driver.");
-
-	if (!(d = opendir(dev_dir))) {
-		log_sys_error("opendir", dev_dir);
-		return 0;
-	}
-
-	names = (struct dm_names *) ((void *) dmi + dmi->data_start);
-
-	names->dev = 0;		/* Flags no data */
-
-	while ((dirent = readdir(d))) {
-		name = dirent->d_name;
-
-		if (name[0] == '.' || !strcmp(name, "control"))
-			continue;
-
-		if (old_names)
-			old_names->next = (uint32_t) ((void *) names -
-						      (void *) old_names);
-		snprintf(path, sizeof(path), "%s/%s", dev_dir, name);
-		if (stat(path, &buf)) {
-			log_sys_error("stat", path);
-			continue;
-		}
-		if (!S_ISBLK(buf.st_mode))
-			continue;
-		names->dev = (uint64_t) buf.st_rdev;
-		names->next = 0;
-		len = strlen(name);
-		if (((char *) (names + 1) + len + 1) >= end) {
-			log_error("Insufficient buffer space for device list");
-			r = 0;
-			break;
-		}
-
-		strcpy(names->name, name);
-
-		old_names = names;
-		names = _align((char *) ++names + len + 1, ALIGNMENT);
-	}
-
-	if (closedir(d))
-		log_sys_error("closedir", dev_dir);
-
-	return r;
-}
-
-static int _dm_task_run_v1(struct dm_task *dmt)
-{
-	struct dm_ioctl_v1 *dmi;
-	unsigned int command;
-
-	dmi = _flatten_v1(dmt);
-	if (!dmi) {
-		log_error("Couldn't create ioctl argument.");
-		return 0;
-	}
-
-	if (!_open_control())
-		return 0;
-
-	if ((unsigned) dmt->type >=
-	    (sizeof(_cmd_data_v1) / sizeof(*_cmd_data_v1))) {
-		log_error(INTERNAL_ERROR "unknown device-mapper task %d",
-			  dmt->type);
-		goto bad;
-	}
-
-	command = _cmd_data_v1[dmt->type].cmd;
-
-	if (dmt->type == DM_DEVICE_TABLE)
-		dmi->flags |= DM_STATUS_TABLE_FLAG;
-
-	if (dmt->new_uuid) {
-		log_error("Changing UUID is not supported by kernel.");
-		goto bad;
-	}
-
-	log_debug("dm %s %s %s%s%s [%u]", _cmd_data_v1[dmt->type].name,
-		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
-		  dmt->newname ? dmt->newname : "",
-		  dmi->data_size);
-	if (dmt->type == DM_DEVICE_LIST) {
-		if (!_dm_names_v1(dmi))
-			goto bad;
-	} 
-#ifdef DM_IOCTLS
-	else if (ioctl(_control_fd, command, dmi) < 0) {
-		if (_log_suppress)
-			log_verbose("device-mapper: %s ioctl failed: %s", 
-				    _cmd_data_v1[dmt->type].name,
-				    strerror(errno));
-		else
-			log_error("device-mapper: %s ioctl failed: %s",
-				  _cmd_data_v1[dmt->type].name,
-				  strerror(errno));
-		goto bad;
-	}
-#else /* Userspace alternative for testing */
-#endif
-
-	if (dmi->flags & DM_BUFFER_FULL_FLAG)
-		/* FIXME Increase buffer size and retry operation (if query) */
-		log_error("WARNING: libdevmapper buffer too small for data");
-
-	switch (dmt->type) {
-	case DM_DEVICE_CREATE:
-		add_dev_node(dmt->dev_name, MAJOR(dmi->dev), MINOR(dmi->dev),
-			     dmt->uid, dmt->gid, dmt->mode, 0);
-		break;
-
-	case DM_DEVICE_REMOVE:
-		rm_dev_node(dmt->dev_name, 0);
-		break;
-
-	case DM_DEVICE_RENAME:
-		rename_dev_node(dmt->dev_name, dmt->newname, 0);
-		break;
-
-	case DM_DEVICE_MKNODES:
-		if (dmi->flags & DM_EXISTS_FLAG)
-			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
-				     MINOR(dmi->dev), dmt->uid,
-				     dmt->gid, dmt->mode, 0);
-		else
-			rm_dev_node(dmt->dev_name, 0);
-		break;
-
-	case DM_DEVICE_STATUS:
-	case DM_DEVICE_TABLE:
-		if (!_unmarshal_status_v1(dmt, dmi))
-			goto bad;
-		break;
-
-	case DM_DEVICE_SUSPEND:
-	case DM_DEVICE_RESUME:
-		dmt->type = DM_DEVICE_INFO;
-		if (!dm_task_run(dmt))
-			goto bad;
-		_dm_zfree_dmi_v1(dmi);	/* We'll use what info returned */
-		return 1;
-	}
-
-	dmt->dmi.v1 = dmi;
-	return 1;
-
-      bad:
-	_dm_zfree_dmi_v1(dmi);
-	return 0;
-}
-
-#endif
-
-/*
  * Protocol Version 4 functions.
  */
 
@@ -881,11 +463,6 @@
 {
 	unsigned *v;
 
-#ifdef DM_COMPAT
-	if (_dm_version == 1)
-		return _dm_task_get_driver_version_v1(dmt, version, size);
-#endif
-
 	if (!dmt->dmi.v4) {
 		version[0] = '\0';
 		return 0;
@@ -1033,11 +610,6 @@
 {
 	int r;
 
-#ifdef DM_COMPAT
-	if (_dm_version == 1)
-		return _dm_format_dev_v1(buf, bufsize, dev_major, dev_minor);
-#endif
-
 	if (bufsize < 8)
 		return 0;
 
@@ -1050,11 +622,6 @@
 
 int dm_task_get_info(struct dm_task *dmt, struct dm_info *info)
 {
-#ifdef DM_COMPAT
-	if (_dm_version == 1)
-		return _dm_task_get_info_v1(dmt, info);
-#endif
-
 	if (!dmt->dmi.v4)
 		return 0;
 
@@ -1084,12 +651,6 @@
 
 	*read_ahead = 0;
 
-#ifdef DM_COMPAT
-	/* Not supporting this */
-        if (_dm_version == 1)
-                return 1;
-#endif  
-
         if (!dmt->dmi.v4 || !(dmt->dmi.v4->flags & DM_EXISTS_FLAG))
 		return 0;
 
@@ -1107,42 +668,22 @@
 
 const char *dm_task_get_name(const struct dm_task *dmt)
 {
-#ifdef DM_COMPAT
-	if (_dm_version == 1)
-		return _dm_task_get_name_v1(dmt);
-#endif
-
 	return (dmt->dmi.v4->name);
 }
 
 const char *dm_task_get_uuid(const struct dm_task *dmt)
 {
-#ifdef DM_COMPAT
-	if (_dm_version == 1)
-		return _dm_task_get_uuid_v1(dmt);
-#endif
-
 	return (dmt->dmi.v4->uuid);
 }
 
 struct dm_deps *dm_task_get_deps(struct dm_task *dmt)
 {
-#ifdef DM_COMPAT
-	if (_dm_version == 1)
-		return _dm_task_get_deps_v1(dmt);
-#endif
-
 	return (struct dm_deps *) (((char *) dmt->dmi.v4) +
 				   dmt->dmi.v4->data_start);
 }
 
 struct dm_names *dm_task_get_names(struct dm_task *dmt)
 {
-#ifdef DM_COMPAT
-	if (_dm_version == 1)
-		return _dm_task_get_names_v1(dmt);
-#endif
-
 	return (struct dm_names *) (((char *) dmt->dmi.v4) +
 				    dmt->dmi.v4->data_start);
 }
@@ -2131,11 +1672,6 @@
 	int rely_on_udev;
 	int suspended_counter;
 
-#ifdef DM_COMPAT
-	if (_dm_version == 1)
-		return _dm_task_run_v1(dmt);
-#endif
-
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v4) / sizeof(*_cmd_data_v4))) {
 		log_error(INTERNAL_ERROR "unknown device-mapper task %d",
--- LVM2/libdm/ioctl/libdm-targets.h	2011/07/01 14:09:20	1.30
+++ LVM2/libdm/ioctl/libdm-targets.h	2011/08/09 17:56:48	1.31
@@ -20,7 +20,6 @@
 #include <sys/types.h>
 
 struct dm_ioctl;
-struct dm_ioctl_v1;
 
 struct target {
 	uint64_t start;
@@ -49,7 +48,6 @@
 	uint32_t read_ahead_flags;
 	union {
 		struct dm_ioctl *v4;
-		struct dm_ioctl_v1 *v1;
 	} dmi;
 	char *newname;
 	char *message;



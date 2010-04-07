From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 Apr 2010 15:57:22 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c ...
Message-ID: <20100407155722.6894.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-04-07 15:57:21

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 
	tools          : dmsetup.c 

Log message:
	Wipe dm-ioctl parameters in memory after use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.352&r2=1.353
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/WHATS_NEW_DM	2010/03/23 14:43:18	1.352
+++ LVM2/WHATS_NEW_DM	2010/04/07 15:57:20	1.353
@@ -1,5 +1,6 @@
 Version 1.02.46 - 
 ================================
+  Wipe memory buffers for dm-ioctl parameters before releaseing.
   Strictly require libudev if udev_sync is used.
   Add support for ioctl's DM_UEVENT_GENERATED_FLAG.
 
--- LVM2/libdm/ioctl/libdm-iface.c	2010/03/25 18:22:04	1.69
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/04/07 15:57:20	1.70
@@ -353,13 +353,29 @@
 #endif
 }
 
+static void _dm_zfree_string(char *string)
+{
+	if (string) {
+		memset(string, 0, strlen(string));
+		dm_free(string);
+	}
+}
+
+static void _dm_zfree_dmi(struct dm_ioctl *dmi)
+{
+	if (dmi) {
+		memset(dmi, 0, dmi->data_size);
+		dm_free(dmi);
+	}
+}
+
 void dm_task_destroy(struct dm_task *dmt)
 {
 	struct target *t, *n;
 
 	for (t = dmt->head; t; t = n) {
 		n = t->next;
-		dm_free(t->params);
+		_dm_zfree_string(t->params);
 		dm_free(t->type);
 		dm_free(t);
 	}
@@ -373,8 +389,7 @@
 	if (dmt->message)
 		dm_free(dmt->message);
 
-	if (dmt->dmi.v4)
-		dm_free(dmt->dmi.v4);
+	_dm_zfree_dmi(dmt->dmi.v4);
 
 	if (dmt->uuid)
 		dm_free(dmt->uuid);
@@ -388,6 +403,14 @@
 
 #ifdef DM_COMPAT
 
+static void _dm_zfree_dmi_v1(struct dm_ioctl_v1 *dmi)
+{
+	if (dmi) {
+		memset(dmi, 0, dmi->data_size);
+		dm_free(dmi);
+	}
+}
+
 static int _dm_task_get_driver_version_v1(struct dm_task *dmt, char *version,
 					  size_t size)
 {
@@ -494,13 +517,10 @@
 	struct dm_target_spec_v1 sp;
 	size_t sp_size = sizeof(struct dm_target_spec_v1);
 	int len;
-	const char no_space[] = "Ran out of memory building ioctl parameter";
 
 	out += sp_size;
-	if (out >= end) {
-		log_error(no_space);
-		return NULL;
-	}
+	if (out >= end)
+		return_NULL;
 
 	sp.status = 0;
 	sp.sector_start = t->start;
@@ -509,12 +529,9 @@
 
 	len = strlen(t->params);
 
-	if ((out + len + 1) >= end) {
-		log_error(no_space);
+	if ((out + len + 1) >= end)
+		return_NULL;
 
-		log_error("t->params= '%s'", t->params);
-		return NULL;
-	}
 	strcpy((char *) out, t->params);
 	out += len + 1;
 
@@ -600,8 +617,10 @@
 	e = (void *) ((char *) dmi + len);
 
 	for (t = dmt->head; t; t = t->next)
-		if (!(b = _add_target_v1(t, b, e)))
+		if (!(b = _add_target_v1(t, b, e))) {
+			log_error("Ran out of memory building ioctl parameter");
 			goto bad;
+		}
 
 	if (dmt->newname)
 		strcpy(b, dmt->newname);
@@ -609,7 +628,7 @@
 	return dmi;
 
       bad:
-	dm_free(dmi);
+	_dm_zfree_dmi_v1(dmi);
 	return NULL;
 }
 
@@ -762,7 +781,7 @@
 		dmt->type = DM_DEVICE_INFO;
 		if (!dm_task_run(dmt))
 			goto bad;
-		dm_free(dmi);	/* We'll use what info returned */
+		_dm_zfree_dmi_v1(dmi);	/* We'll use what info returned */
 		return 1;
 	}
 
@@ -770,7 +789,7 @@
 	return 1;
 
       bad:
-	dm_free(dmi);
+	_dm_zfree_dmi_v1(dmi);
 	return 0;
 }
 
@@ -1177,7 +1196,7 @@
 	return t;
 
       bad:
-	dm_free(t->params);
+	_dm_zfree_string(t->params);
 	dm_free(t->type);
 	dm_free(t);
 	return NULL;
@@ -1189,13 +1208,10 @@
 	struct dm_target_spec sp;
 	size_t sp_size = sizeof(struct dm_target_spec);
 	int len;
-	const char no_space[] = "Ran out of memory building ioctl parameter";
 
 	out += sp_size;
-	if (out >= end) {
-		log_error(no_space);
-		return NULL;
-	}
+	if (out >= end)
+		return_NULL;
 
 	sp.status = 0;
 	sp.sector_start = t->start;
@@ -1204,12 +1220,9 @@
 
 	len = strlen(t->params);
 
-	if ((out + len + 1) >= end) {
-		log_error(no_space);
+	if ((out + len + 1) >= end)
+		return_NULL;
 
-		log_error("t->params= '%s'", t->params);
-		return NULL;
-	}
 	strcpy((char *) out, t->params);
 	out += len + 1;
 
@@ -1403,8 +1416,10 @@
 	e = (void *) ((char *) dmi + len);
 
 	for (t = dmt->head; t; t = t->next)
-		if (!(b = _add_target(t, b, e)))
+		if (!(b = _add_target(t, b, e))) {
+			log_error("Ran out of memory building ioctl parameter");
 			goto bad;
+		}
 
 	if (dmt->newname)
 		strcpy(b, dmt->newname);
@@ -1421,7 +1436,7 @@
 	return dmi;
 
       bad:
-	dm_free(dmi);
+	_dm_zfree_dmi(dmi);
 	return NULL;
 }
 
@@ -1782,7 +1797,7 @@
 					  "failed: %s",
 				    	   _cmd_data_v4[dmt->type].name,
 					  strerror(errno));
-			dm_free(dmi);
+			_dm_zfree_dmi(dmi);
 			return NULL;
 		}
 	}
@@ -1853,7 +1868,7 @@
 		case DM_DEVICE_TABLE:
 		case DM_DEVICE_WAITEVENT:
 			_ioctl_buffer_double_factor++;
-			dm_free(dmi);
+			_dm_zfree_dmi(dmi);
 			goto repeat_ioctl;
 		default:
 			log_error("WARNING: libdevmapper buffer too small for data");
@@ -1911,13 +1926,12 @@
 	}
 
 	/* Was structure reused? */
-	if (dmt->dmi.v4)
-		dm_free(dmt->dmi.v4);
+	_dm_zfree_dmi(dmt->dmi.v4);
 	dmt->dmi.v4 = dmi;
 	return 1;
 
       bad:
-	dm_free(dmi);
+	_dm_zfree_dmi(dmi);
 	return 0;
 }
 
--- LVM2/tools/dmsetup.c	2010/03/23 14:43:19	1.136
+++ LVM2/tools/dmsetup.c	2010/04/07 15:57:20	1.137
@@ -266,6 +266,7 @@
 	r = 1;
 
       out:
+	memset(buffer, 0, buffer_size);
 #ifndef HAVE_GETLINE
 	dm_free(buffer);
 #else



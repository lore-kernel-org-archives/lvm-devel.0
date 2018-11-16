From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 18:33:00 -0500
Subject: master - libdm: print params only for ioctls using them
Message-ID: <201811162333.wAGNX09G015857@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43f8da76997a22be123e97b6d0f357d6ec2d0c7c
Commit:        43f8da76997a22be123e97b6d0f357d6ec2d0c7c
Parent:        1ae5bf2b833a5d55cf97de1619cc820d4e8c394f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 15:57:15 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 00:30:50 2018 +0100

libdm: print params only for ioctls using them

When preparing ioctl buffer and flatting all parameters,
add table parameters only to ioctl that do process them.

Note: list of ioctl should be kept in sync with kernel code.
---
 WHATS_NEW_DM                      |    1 +
 device_mapper/ioctl/libdm-iface.c |   37 +++++++++++++++++++++++++++++--------
 libdm/ioctl/libdm-iface.c         |   37 +++++++++++++++++++++++++++++--------
 3 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c19d9a8..aa1734c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.155 - 
 ====================================
+  Enhance ioctl flattening and add parameters only when needed.
   Add DM_DEVICE_ARM_POLL for API completness matching kernel.
   Do not add parameters for RESUME with DM_DEVICE_CREATE dm task.
 
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 31a4bc0..1321dc0 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -1085,6 +1085,22 @@ static int _lookup_dev_name(uint64_t dev, char *buf, size_t len)
 	return r;
 }
 
+static int _add_params(int type)
+{
+	switch (type) {
+	case DM_DEVICE_REMOVE_ALL:
+	case DM_DEVICE_CREATE:
+	case DM_DEVICE_REMOVE:
+	case DM_DEVICE_SUSPEND:
+	case DM_DEVICE_STATUS:
+	case DM_DEVICE_CLEAR:
+	case DM_DEVICE_ARM_POLL:
+		return 0; /* IOCTL_FLAGS_NO_PARAMS in drivers/md/dm-ioctl.c */
+	default:
+		return 1;
+	}
+}
+
 static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 {
 	const size_t min_size = 16 * 1024;
@@ -1097,11 +1113,15 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	char *b, *e;
 	int count = 0;
 
-	for (t = dmt->head; t; t = t->next) {
-		len += sizeof(struct dm_target_spec);
-		len += strlen(t->params) + 1 + ALIGNMENT;
-		count++;
-	}
+	if (_add_params(dmt->type))
+		for (t = dmt->head; t; t = t->next) {
+			len += sizeof(struct dm_target_spec);
+			len += strlen(t->params) + 1 + ALIGNMENT;
+			count++;
+		}
+	else if (dmt->head)
+		log_debug_activation(INTERNAL_ERROR "dm '%s' ioctl should not define parameters.",
+				     _cmd_data_v4[dmt->type].name);
 
 	if (count && (dmt->sector || dmt->message)) {
 		log_error("targets and message are incompatible");
@@ -1251,9 +1271,10 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	b = (char *) (dmi + 1);
 	e = (char *) dmi + len;
 
-	for (t = dmt->head; t; t = t->next)
-		if (!(b = _add_target(t, b, e)))
-			goto_bad;
+	if (_add_params(dmt->type))
+		for (t = dmt->head; t; t = t->next)
+			if (!(b = _add_target(t, b, e)))
+				goto_bad;
 
 	if (dmt->newname)
 		strcpy(b, dmt->newname);
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 6e73b1d..002669e 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1097,6 +1097,22 @@ static int _lookup_dev_name(uint64_t dev, char *buf, size_t len)
 	return r;
 }
 
+static int _add_params(int type)
+{
+	switch (type) {
+	case DM_DEVICE_REMOVE_ALL:
+	case DM_DEVICE_CREATE:
+	case DM_DEVICE_REMOVE:
+	case DM_DEVICE_SUSPEND:
+	case DM_DEVICE_STATUS:
+	case DM_DEVICE_CLEAR:
+	case DM_DEVICE_ARM_POLL:
+		return 0; /* IOCTL_FLAGS_NO_PARAMS in drivers/md/dm-ioctl.c */
+	default:
+		return 1;
+	}
+}
+
 static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 {
 	const size_t min_size = 16 * 1024;
@@ -1109,11 +1125,15 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	char *b, *e;
 	int count = 0;
 
-	for (t = dmt->head; t; t = t->next) {
-		len += sizeof(struct dm_target_spec);
-		len += strlen(t->params) + 1 + ALIGNMENT;
-		count++;
-	}
+	if (_add_params(dmt->type))
+		for (t = dmt->head; t; t = t->next) {
+			len += sizeof(struct dm_target_spec);
+			len += strlen(t->params) + 1 + ALIGNMENT;
+			count++;
+		}
+	else if (dmt->head)
+		log_debug_activation(INTERNAL_ERROR "dm '%s' ioctl should not define parameters.",
+				     _cmd_data_v4[dmt->type].name);
 
 	if (count && (dmt->sector || dmt->message)) {
 		log_error("targets and message are incompatible");
@@ -1263,9 +1283,10 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	b = (char *) (dmi + 1);
 	e = (char *) dmi + len;
 
-	for (t = dmt->head; t; t = t->next)
-		if (!(b = _add_target(t, b, e)))
-			goto_bad;
+	if (_add_params(dmt->type))
+		for (t = dmt->head; t; t = t->next)
+			if (!(b = _add_target(t, b, e)))
+				goto_bad;
 
 	if (dmt->newname)
 		strcpy(b, dmt->newname);



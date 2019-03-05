From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:43 -0500
Subject: stable-2.02 - libdm: print params only for ioctls using them
Message-ID: <201903051353.x25Drh4C006785@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=40f57155a308bcefedb1ec6dc482b8c719b56750
Commit:        40f57155a308bcefedb1ec6dc482b8c719b56750
Parent:        1bef4dfab39c9cef28df979a2b092a0dff79b2cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 15:57:15 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:47:50 2019 +0100

libdm: print params only for ioctls using them

When preparing ioctl buffer and flatting all parameters,
add table parameters only to ioctl that do process them.

Note: list of ioctl should be kept in sync with kernel code.
(cherry picked from commit 43f8da76997a22be123e97b6d0f357d6ec2d0c7c)

Conflicts:
	WHATS_NEW_DM
	device_mapper/ioctl/libdm-iface.c
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |   37 +++++++++++++++++++++++++++++--------
 2 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ff92031..f92e4d8 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.156 - 
 =====================================
+  Enhance ioctl flattening and add parameters only when needed.
   Add DM_DEVICE_ARM_POLL for API completness matching kernel.
 
 Version 1.02.154 - 07th December 2018
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 863e812..3a48c9b 100644
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



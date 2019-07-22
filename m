From: Lidong Zhong <lidong.zhong@suse.com>
Date: Mon, 22 Jul 2019 02:59:38 +0000
Subject: [PATCH] libdm: _dm_task_set_name_from_path: always use major/minor
Message-ID: <20190722025921.5554-1-lidong.zhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Martin Wilck <mwilck@suse.com>

libdm assumes that names of symlinks under /dev/mapper uniquely correspond
to device-mapper names. If this is not the case (e.g. if additional symlinks
under /dev/mapper have been created by custom udev rules), this algorithm
may fail, as the names of the extra symlinks don't match the dm name of the
device. The error message is then a rather misleading "Device does not
exist" (the device _does_ actually exist, it just has a different dm
name). Because the algorithm takes the first match in /dev/mapper, depending
on sort order, this first match may be the "wrong" one of multiple symlinks,
and thus this error can occur for an innocent "dmsetup info /dev/dm-1"
command.

The current algorithm checks the major/minor number anyway. Therefore, the
assumption about symlink names under /dev/mapper can be easily dropped by
always using the major/minor number rather than the name for device lookup.
In theory, this approach might even be used if there were no symlinks under
/dev/mapper at all matching a given device, but this patch refrains from doing
so for compatibility reasons.

This patch changes the user-visible behavior only where multiple symlinks are
present. Under normal conditions (unique names under /dev/mapper), it yields
the same results as before even for pathological invocations such as "dmsetup
info -j 254 -m 7 /dev/dm-6".

Signed-off-by: Martin Wilck <mwilck@suse.com>
---
 libdm/libdm-common.c | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 40b366b..cbc454a 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -343,7 +343,7 @@ struct dm_task *dm_task_create(int type)
 /*
  * Find the name associated with a given device number by scanning _dm_dir.
  */
-static int _find_dm_name_of_device(dev_t st_rdev, char *buf, size_t buf_len)
+static int _find_dm_name_of_device(dev_t st_rdev)
 {
 	const char *name;
 	char path[PATH_MAX];
@@ -373,7 +373,6 @@ static int _find_dm_name_of_device(dev_t st_rdev, char *buf, size_t buf_len)
 			continue;
 
 		if (st.st_rdev == st_rdev) {
-			strncpy(buf, name, buf_len);
 			r = 1;
 			break;
 		}
@@ -605,7 +604,7 @@ static int _dm_task_set_name_from_path(struct dm_task *dmt, const char *path,
 {
 	char buf[PATH_MAX];
 	struct stat st1, st2;
-	const char *final_name = NULL;
+	int found = 0;
 	size_t len;
 
 	if (dmt->type == DM_DEVICE_CREATE) {
@@ -625,7 +624,7 @@ static int _dm_task_set_name_from_path(struct dm_task *dmt, const char *path,
 		}
 
 		if (!stat(buf, &st2) && (st1.st_rdev == st2.st_rdev))
-			final_name = name;
+			found = 1;
 	} else {
 		/* Not found. */
 		/* If there is exactly one '/' try a prefix of /dev */
@@ -642,24 +641,24 @@ static int _dm_task_set_name_from_path(struct dm_task *dmt, const char *path,
 			log_error("Device %s not found", path);
 			return 0;
 		}
-		/* Found */
+		found = 1;
 	}
 
 	/*
 	 * If we don't have the dm name yet, Call _find_dm_name_of_device() to
 	 * scan _dm_dir for a match.
 	 */
-	if (!final_name) {
-		if (_find_dm_name_of_device(st1.st_rdev, buf, sizeof(buf)))
-			final_name = buf;
-		else {
-			log_error("Device %s not found", name);
-			return 0;
-		}
+	if (!found)
+		found = _find_dm_name_of_device(st1.st_rdev);
+
+	if (!found) {
+		log_error("Device %s not found", name);
+		return 0;
 	}
 
-	/* This is an already existing path - do not mangle! */
-	return _dm_task_set_name(dmt, final_name, DM_STRING_MANGLING_NONE);
+	/* Don't allow fallback here - input major  / minor should fit */
+	return dm_task_set_major_minor(dmt, MAJOR(st1.st_rdev),
+				       MINOR(st1.st_rdev), 0);
 }
 
 int dm_task_set_name(struct dm_task *dmt, const char *name)
-- 
2.21.0



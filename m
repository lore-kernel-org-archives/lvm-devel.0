From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 29 Jul 2015 11:29:36 +0000 (UTC)
Subject: master - dmsetup: Accept vg/lv name format.
Message-ID: <20150729112936.ADBC5601E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5491d36982c7afe10f655ad0592fb20f9a331fd
Commit:        a5491d36982c7afe10f655ad0592fb20f9a331fd
Parent:        ca0d9a70d15ca44c1d0d6f65a277c5e2ac7dd161
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 29 12:24:36 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 29 12:24:36 2015 +0100

dmsetup: Accept vg/lv name format.

If there is exactly one / which is not the first character, check
for /dev/vg/lv (as dm_dir()/../$name i.e. /dev/mapper/../vg/lv.)
---
 WHATS_NEW            |    1 +
 libdm/libdm-common.c |   60 ++++++++++++++++++++++++++++++++++---------------
 2 files changed, 42 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 436d1d9..1d8f472 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.127 - 
 =================================
+  Recognise vg/lv name format in dmsetup.
   Fix regression in cache causing some PVs to bypass filters (2.02.105).
 
 Version 2.02.126 - 24th July 2015
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index b56643f..0811db0 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -546,35 +546,57 @@ static int _dm_task_set_name_from_path(struct dm_task *dmt, const char *path,
 {
 	char buf[PATH_MAX];
 	struct stat st1, st2;
-	const char *final_name;
+	const char *final_name = NULL;
+	size_t len;
 
 	if (dmt->type == DM_DEVICE_CREATE) {
 		log_error("Name \"%s\" invalid. It contains \"/\".", path);
 		return 0;
 	}
 
-	if (stat(path, &st1)) {
-		log_error("Device %s not found", path);
-		return 0;
+	if (!stat(path, &st1)) {
+		/*
+		 * Found directly.
+		 * If supplied path points to same device as last component
+		 * under /dev/mapper, use that name directly.  
+		 */
+		if (dm_snprintf(buf, sizeof(buf), "%s/%s", _dm_dir, name) == -1) {
+			log_error("Couldn't create path for %s", name);
+			return 0;
+		}
+
+		if (!stat(buf, &st2) && (st1.st_rdev == st2.st_rdev))
+			final_name = name;
+	} else {
+		/* Not found. */
+		/* If there is exactly one '/' try a prefix of /dev */
+		if ((len = strlen(path)) < 3 || path[0] == '/' ||
+		    dm_count_chars(path, len, '/') != 1) {
+			log_error("Device %s not found", path);
+			return 0;
+		}
+		if (dm_snprintf(buf, sizeof(buf), "%s/../%s", _dm_dir, path) == -1) {
+			log_error("Couldn't create /dev path for %s", path);
+			return 0;
+		}
+		if (stat(buf, &st1)) {
+			log_error("Device %s not found", path);
+			return 0;
+		}
+		/* Found */
 	}
 
 	/*
-	 * If supplied path points to same device as last component
-	 * under /dev/mapper, use that name directly.  Otherwise call
-	 * _find_dm_name_of_device() to scan _dm_dir for a match.
+	 * If we don't have the dm name yet, Call _find_dm_name_of_device() to
+	 * scan _dm_dir for a match.
 	 */
-	if (dm_snprintf(buf, sizeof(buf), "%s/%s", _dm_dir, name) == -1) {
-		log_error("Couldn't create path for %s", name);
-		return 0;
-	}
-
-	if (!stat(buf, &st2) && (st1.st_rdev == st2.st_rdev))
-		final_name = name;
-	else if (_find_dm_name_of_device(st1.st_rdev, buf, sizeof(buf)))
-		final_name = buf;
-	else {
-		log_error("Device %s not found", name);
-		return 0;
+	if (!final_name) {
+		if (_find_dm_name_of_device(st1.st_rdev, buf, sizeof(buf)))
+			final_name = buf;
+		else {
+			log_error("Device %s not found", name);
+			return 0;
+		}
 	}
 
 	/* This is an already existing path - do not mangle! */



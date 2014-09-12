From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Sep 2014 13:29:04 +0000 (UTC)
Subject: master - libdm: fix dm_is_dm_major to not issue error about missing /proc lines for dm module.
Message-ID: <20140912132904.1B38A60364@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5895657b5941f78969ab0c1a97cade5084c95166
Commit:        5895657b5941f78969ab0c1a97cade5084c95166
Parent:        25ae9383bbdec063257f67ac2dee8defd24aa2cf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 12 15:17:57 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 12 15:28:51 2014 +0200

libdm: fix dm_is_dm_major to not issue error about missing /proc lines for dm module.

This is probably better approach than 3880ca5ecad1761bd13a190c58f8f85fdd7cd0e1.

If dm module is not loaded during dm_is_dm_major call, there are no
lines for dm in /proc/devices, of course. Normally, dm_is_dm_major
is called to check existing devices, hence if module is not loaded,
we can expect there's no DM device present at the same time so we
can directly return 0 here (meaning the major number being inspected
is not dm device's one).

See also https://bugzilla.redhat.com/show_bug.cgi?id=1059711.
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |   52 +++++++++++++++++++++++++++++++++-----------
 2 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4effe09..d60b35f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.91 - 
 ====================================
+  Fix dm_is_dm_major to not issue error about missing /proc lines for dm module.
 
 Version 1.02.90 - 1st September 2014
 ====================================
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 7d50f3a..fb9bafd 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -165,9 +165,13 @@ static int _uname(void)
 /*
  * Set number to NULL to populate _dm_bitset - otherwise first
  * match is returned.
+ * Returns:
+ * 	0 - error
+ * 	1 - success - number found
+ * 	2 - success - number not found (only if require_module_loaded=0)
  */
 static int _get_proc_number(const char *file, const char *name,
-			    uint32_t *number)
+			    uint32_t *number, int require_module_loaded)
 {
 	FILE *fl;
 	char nm[256];
@@ -199,8 +203,11 @@ static int _get_proc_number(const char *file, const char *name,
 	free(line);
 
 	if (number) {
-		log_error("%s: No entry for %s found", file, name);
-		return 0;
+		if (require_module_loaded) {
+			log_error("%s: No entry for %s found", file, name);
+			return 0;
+		} else
+			return 2;
 	}
 
 	return 1;
@@ -208,8 +215,8 @@ static int _get_proc_number(const char *file, const char *name,
 
 static int _control_device_number(uint32_t *major, uint32_t *minor)
 {
-	if (!_get_proc_number(PROC_DEVICES, MISC_NAME, major) ||
-	    !_get_proc_number(PROC_MISC, DM_NAME, minor)) {
+	if (!_get_proc_number(PROC_DEVICES, MISC_NAME, major, 1) ||
+	    !_get_proc_number(PROC_MISC, DM_NAME, minor, 1)) {
 		*major = 0;
 		return 0;
 	}
@@ -296,8 +303,15 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 /*
  * FIXME Update bitset in long-running process if dm claims new major numbers.
  */
-static int _create_dm_bitset(void)
+/*
+ * If require_module_loaded=0, caller is responsible to check
+ * whether _dm_device_major or _dm_bitset is really set. If
+ * it's not, it means
+ */
+static int _create_dm_bitset(int require_module_loaded)
 {
+	int r;
+
 #ifdef DM_IOCTLS
 	if (_dm_bitset || _dm_device_major)
 		return 1;
@@ -315,7 +329,8 @@ static int _create_dm_bitset(void)
 		_dm_multiple_major_support = 0;
 
 	if (!_dm_multiple_major_support) {
-		if (!_get_proc_number(PROC_DEVICES, DM_NAME, &_dm_device_major))
+		if (!_get_proc_number(PROC_DEVICES, DM_NAME, &_dm_device_major,
+				      require_module_loaded))
 			return 0;
 		return 1;
 	}
@@ -324,10 +339,15 @@ static int _create_dm_bitset(void)
 	if (!(_dm_bitset = dm_bitset_create(NULL, NUMBER_OF_MAJORS)))
 		return 0;
 
-	if (!_get_proc_number(PROC_DEVICES, DM_NAME, NULL)) {
+	r = _get_proc_number(PROC_DEVICES, DM_NAME, NULL, require_module_loaded);
+	if (!r || r == 2) {
 		dm_bitset_destroy(_dm_bitset);
 		_dm_bitset = NULL;
-		return 0;
+		/*
+		 * It's not an error if we didn't find anything and we
+		 * didn't require module to be loaded at the same time.
+		 */
+		return r == 2;
 	}
 
 	return 1;
@@ -338,13 +358,19 @@ static int _create_dm_bitset(void)
 
 int dm_is_dm_major(uint32_t major)
 {
-	if (!_create_dm_bitset())
+	if (!_create_dm_bitset(0))
 		return 0;
 
-	if (_dm_multiple_major_support)
+	if (_dm_multiple_major_support) {
+		if (!_dm_bitset)
+			return 0;
 		return dm_bit(_dm_bitset, major) ? 1 : 0;
-	else
+	}
+	else {
+		if (!_dm_device_major)
+			return 0;
 		return (major == _dm_device_major) ? 1 : 0;
+	}
 }
 
 static void _close_control_fd(void)
@@ -406,7 +432,7 @@ static int _open_control(void)
 	if (!_open_and_assign_control_fd(control))
 		goto_bad;
 	
-	if (!_create_dm_bitset()) {
+	if (!_create_dm_bitset(1)) {
 		log_error("Failed to set up list of device-mapper major numbers");
 		return 0;
 	}



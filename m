From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:49 +0000 (UTC)
Subject: dev-mornfall-lvmcache - dmeventd: use dm_mountinfo_read
Message-ID: <20130605120349.8B6C36116D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=810bc4f8c1f2f28bf78ac538486d63317ba9b079
Commit:        810bc4f8c1f2f28bf78ac538486d63317ba9b079
Parent:        7fab9a9dda12a0d40688de5a7b57f6d7234e0f2c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 20 13:10:07 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 20 16:47:33 2013 +0200

dmeventd: use dm_mountinfo_read

Reuse mountinfo reading code from libdm.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |  115 +++++++-----------------
 1 files changed, 34 insertions(+), 81 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 95ab27a..f32424a 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -53,53 +53,6 @@ struct dso_state {
 #  define MKDEV(x,y) makedev((x),(y))
 #endif
 
-/* Macros to make string defines */
-#define TO_STRING_EXP(A) #A
-#define TO_STRING(A) TO_STRING_EXP(A)
-
-static int _is_octal(int a)
-{
-	return (((a) & ~7) == '0');
-}
-
-/* Convert mangled mountinfo into normal ASCII string */
-static void _unmangle_mountinfo_string(const char *src, char *buf)
-{
-	if (!src)
-		return;
-
-	while (*src) {
-		if ((*src == '\\') &&
-		    _is_octal(src[1]) && _is_octal(src[2]) && _is_octal(src[3])) {
-			*buf++ = 64 * (src[1] & 7) + 8 * (src[2] & 7) + (src[3] & 7);
-			src += 4;
-		} else
-			*buf++ = *src++;
-	}
-	*buf = '\0';
-}
-
-/* Parse one line of mountinfo */
-static int _parse_mountinfo_line(const char *line, unsigned *maj, unsigned *min, char *buf)
-{
-	char root[PATH_MAX + 1];
-	char target[PATH_MAX + 1];
-
-	/* TODO: maybe detect availability of  %ms  glib support ? */
-	if (sscanf(line, "%*u %*u %u:%u %" TO_STRING(PATH_MAX)
-		   "s %" TO_STRING(PATH_MAX) "s",
-		   maj, min, root, target) < 4)
-		return 0;
-
-	_unmangle_mountinfo_string(target, buf);
-
-#if THIN_DEBUG
-	syslog(LOG_DEBUG, "Mounted  %u:%u  %s", *maj, *min, buf);
-#endif
-
-	return 1;
-}
-
 /* Get dependencies for device, and try to find matching device */
 static int _has_deps(const char *name, int tp_major, int tp_minor, int *dev_minor)
 {
@@ -238,62 +191,62 @@ static int _run(const char *cmd, ...)
 	return 1; /* all good */
 }
 
+struct mountinfo_s {
+	struct dm_info info;
+	dm_bitset_t minors; /* Bitset for active thin pool minors */
+	const char *device;
+};
+
+static int _umount_device(char *buffer, unsigned major, unsigned minor,
+			  char *target, void *cb_data)
+{
+	struct mountinfo_s *data = cb_data;
+
+	if ((major == data->info.major) && dm_bit(data->minors, minor)) {
+		syslog(LOG_INFO, "Unmounting thin volume %s from %s.\n",
+		       data->device, target);
+		if (!_run(UMOUNT_COMMAND, "-fl", target, NULL))
+			syslog(LOG_ERR, "Failed to umount thin %s from %s: %s.\n",
+			       data->device, target, strerror(errno));
+	}
+
+	return 1;
+}
+
 /*
  * Find all thin pool users and try to umount them.
  * TODO: work with read-only thin pool support
  */
 static void _umount(struct dm_task *dmt, const char *device)
 {
-	static const char mountinfo[] = "/proc/self/mountinfo";
 	static const size_t MINORS = 4096;
-	FILE *minfo = NULL;
-	char buffer[4096];
-	char target[PATH_MAX];
-	struct dm_info info;
-	unsigned maj, min;
-	dm_bitset_t minors; /* Bitset for active thin pool minors */
+	struct mountinfo_s data = {
+		.device = device,
+	};
 
-	if (!dm_task_get_info(dmt, &info))
+	if (!dm_task_get_info(dmt, &data.info))
 		return;
 
 	dmeventd_lvm2_unlock();
 
-	if (!(minors = dm_bitset_create(NULL, MINORS))) {
+	if (!(data.minors = dm_bitset_create(NULL, MINORS))) {
 		syslog(LOG_ERR, "Failed to allocate bitset. Not unmounting %s.\n", device);
 		goto out;
 	}
 
-	if (!(minfo = fopen(mountinfo, "r"))) {
-		syslog(LOG_ERR, "Could not read %s. Not umounting %s.\n", mountinfo, device);
-		goto out;
-	}
-
-	if (!_find_all_devs(minors, info.major, info.minor)) {
+	if (!_find_all_devs(data.minors, data.info.major, data.info.minor)) {
 		syslog(LOG_ERR, "Failed to detect mounted volumes for %s.\n", device);
 		goto out;
 	}
 
-	while (!feof(minfo)) {
-		/* read mountinfo line */
-		if (!fgets(buffer, sizeof(buffer), minfo))
-			break; /* eof, likely */
-
-		if (_parse_mountinfo_line(buffer, &maj, &min, target) &&
-		    (maj == info.major) && dm_bit(minors, min)) {
-			syslog(LOG_INFO, "Unmounting thin volume %s from %s.\n",
-			       device, target);
-			if (!_run(UMOUNT_COMMAND, "-fl", target, NULL))
-				syslog(LOG_ERR, "Failed to umount thin %s from %s: %s.\n",
-				       device, target, strerror(errno));
-		}
+	if (!dm_mountinfo_read(_umount_device, &data)) {
+		syslog(LOG_ERR, "Could not parse mountinfo file.\n");
+		goto out;
 	}
 
 out:
-	if (minfo && fclose(minfo))
-		syslog(LOG_ERR, "Failed to close %s\n", mountinfo);
-
-	if (minors)
-		dm_bitset_destroy(minors);
+	if (data.minors)
+		dm_bitset_destroy(data.minors);
 	dmeventd_lvm2_lock();
 }
 



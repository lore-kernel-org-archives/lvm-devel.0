From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:23 -0400
Subject: master - cleanup: call uname once
Message-ID: <201804201102.w3KB2NXM031324@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1287edf6264b910a1f0d6dfbd809c2b51fe3ff2a
Commit:        1287edf6264b910a1f0d6dfbd809c2b51fe3ff2a
Parent:        d81e3f9b067f9eb44122a8637966bfa838716135
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 27 21:07:13 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:16:58 2018 +0200

cleanup: call uname once

Call uname() once and keep result for mirror use-case.
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |   19 +++++++++++++++----
 libdm/libdm-common.h      |    2 ++
 libdm/libdm-deptree.c     |   16 +++-------------
 4 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d3cdf7d..8fc3230 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 - 
 =====================================
+  Reuse uname() result for mirror target.
   Recognize also mounted btrfs through dm_device_has_mounted_fs().
   Add missing log_error() into dm_stats_populate() returning 0.
   Avoid calling dm_stats_populat() for DM devices without any stats regions.
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 3965be6..769b69c 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -133,9 +133,9 @@ static char *_align(char *ptr, unsigned int a)
 }
 
 #ifdef DM_IOCTLS
-static int _kernel_major = 0;
-static int _kernel_minor = 0;
-static int _kernel_release = 0;
+static unsigned _kernel_major = 0;
+static unsigned _kernel_minor = 0;
+static unsigned _kernel_release = 0;
 
 static int _uname(void)
 {
@@ -151,7 +151,7 @@ static int _uname(void)
 		return 0;
 	}
 
-	parts = sscanf(_uts.release, "%d.%d.%d",
+	parts = sscanf(_uts.release, "%u.%u.%u",
 		       &_kernel_major, &_kernel_minor, &_kernel_release);
 
 	/* Kernels with a major number of 2 always had 3 parts. */
@@ -164,6 +164,17 @@ static int _uname(void)
 	return 1;
 }
 
+int get_uname_version(unsigned *major, unsigned *minor, unsigned *release)
+{
+	if (!_uname())
+		return_0;
+
+	*major = _kernel_major;
+	*minor = _kernel_minor;
+	*release = _kernel_release;
+
+	return 1;
+}
 /*
  * Set number to NULL to populate _dm_bitset - otherwise first
  * match is returned.
diff --git a/libdm/libdm-common.h b/libdm/libdm-common.h
index 4dc1870..010d876 100644
--- a/libdm/libdm-common.h
+++ b/libdm/libdm-common.h
@@ -53,4 +53,6 @@ void dec_suspended(void);
 
 int parse_thin_pool_status(const char *params, struct dm_status_thin_pool *s);
 
+int get_uname_version(unsigned *major, unsigned *minor, unsigned *release);
+
 #endif
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 98dda44..ab05456 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2105,24 +2105,14 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 	int block_on_error = 0;
 	int handle_errors = 0;
 	int dm_log_userspace = 0;
-	struct utsname uts;
 	unsigned log_parm_count;
-	int pos = 0, parts;
+	int pos = 0;
 	char logbuf[DM_FORMAT_DEV_BUFSIZE];
 	const char *logtype;
 	unsigned kmaj = 0, kmin = 0, krel = 0;
 
-	if (uname(&uts) == -1) {
-		log_error("Cannot read kernel release version.");
-		return 0;
-	}
-
-	/* Kernels with a major number of 2 always had 3 parts. */
-	parts = sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel);
-	if (parts < 1 || (kmaj < 3 && parts < 3)) {
-		log_error("Wrong kernel release version %s.", uts.release);
-		return 0;
-	}
+	if (!get_uname_version(&kmaj, &kmin, &krel))
+		return_0;
 
 	if ((seg->flags & DM_BLOCK_ON_ERROR)) {
 		/*



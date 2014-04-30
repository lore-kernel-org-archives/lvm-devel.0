From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:27:55 +0000 (UTC)
Subject: master - libdm: cleanup complation without DM_IOCTLS
Message-ID: <20140430082755.01F1460DAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=905d4cda7ae17aa1eb8f8d0e85b9d577e650bb60
Commit:        905d4cda7ae17aa1eb8f8d0e85b9d577e650bb60
Parent:        ad77fb50bd568718b12336ca0f0c81e3730b6237
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 23:40:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:29 2014 +0200

libdm: cleanup complation without DM_IOCTLS

---
 libdm/ioctl/libdm-iface.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 73cda17..345651b 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -68,10 +68,6 @@ static unsigned _dm_version_minor = 0;
 static unsigned _dm_version_patchlevel = 0;
 static int _log_suppress = 0;
 
-static int _kernel_major = 0;
-static int _kernel_minor = 0;
-static int _kernel_release = 0;
-
 /*
  * If the kernel dm driver only supports one major number
  * we store it in _dm_device_major.  Otherwise we indicate
@@ -133,6 +129,11 @@ static char *_align(char *ptr, unsigned int a)
 	return (char *) (((unsigned long) ptr + agn) & ~agn);
 }
 
+#ifdef DM_IOCTLS
+static int _kernel_major = 0;
+static int _kernel_minor = 0;
+static int _kernel_release = 0;
+
 static int _uname(void)
 {
 	static int _uts_set = 0;
@@ -148,9 +149,7 @@ static int _uname(void)
 	}
 
 	parts = sscanf(_uts.release, "%d.%d.%d",
-			&_kernel_major,
-			&_kernel_minor,
-			&_kernel_release);
+		       &_kernel_major, &_kernel_minor, &_kernel_release);
 
 	/* Kernels with a major number of 2 always had 3 parts. */
 	if (parts < 1 || (_kernel_major < 3 && parts < 3)) {
@@ -162,7 +161,6 @@ static int _uname(void)
 	return 1;
 }
 
-#ifdef DM_IOCTLS
 /*
  * Set number to NULL to populate _dm_bitset - otherwise first
  * match is returned.
@@ -357,6 +355,7 @@ static void _close_control_fd(void)
 	}
 }
 
+#ifdef DM_IOCTLS
 static int _open_and_assign_control_fd(const char *control)
 {
 	if ((_control_fd = open(control, O_RDWR)) < 0) {
@@ -366,6 +365,7 @@ static int _open_and_assign_control_fd(const char *control)
 
 	return 1;
 }
+#endif
 
 static int _open_control(void)
 {
@@ -1285,6 +1285,7 @@ static int _udev_complete(struct dm_task *dmt)
 	return 1;
 }
 
+#ifdef DM_IOCTLS
 static int _check_uevent_generated(struct dm_ioctl *dmi)
 {
 	if (!dm_check_version() ||
@@ -1295,6 +1296,7 @@ static int _check_uevent_generated(struct dm_ioctl *dmi)
 
 	return dmi->flags & DM_UEVENT_GENERATED_FLAG;
 }
+#endif
 
 static int _create_and_load_v4(struct dm_task *dmt)
 {
@@ -1598,6 +1600,7 @@ static const char *_sanitise_message(char *message)
 	return sanitised_message;
 }
 
+#ifdef DM_IOCTLS
 static int _do_dm_ioctl_unmangle_string(char *str, const char *str_name,
 					char *buf, size_t buf_size,
 					dm_string_mangling_t mode)
@@ -1658,6 +1661,7 @@ static int _dm_ioctl_unmangle_uuids(int type, struct dm_ioctl *dmi)
 
 	return 1;
 }
+#endif
 
 static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				     unsigned buffer_repeat_count,
@@ -1794,6 +1798,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 		goto error;
 
 #else /* Userspace alternative for testing */
+	goto error;
 #endif
 	return dmi;
 



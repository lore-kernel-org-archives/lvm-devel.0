From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 02 Aug 2010 21:24:57 +0200
Subject: [PATCH] Add check for semaphore kernel support
Message-ID: <4C571B89.2030309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We also need to check for kernel semaphore support (part of System V IPC,
kernel's CONFIG_SYSVIPC). If not compiled in the kernel, we need to disable
udev synchronisation code and show a warning message at least (so one knows
that it should be added in the kernel or that libdebmapper should be compiled
without udev_sync alternatively).

Inspired by util-linux-ng's ipcs code.

Initiated by the problem reported here:
http://bugs.gentoo.org/show_bug.cgi?id=330375

Peter
---
 libdm/libdm-common.c |   33 +++++++++++++++++++++++++++++----
 1 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 438e461..23dd761 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -60,6 +60,7 @@ static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
 static int _verbose = 0;
 
 #ifdef UDEV_SYNC_SUPPORT
+static int _semaphore_supported = -1;
 static int _udev_running = -1;
 static int _sync_with_udev = 1;
 static int _udev_checking = 1;
@@ -929,6 +930,23 @@ int dm_udev_wait(uint32_t cookie)
 
 #else		/* UDEV_SYNC_SUPPORT */
 
+static int _check_semaphore_is_supported()
+{
+	int maxid;
+	union semun arg;
+	struct seminfo seminfo;
+
+	arg.array = (unsigned short int *) (void *) &seminfo;
+	maxid = semctl(0, 0, SEM_INFO, arg);
+
+	if (maxid < 0) {
+		log_warn("Kernel not configured for semaphores (System V IPC). "
+			 "Not using udev synchronisation code.");
+		return 0;
+	}
+
+	return 1;
+}
 
 static int _check_udev_is_running(void)
 {
@@ -958,20 +976,27 @@ bad:
 	return 0;
 }
 
-void dm_udev_set_sync_support(int sync_with_udev)
+static void _check_udev_sync_requirements_once()
 {
+	if (_semaphore_supported < 0)
+		_semaphore_supported = _check_semaphore_is_supported();
+
 	if (_udev_running < 0)
 		_udev_running = _check_udev_is_running();
+}
 
+void dm_udev_set_sync_support(int sync_with_udev)
+{
+	_check_udev_sync_requirements_once();
 	_sync_with_udev = sync_with_udev;
 }
 
 int dm_udev_get_sync_support(void)
 {
-	if (_udev_running < 0)
-		_udev_running = _check_udev_is_running();
+	_check_udev_sync_requirements_once();
 
-	return dm_cookie_supported() && _udev_running && _sync_with_udev;
+	return _semaphore_supported && dm_cookie_supported() &&
+		_udev_running && _sync_with_udev;
 }
 
 void dm_udev_set_checking(int checking)



From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 28 Apr 2016 00:00:08 +0000 (UTC)
Subject: master - libdm: Add dm_udev_wait_immediate.
Message-ID: <20160428000008.2328460095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16019b518e287da19c87eb64229f5c3ca057cb05
Commit:        16019b518e287da19c87eb64229f5c3ca057cb05
Parent:        a2d2a61339b83de0d48ed6ed15e816773393c6b4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 28 00:54:27 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 28 00:54:27 2016 +0100

libdm: Add dm_udev_wait_immediate.

dm_udev_wait() waits inside the library.
dm_udev_wait_immediate allows the caller to do other things if the
cookie isn't yet ready to be decremented.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_124 |    1 +
 libdm/libdevmapper.h                |    9 ++++++
 libdm/libdm-common.c                |   49 +++++++++++++++++++++++++++++++++-
 4 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7460a94..b21d7d5 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.124 - 
 ==================================
+  Add dm_udev_wait_immediate to libdevmapper for waiting outside the library.
 
 Version 1.02.123 - 23rd April 2016
 ==================================
diff --git a/libdm/.exported_symbols.DM_1_02_124 b/libdm/.exported_symbols.DM_1_02_124
new file mode 100644
index 0000000..934011a
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_124
@@ -0,0 +1 @@
+dm_udev_wait_immediate
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index a90013f..d2f40c9 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -3218,6 +3218,15 @@ int dm_udev_create_cookie(uint32_t *cookie);
 int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);
 
+/*
+ * dm_dev_wait_immediate 
+ * If *ready is 1 on return, the wait is complete.
+ * If *ready is 0 on return, the wait is incomplete and either
+ * this function or dm_udev_wait() must be called again.
+ * Returns 0 on error, when neither function should be called again.
+ */
+int dm_udev_wait_immediate(uint32_t cookie, int *ready);
+
 #define DM_DEV_DIR_UMASK 0022
 #define DM_CONTROL_NODE_UMASK 0177
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 2580d94..d67d0bb 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -2082,6 +2082,14 @@ int dm_udev_wait(uint32_t cookie)
 	return 1;
 }
 
+int dm_udev_wait_immediate(uint32_t cookie, int *ready)
+{
+	update_devs();
+	*ready = 1;
+
+	return 1;
+}
+
 #else		/* UDEV_SYNC_SUPPORT */
 
 static int _check_semaphore_is_supported(void)
@@ -2506,10 +2514,16 @@ int dm_udev_complete(uint32_t cookie)
 	return 1;
 }
 
-static int _udev_wait(uint32_t cookie)
+/*
+ * If *nowait is set, return immediately leaving it set if the semaphore
+ * is not ready to be decremented to 0.  *nowait is cleared if the wait
+ * succeeds.
+ */
+static int _udev_wait(uint32_t cookie, int *nowait)
 {
 	int semid;
 	struct sembuf sb = {0, 0, 0};
+	int val;
 
 	if (!cookie || !dm_udev_get_sync_support())
 		return 1;
@@ -2517,6 +2531,21 @@ static int _udev_wait(uint32_t cookie)
 	if (!_get_cookie_sem(cookie, &semid))
 		return_0;
 
+	/* Return immediately if the semaphore value exceeds 1? */
+	if (*nowait) {
+		if ((val = semctl(semid, 0, GETVAL)) < 0) {
+			log_error("semid %d: sem_ctl GETVAL failed for "
+				  "cookie 0x%" PRIx32 ": %s",
+				  semid, cookie, strerror(errno));
+			return 0;		
+		}
+
+		if (val > 1)
+			return 1;
+
+		*nowait = 0;
+	}
+
 	if (!_udev_notify_sem_dec(cookie, semid)) {
 		log_error("Failed to set a proper state for notification "
 			  "semaphore identified by cookie value %" PRIu32 " (0x%x) "
@@ -2548,11 +2577,27 @@ repeat_wait:
 
 int dm_udev_wait(uint32_t cookie)
 {
-	int r = _udev_wait(cookie);
+	int nowait = 0;
+	int r = _udev_wait(cookie, &nowait);
 
 	update_devs();
 
 	return r;
 }
 
+int dm_udev_wait_immediate(uint32_t cookie, int *ready)
+{
+	int nowait = 1;
+	int r = _udev_wait(cookie, &nowait);
+
+	if (r && nowait) {
+		*ready = 0;
+		return 1;
+	}
+
+	update_devs();
+	*ready = 1;
+
+	return r;
+}
 #endif		/* UDEV_SYNC_SUPPORT */



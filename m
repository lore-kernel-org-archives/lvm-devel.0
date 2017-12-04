From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:57:54 -0500
Subject: master - cleanup: stack tracing
Message-ID: <201712041457.vB4EvsnL007158@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=925fec6ecb8f1915aee20e09a9703e1cb70cd0b1
Commit:        925fec6ecb8f1915aee20e09a9703e1cb70cd0b1
Parent:        e3366787b6349a190063a09b0c37ad5a641fcccf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 13:31:40 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: stack tracing

---
 libdm/libdm-common.c  |    4 ++--
 libdm/libdm-deptree.c |   12 ++++--------
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index e983b03..f5c6062 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -2033,7 +2033,7 @@ int dm_mknodes(const char *name)
 	int r = 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_MKNODES)))
-		return 0;
+		return_0;
 
 	if (name && !dm_task_set_name(dmt, name))
 		goto out;
@@ -2054,7 +2054,7 @@ int dm_driver_version(char *version, size_t size)
 	int r = 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_VERSION)))
-		return 0;
+		return_0;
 
 	if (!dm_task_run(dmt))
 		log_error("Failed to get driver version");
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index ba11388..f662d26 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -813,10 +813,8 @@ static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint
 		return 1;
 	}
 
-	if (!(*dmt = dm_task_create(DM_DEVICE_DEPS))) {
-		log_error("deps dm_task creation failed");
-		return 0;
-	}
+	if (!(*dmt = dm_task_create(DM_DEVICE_DEPS)))
+		return_0;
 
 	if (!dm_task_set_major(*dmt, major) || !dm_task_set_minor(*dmt, minor)) {
 		log_error("_deps: failed to set major:minor for (" FMTu32 ":" FMTu32 ").",
@@ -877,10 +875,8 @@ static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
 	struct dm_task *dmt;
 	int r = 0;
 
-	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
-		log_error("_info_by_dev: dm_task creation failed");
-		return 0;
-	}
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
+		return_0;
 
 	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
 		log_error("_info_by_dev: Failed to set device number.");



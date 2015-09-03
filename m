From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:15 +0000 (UTC)
Subject: master - dmeventd: reorder mempool allocation
Message-ID: <20150903213615.B2E9960F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b9843c20b3ca26867228d89154b611c4464eff2
Commit:        2b9843c20b3ca26867228d89154b611c4464eff2
Parent:        872ea3b98710c2a45c76dc22a606a40b13440d13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 3 17:39:03 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:36 2015 +0200

dmeventd: reorder mempool allocation

Since lvm2_init() effectively detects memory leaks
allocate mempool after this initialization
(so it's not reported as leak).
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 9b08bbe..7350623 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -94,21 +94,22 @@ int dmeventd_lvm2_init(void)
 
 	pthread_mutex_lock(&_register_mutex);
 
-	/*
-	 * Need some space for allocations.  1024 should be more
-	 * than enough for what we need (device mapper name splitting)
-	 */
-	if (!_mem_pool && !(_mem_pool = dm_pool_create("mirror_dso", 1024)))
-		goto out;
-
 	if (!_lvm_handle) {
 		if (!getenv("LVM_LOG_FILE_EPOCH"))
 			lvm2_log_fn(_temporary_log_fn);
-		if (!(_lvm_handle = lvm2_init())) {
-			dm_pool_destroy(_mem_pool);
-			_mem_pool = NULL;
+		if (!(_lvm_handle = lvm2_init()))
+			goto out;
+
+		/*
+		 * Need some space for allocations.  1024 should be more
+		 * than enough for what we need (device mapper name splitting)
+		 */
+		if (!_mem_pool && !(_mem_pool = dm_pool_create("mirror_dso", 1024))) {
+			lvm2_exit(_lvm_handle);
+			_lvm_handle = NULL;
 			goto out;
 		}
+
 		lvm2_disable_dmeventd_monitoring(_lvm_handle);
 		/* FIXME Temporary: move to dmeventd core */
 		lvm2_run(_lvm_handle, "_memlock_inc");



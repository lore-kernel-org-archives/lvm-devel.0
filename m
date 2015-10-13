From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:52 +0000 (UTC)
Subject: master - dmeventd: add more debug messages
Message-ID: <20151013140352.824AA61207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e2721030857088803bc71ccc27644b7b95241ca
Commit:        0e2721030857088803bc71ccc27644b7b95241ca
Parent:        13086c2523a00bc8501113f56094312bda4881e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 10 16:36:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:15:43 2015 +0200

dmeventd: add more debug messages

---
 daemons/dmeventd/dmeventd.c                        |   15 ++++++++++++---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c       |    4 ++++
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    1 +
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 0acb919..e34c4c1 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -874,7 +874,7 @@ static void *_monitor_thread(void *arg)
 		}
 	}
 
-	DEBUGLOG("Finished _monitor_thread");
+	DEBUGLOG("Finished _monitor_thread.");
 	pthread_cleanup_pop(1);
 
 	return NULL;
@@ -1120,6 +1120,8 @@ static int _unregister_for_event(struct message_data *message_data)
 	}
 	_unlock_mutex();
 
+	DEBUGLOG("Unregistered uuid:%s.", thread->device.uuid);
+
       out:
 	return ret;
 }
@@ -1147,6 +1149,7 @@ static int _registered_device(struct message_data *message_data,
 		return -ENOMEM;
 
 	msg->size = (uint32_t) r;
+	DEBUGLOG("Registered %s.", msg->data);
 
 	return 0;
 }
@@ -1154,6 +1157,7 @@ static int _registered_device(struct message_data *message_data,
 static int _want_registered_device(char *dso_name, char *device_uuid,
 				   struct thread_status *thread)
 {
+	DEBUGLOG("Looking for dso:%s  uuid:%s.", dso_name, device_uuid);
 	/* If DSO names and device paths are equal. */
 	if (dso_name && device_uuid)
 		return !strcmp(dso_name, thread->dso_data->dso_name) &&
@@ -1175,6 +1179,9 @@ static int _get_registered_dev(struct message_data *message_data, int next)
 	struct thread_status *thread, *hit = NULL;
 	int ret = -ENOENT;
 
+	DEBUGLOG("Get%s dso:%s  uuid:%s.", next ? "" : "Next",
+		 message_data->dso_name,
+		 message_data->device_uuid);
 	_lock_mutex();
 
 	/* Iterate list of threads checking if we want a particular one. */
@@ -1205,8 +1212,10 @@ static int _get_registered_dev(struct message_data *message_data, int next)
 				goto reg;
 			}
 
-	if (!hit)
+	if (!hit) {
+		DEBUGLOG("Get%s not registered", next ? "" : "Next");
 		goto out;
+	}
 
 	while (1) {
 		if (dm_list_end(&_thread_registry, &thread->list))
@@ -1613,9 +1622,9 @@ static void _cleanup_unused_threads(void)
 		}
 
 		if (thread->status == DM_THREAD_DONE) {
-			DEBUGLOG("Destroying Thr %x.", (int)thread->thread);
 			dm_list_del(l);
 			_unlock_mutex();
+			DEBUGLOG("Destroying Thr %x.", (int)thread->thread);
 			join_ret = pthread_join(thread->thread, NULL);
 			_free_thread_status(thread);
 			_lock_mutex();
diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 0ba3694..e3d8321 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -74,6 +74,7 @@ int dmeventd_lvm2_init(void)
 		lvm2_disable_dmeventd_monitoring(_lvm_handle);
 		/* FIXME Temporary: move to dmeventd core */
 		lvm2_run(_lvm_handle, "_memlock_inc");
+		log_debug("lvm plugin initilized.");
 	}
 
 	_register_count++;
@@ -89,14 +90,17 @@ void dmeventd_lvm2_exit(void)
 	pthread_mutex_lock(&_register_mutex);
 
 	if (!--_register_count) {
+		log_debug("lvm plugin shuting down.");
 		lvm2_run(_lvm_handle, "_memlock_dec");
 		dm_pool_destroy(_mem_pool);
 		_mem_pool = NULL;
+		log_debug("lvm plugin exiting.");
 		lvm2_exit(_lvm_handle);
 		_lvm_handle = NULL;
 	}
 
 	pthread_mutex_unlock(&_register_mutex);
+	log_debug("lvm plugin exited.");
 }
 
 struct dm_pool *dmeventd_lvm2_pool(void)
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index f78b8f7..ffe6666 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -152,6 +152,7 @@ void process_event(struct dm_task *dmt,
 
 	if (status->invalid) {
 		struct dm_info info;
+		log_error("Snapshot %s is lost.", device);
 		if (dm_task_get_info(dmt, &info)) {
 			dmeventd_lvm2_unlock();
 			_umount(device, info.major, info.minor);



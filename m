From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 29 Mar 2010 17:27:20 +0200
Subject: [PATCH 2/7] Fix resouces leak in error path
In-Reply-To: <cover.1269876115.git.zkabelac@redhat.com>
References: <cover.1269876115.git.zkabelac@redhat.com>
Message-ID: <51fcf883cce836e4b20941c192d2e92bb9e5f859.1269876115.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the error path of _register_for_event() calls _free_thread_status()
we need to call _lib_put().
To make thing simplier moving this _lib_put() into common error path code.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/dmeventd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 37122c9..f4b664b 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -243,8 +243,10 @@ static struct thread_status *_alloc_thread_status(struct message_data *data,
 	return ret;
 }
 
+static void _lib_put(struct dso_data *data);
 static void _free_thread_status(struct thread_status *thread)
 {
+	_lib_put(thread->dso_data);
 	if (thread->current_task)
 		dm_task_destroy(thread->current_task);
 	dm_free(thread->device.uuid);
@@ -1481,7 +1483,6 @@ static void _cleanup_unused_threads(void)
 		if (thread->status == DM_THREAD_DONE) {
 			dm_list_del(l);
 			pthread_join(thread->thread, NULL);
-			_lib_put(thread->dso_data);
 			_free_thread_status(thread);
 		}
 	}
-- 
1.7.0.1



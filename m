From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:25 +0000 (UTC)
Subject: master - cleanup: skip zeroing of cleared areas
Message-ID: <20140418145525.443C360F48@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91eb8927fd83a8ddff7c4007c2421386946437e0
Commit:        91eb8927fd83a8ddff7c4007c2421386946437e0
Parent:        20179523e2ab0d0dce757e1a689f30ad4add3f17
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 09:59:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:51 2014 +0200

cleanup: skip zeroing of cleared areas

Zalloc mem is already zeroed.
---
 daemons/dmeventd/dmeventd.c |   17 +++++------------
 1 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 32610ec..e1235dd 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -218,9 +218,9 @@ static pthread_cond_t _timeout_cond = PTHREAD_COND_INITIALIZER;
 static struct thread_status *_alloc_thread_status(const struct message_data *data,
 						  struct dso_data *dso_data)
 {
-	struct thread_status *ret = (typeof(ret)) dm_zalloc(sizeof(*ret));
+	struct thread_status *ret;
 
-	if (!ret)
+	if (!(ret = dm_zalloc(sizeof(*ret))))
 		return NULL;
 
 	if (!(ret->device.uuid = dm_strdup(data->device_uuid))) {
@@ -228,9 +228,6 @@ static struct thread_status *_alloc_thread_status(const struct message_data *dat
 		return NULL;
 	}
 
-	ret->current_task = NULL;
-	ret->device.name = NULL;
-	ret->device.major = ret->device.minor = 0;
 	ret->dso_data = dso_data;
 	ret->events = data->events_field;
 	ret->timeout = data->timeout_secs;
@@ -411,11 +408,7 @@ static int _fill_device_data(struct thread_status *ts)
 	if (!ts->device.uuid)
 		return 0;
 
-	ts->device.name = NULL;
-	ts->device.major = ts->device.minor = 0;
-
-	dmt = dm_task_create(DM_DEVICE_INFO);
-	if (!dmt)
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
 		return 0;
 
 	if (!dm_task_set_uuid(dmt, ts->device.uuid))
@@ -424,8 +417,8 @@ static int _fill_device_data(struct thread_status *ts)
 	if (!dm_task_run(dmt))
 		goto fail;
 
-	ts->device.name = dm_strdup(dm_task_get_name(dmt));
-	if (!ts->device.name)
+	dm_free(ts->device.name);
+	if (!(ts->device.name = dm_strdup(dm_task_get_name(dmt))))
 		goto fail;
 
 	if (!dm_task_get_info(dmt, &dmi))



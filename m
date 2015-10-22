From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:45 +0000 (UTC)
Subject: master - dmeventd: move dso handling into single code section
Message-ID: <20151022213345.B52BD60B67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efc76ca33dec99e3b0499ef28fb9236815ad2258
Commit:        efc76ca33dec99e3b0499ef28fb9236815ad2258
Parent:        590091a4faa4a4eb66598137576e01e692fb9f8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 12:22:55 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:33:19 2015 +0200

dmeventd: move dso handling into single code section

Move all DSO related function in front, so they could be easily
referenced from rest of code.

Add proper error paths with logging and error reporting.

Drop mutex locking when releasing DSO - since DSO is always
allocated and released in main 'event' processing thread.
---
 daemons/dmeventd/dmeventd.c |  236 ++++++++++++++++++++++---------------------
 1 files changed, 122 insertions(+), 114 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 93df32e..69fe393 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -243,29 +243,127 @@ static DM_LIST_INIT(_timeout_registry);
 static pthread_mutex_t _timeout_mutex = PTHREAD_MUTEX_INITIALIZER;
 static pthread_cond_t _timeout_cond = PTHREAD_COND_INITIALIZER;
 
-/* Allocate/free the status structure for a monitoring thread. */
-static struct thread_status *_alloc_thread_status(const struct message_data *data,
-						  struct dso_data *dso_data)
+
+/**********
+ *   DSO
+ **********/
+
+/* DSO data allocate/free. */
+static void _free_dso_data(struct dso_data *data)
 {
-	struct thread_status *ret;
+	dm_free(data->dso_name);
+	dm_free(data);
+}
 
-	if (!(ret = dm_zalloc(sizeof(*ret))))
-		return NULL;
+static struct dso_data *_alloc_dso_data(struct message_data *data)
+{
+	struct dso_data *ret = (typeof(ret)) dm_zalloc(sizeof(*ret));
 
-	if (!(ret->device.uuid = dm_strdup(data->device_uuid))) {
+	if (!ret)
+		return_NULL;
+
+	if (!(ret->dso_name = dm_strdup(data->dso_name))) {
 		dm_free(ret);
-		return NULL;
+		return_NULL;
 	}
 
-	ret->dso_data = dso_data;
-	ret->events = data->events_field;
-	ret->timeout = data->timeout_secs;
-	dm_list_init(&ret->timeout_list);
+	return ret;
+}
+
+/* DSO reference counting. */
+static void _lib_get(struct dso_data *data)
+{
+	data->ref_count++;
+}
+
+static void _lib_put(struct dso_data *data)
+{
+	if (!--data->ref_count) {
+		dlclose(data->dso_handle);
+		UNLINK_DSO(data);
+		_free_dso_data(data);
+	}
+}
+
+/* Find DSO data. */
+static struct dso_data *_lookup_dso(struct message_data *data)
+{
+	struct dso_data *dso_data, *ret = NULL;
+
+	dm_list_iterate_items(dso_data, &_dso_registry)
+		if (!strcmp(data->dso_name, dso_data->dso_name)) {
+			_lib_get(dso_data);
+			ret = dso_data;
+			break;
+		}
+
+	return ret;
+}
+
+/* Lookup DSO symbols we need. */
+static int _lookup_symbol(void *dl, void **symbol, const char *name)
+{
+	if (!(*symbol = dlsym(dl, name)))
+		return_0;
+
+	return 1;
+}
+
+static int _lookup_symbols(void *dl, struct dso_data *data)
+{
+	return _lookup_symbol(dl, (void *) &data->process_event,
+			     "process_event") &&
+	    _lookup_symbol(dl, (void *) &data->register_device,
+			  "register_device") &&
+	    _lookup_symbol(dl, (void *) &data->unregister_device,
+			  "unregister_device");
+}
+
+/* Load an application specific DSO. */
+static struct dso_data *_load_dso(struct message_data *data)
+{
+	void *dl;
+	struct dso_data *ret;
+	const char *dlerr;
+
+	if (!(dl = dlopen(data->dso_name, RTLD_NOW))) {
+		dlerr = dlerror();
+		goto_bad;
+	}
+
+	if (!(ret = _alloc_dso_data(data))) {
+		dlclose(dl);
+		dlerr = "no memory";
+		goto_bad;
+	}
+
+	if (!(_lookup_symbols(dl, ret))) {
+		_free_dso_data(ret);
+		dlclose(dl);
+		dlerr = "symbols missing";
+		goto_bad;
+	}
+
+	/*
+	 * Keep handle to close the library once
+	 * we've got no references to it any more.
+	 */
+	ret->dso_handle = dl;
+	LINK_DSO(ret);
 
 	return ret;
+bad:
+	log_error("dmeventd %s dlopen failed: %s.", data->dso_name, dlerr);
+	data->msg->size = dm_asprintf(&(data->msg->data), "%s %s dlopen failed: %s",
+				      data->id, data->dso_name, dlerr);
+	return NULL;
 }
 
-static void _lib_put(struct dso_data *data);
+/************
+ *  THREAD
+ ************/
+
+/* Allocate/free the thread status structure for a monitoring thread. */
 static void _free_thread_status(struct thread_status *thread)
 {
 	_lib_put(thread->dso_data);
@@ -276,19 +374,25 @@ static void _free_thread_status(struct thread_status *thread)
 	dm_free(thread);
 }
 
-/* Allocate/free DSO data. */
-static struct dso_data *_alloc_dso_data(struct message_data *data)
+/* Allocate/free the status structure for a monitoring thread. */
+static struct thread_status *_alloc_thread_status(const struct message_data *data,
+						  struct dso_data *dso_data)
 {
-	struct dso_data *ret = (typeof(ret)) dm_zalloc(sizeof(*ret));
+	struct thread_status *ret;
 
-	if (!ret)
+	if (!(ret = dm_zalloc(sizeof(*ret))))
 		return NULL;
 
-	if (!(ret->dso_name = dm_strdup(data->dso_name))) {
+	if (!(ret->device.uuid = dm_strdup(data->device_uuid))) {
 		dm_free(ret);
 		return NULL;
 	}
 
+	ret->dso_data = dso_data;
+	ret->events = data->events_field;
+	ret->timeout = data->timeout_secs;
+	dm_list_init(&ret->timeout_list);
+
 	return ret;
 }
 
@@ -331,12 +435,6 @@ static int _pthread_create_smallstack(pthread_t *t, void *(*fun)(void *), void *
 	return r;
 }
 
-static void _free_dso_data(struct dso_data *data)
-{
-	dm_free(data->dso_name);
-	dm_free(data);
-}
-
 /*
  * Fetch a string off src and duplicate it into *ptr.
  * Pay attention to zero-length strings.
@@ -893,96 +991,6 @@ static int _terminate_thread(struct thread_status *thread)
 	return pthread_kill(thread->thread, SIGALRM);
 }
 
-/* DSO reference counting. Call with _global_mutex locked! */
-static void _lib_get(struct dso_data *data)
-{
-	data->ref_count++;
-}
-
-static void _lib_put(struct dso_data *data)
-{
-	if (!--data->ref_count) {
-		dlclose(data->dso_handle);
-		UNLINK_DSO(data);
-		_free_dso_data(data);
-	}
-}
-
-/* Find DSO data. */
-static struct dso_data *_lookup_dso(struct message_data *data)
-{
-	struct dso_data *dso_data, *ret = NULL;
-
-	dm_list_iterate_items(dso_data, &_dso_registry)
-		if (!strcmp(data->dso_name, dso_data->dso_name)) {
-			_lib_get(dso_data);
-			ret = dso_data;
-			break;
-		}
-
-	return ret;
-}
-
-/* Lookup DSO symbols we need. */
-static int _lookup_symbol(void *dl, void **symbol, const char *name)
-{
-	if ((*symbol = dlsym(dl, name)))
-		return 1;
-
-	return 0;
-}
-
-static int _lookup_symbols(void *dl, struct dso_data *data)
-{
-	return _lookup_symbol(dl, (void *) &data->process_event,
-			     "process_event") &&
-	    _lookup_symbol(dl, (void *) &data->register_device,
-			  "register_device") &&
-	    _lookup_symbol(dl, (void *) &data->unregister_device,
-			  "unregister_device");
-}
-
-/* Load an application specific DSO. */
-static struct dso_data *_load_dso(struct message_data *data)
-{
-	void *dl;
-	struct dso_data *ret;
-
-	if (!(dl = dlopen(data->dso_name, RTLD_NOW))) {
-		const char *dlerr = dlerror();
-		log_error("dmeventd %s dlopen failed: %s.",
-			  data->dso_name, dlerr);
-		data->msg->size =
-		    dm_asprintf(&(data->msg->data), "%s %s dlopen failed: %s",
-				data->id, data->dso_name, dlerr);
-		return NULL;
-	}
-
-	if (!(ret = _alloc_dso_data(data))) {
-		dlclose(dl);
-		return NULL;
-	}
-
-	if (!(_lookup_symbols(dl, ret))) {
-		_free_dso_data(ret);
-		dlclose(dl);
-		return NULL;
-	}
-
-	/*
-	 * Keep handle to close the library once
-	 * we've got no references to it any more.
-	 */
-	ret->dso_handle = dl;
-	_lib_get(ret);
-
-	_lock_mutex();
-	LINK_DSO(ret);
-	_unlock_mutex();
-
-	return ret;
-}
-
 /* Return success on daemon active check. */
 static int _active(struct message_data *message_data)
 {



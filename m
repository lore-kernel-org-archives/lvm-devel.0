From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 31 Jul 2013 20:24:13 +0000 (UTC)
Subject: master - dmeventd: Fix memory leak
Message-ID: <20130731202413.D3ABA60FD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ca54c4f0b27125bc385d55ea0b44853fc7744dd
Commit:        5ca54c4f0b27125bc385d55ea0b44853fc7744dd
Parent:        7db95d0d40c3608b7298cb19380430613fa9e532
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jul 31 15:23:13 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jul 31 15:23:13 2013 -0500

dmeventd: Fix memory leak

When creating a timeout thread for snapshots, the thread is not
tracked and thus never joined.  This means that the exit status
of the timeout thread is held indefinitely.  Saves a bit of
memory to set PTHREAD_CREATE_DETACHED when creating this thread.

I've also added pthread_attr_init|destroy to setup the creation
pthread_attr_t.

Reported-by: NeilBrown <neilb@suse.de>
Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
---
 WHATS_NEW                   |    1 +
 daemons/dmeventd/dmeventd.c |   41 +++++++++++++++++++++++++++++++++--------
 2 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 69a8275..c76dc68 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Create dmeventd timeout threads as "detached" so exit status is freed.
   Add initial support thin pool lvconvert --repair.
   Add --with-thin-repair and --with-thin-dump configure options.
   Add lvm.conf thin_repair/dump_executable and thin_repair_options.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 92c93d9..9c7a6c6 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -264,16 +264,44 @@ static struct dso_data *_alloc_dso_data(struct message_data *data)
 	return ret;
 }
 
-/* Create a device monitoring thread. */
+/*
+ * Create a device monitoring thread.
+ * N.B.  Error codes returned are positive.
+ */
 static int _pthread_create_smallstack(pthread_t *t, void *(*fun)(void *), void *arg)
 {
+	int r;
+	pthread_t tmp;
 	pthread_attr_t attr;
 	pthread_attr_init(&attr);
+
+	/*
+	 * From pthread_attr_init man page:
+	 * POSIX.1-2001 documents an ENOMEM error for pthread_attr_init(); on
+	 * Linux these functions always succeed (but portable and future-proof
+	 * applications should nevertheless handle a possible error return).
+	 */
+	if ((r = pthread_attr_init(&attr)) != 0)
+		return r;
+
 	/*
 	 * We use a smaller stack since it gets preallocated in its entirety
 	 */
 	pthread_attr_setstacksize(&attr, THREAD_STACK_SIZE);
-	return pthread_create(t, &attr, fun, arg);
+
+	/*
+	 * If no-one will be waiting, we need to detach.
+	 */
+	if (!t) {
+		pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
+		t = &tmp;
+	}
+
+	r = pthread_create(t, &attr, fun, arg);
+
+	pthread_attr_destroy(&attr);
+
+	return r;
 }
 
 static void _free_dso_data(struct dso_data *data)
@@ -548,12 +576,9 @@ static int _register_for_timeout(struct thread_status *thread)
 			pthread_cond_signal(&_timeout_cond);
 	}
 
-	if (!_timeout_running) {
-		pthread_t timeout_id;
-
-		if (!(ret = _pthread_create_smallstack(&timeout_id, _timeout_thread, NULL)))
-			_timeout_running = 1;
-	}
+	if (!_timeout_running &&
+	    !(ret = _pthread_create_smallstack(NULL, _timeout_thread, NULL)))
+		_timeout_running = 1;
 
 	pthread_mutex_unlock(&_timeout_mutex);
 



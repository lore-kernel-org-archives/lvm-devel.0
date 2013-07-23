From: NeilBrown <neilb@suse.de>
Date: Tue, 23 Jul 2013 12:42:39 +1000
Subject: [PATCH] dmeventd: remove memory leak
Message-ID: <20130723124239.430bdd40@notabene.brown>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


If e.g. a snapshot volume is repeatly added and removed, dmeventd will
leake memory.

This is because the 'timeout' thread is not detached and is never
joined.  So the resources it uses are never freed.

This patch changes _pthread_create_smallstack to set
PTHREAD_CREATE_DETACHED if the pthread pointer passed is NULL, and
changes _register_for_timeout to pass a NULL pointer rather than a
pointer to an unused variable.

Signed-off-by: NeilBrown <neilb@suse.de>

---

Customer found this memory leak.  It can be easily seen by e.g.

while true; do
   lvcreate -n snaptest -L 900m -s /dev/vgtest/lvtest
   sleep 1
   lvremove -f /dev/vgtest/snaptest
done

and watching /proc/`pid-of dmeventd`/maps

NeilBrown

 daemons/dmeventd/dmeventd.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

--- LVM2.2.02.84.orig/daemons/dmeventd/dmeventd.c
+++ LVM2.2.02.84/daemons/dmeventd/dmeventd.c
@@ -256,12 +256,20 @@ static struct dso_data *_alloc_dso_data(
 /* Create a device monitoring thread. */
 static int _pthread_create_smallstack(pthread_t *t, void *(*fun)(void *), void *arg)
 {
+	pthread_t tmp;
 	pthread_attr_t attr;
 	pthread_attr_init(&attr);
 	/*
 	 * We use a smaller stack since it gets preallocated in its entirety
 	 */
 	pthread_attr_setstacksize(&attr, THREAD_STACK_SIZE);
+	/*
+	 * If no-one will be waiting, we need to detach.
+	 */
+	if (!t) {
+		pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
+		t = &tmp;
+	}
 	return pthread_create(t, &attr, fun, arg);
 }
 
@@ -544,9 +552,7 @@ static int _register_for_timeout(struct
 	}
 
 	if (!_timeout_running) {
-		pthread_t timeout_id;
-
-		if (!(ret = -_pthread_create_smallstack(&timeout_id, _timeout_thread, NULL)))
+		if (!(ret = -_pthread_create_smallstack(NULL, _timeout_thread, NULL)))
 			_timeout_running = 1;
 	}
 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 828 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20130723/020f5a59/attachment.sig>

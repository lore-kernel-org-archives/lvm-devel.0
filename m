From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:33 +0000 (UTC)
Subject: master - clvmd: add special lvm thread exit
Message-ID: <20140321213133.ED43160919@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8431d47b3b4d1742e9703a1abfd9722b94adaf34
Commit:        8431d47b3b4d1742e9703a1abfd9722b94adaf34
Parent:        05a532e1711e9e5e03dc879b790a92fb2a2464c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 18:01:38 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:23 2014 +0100

clvmd: add special lvm thread exit

When multiple threads act on the same 'quit' variable
the order of exit becomes unpredictable.

So let the main_loop() finish first and then clean up
all queued lvm jobs.

Do not add any new work, when lvm_thread_exit is set.
---
 daemons/clvmd/clvmd.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a3f4354..4ca2918 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -89,6 +89,7 @@ static pthread_t lvm_thread;
 /* Stack size 128KiB for thread, must be bigger then DEFAULT_RESERVED_STACK */
 static const size_t STACK_SIZE = 128 * 1024;
 static pthread_attr_t stack_attr;
+static int lvm_thread_exit = 0;
 static pthread_mutex_t lvm_thread_mutex;
 static pthread_cond_t lvm_thread_cond;
 static pthread_barrier_t lvm_start_barrier;
@@ -617,6 +618,7 @@ int main(int argc, char *argv[])
 	main_loop(local_sock, cmd_timeout);
 
 	pthread_mutex_lock(&lvm_thread_mutex);
+	lvm_thread_exit = 1;
 	pthread_cond_signal(&lvm_thread_cond);
 	pthread_mutex_unlock(&lvm_thread_mutex);
 	if ((errno = pthread_join(lvm_thread, NULL)))
@@ -2081,7 +2083,7 @@ static void *lvm_thread_fn(void *arg)
 	/* Now wait for some actual work */
 	pthread_mutex_lock(&lvm_thread_mutex);
 
-	while (!quit) {
+	while (!lvm_thread_exit)
 		if (dm_list_empty(&lvm_cmd_head)) {
 			DEBUGLOG("LVM thread waiting for work\n");
 			pthread_cond_wait(&lvm_thread_cond, &lvm_thread_mutex);
@@ -2097,7 +2099,6 @@ static void *lvm_thread_fn(void *arg)
 
 			pthread_mutex_lock(&lvm_thread_mutex);
 		}
-	}
 
 	pthread_mutex_unlock(&lvm_thread_mutex);
 
@@ -2110,6 +2111,9 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 {
 	struct lvm_thread_cmd *cmd;
 
+	if (lvm_thread_exit)
+		return -1; /* We are about to exit */
+
 	cmd = malloc(sizeof(struct lvm_thread_cmd));
 	if (!cmd)
 		return ENOMEM;



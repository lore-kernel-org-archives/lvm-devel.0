From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 24 Mar 2011 12:16:37 +0100
Subject: [PATCH 4/4] Better shutdown for clvmd
In-Reply-To: <cover.1300965223.git.zkabelac@redhat.com>
References: <cover.1300965223.git.zkabelac@redhat.com>
Message-ID: <5826c97b6ad94b05ed1d57f34dc3d72db9b09a5b.1300965223.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Ok - this is 'a small step' towards cleaner shutdown sequence.
It could be seens as unneeded - as normally clvmd doens't care about
unreleased memory on exit - but for valgrind testing it's better to
have them cleaned all.

So - few things are left on exit path - this patch starts to remove
just some of them.

1. lvm_thread_fs is made as a thread which could be joined on exit()
2. memory allocated to local_clien_head list is released.
   (this part is somewhat more complex if the proper reaction is
   needed - and as it requires some heavier code moving - it will
   be resolved later.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c |   30 ++++++++++++++++++++++--------
 1 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 361fc62..fc092cf 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -103,8 +103,6 @@ static int child_pipe[2];
 
 typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC, IF_SINGLENODE} if_type_t;
 
-typedef void *(lvm_pthread_fn_t)(void*);
-
 /* Prototypes for code further down */
 static void sigusr2_handler(int sig);
 static void sighup_handler(int sig);
@@ -134,7 +132,7 @@ static int check_all_clvmds_running(struct local_client *client);
 static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 				     int len, const char *csid,
 				     struct local_client **new_client);
-static void lvm_thread_fn(void *) __attribute__ ((noreturn));
+static void *lvm_thread_fn(void *);
 static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 			   int msglen, const char *csid);
 static int distribute_command(struct local_client *thisfd);
@@ -333,7 +331,7 @@ static void check_permissions(void)
 int main(int argc, char *argv[])
 {
 	int local_sock;
-	struct local_client *newfd;
+	struct local_client *newfd, *delfd;
 	struct utsname nodeinfo;
 	struct lvm_startup_params lvm_params;
 	int opt;
@@ -581,8 +579,7 @@ int main(int argc, char *argv[])
 	pthread_mutex_lock(&lvm_start_mutex);
 	lvm_params.using_gulm = using_gulm;
 	lvm_params.argv = argv;
-	pthread_create(&lvm_thread, NULL, (lvm_pthread_fn_t*)lvm_thread_fn,
-			(void *)&lvm_params);
+	pthread_create(&lvm_thread, NULL, lvm_thread_fn, &lvm_params);
 
 	/* Tell the rest of the cluster our version number */
 	/* CMAN can do this immediately, gulm needs to wait until
@@ -601,9 +598,24 @@ int main(int argc, char *argv[])
 	/* Do some work */
 	main_loop(local_sock, cmd_timeout);
 
+	pthread_mutex_lock(&lvm_thread_mutex);
+	pthread_cond_signal(&lvm_thread_cond);
+	pthread_mutex_unlock(&lvm_thread_mutex);
+	if ((errno = pthread_join(lvm_thread, NULL)))
+		log_sys_error("pthread_join", "");
+
 	close_local_sock(local_sock);
 	destroy_lvm();
 
+	for (newfd = local_client_head.next; newfd != NULL;) {
+		delfd = newfd;
+		newfd = newfd->next;
+		/* FIXME: needs cleanup code from read_from_local_sock() */
+                /* for now break of CLVMD presents access to free memory here */
+		safe_close(&(delfd->fd));
+		free(delfd);
+	}
+
 	return 0;
 }
 
@@ -1931,7 +1943,7 @@ static int process_work_item(struct lvm_thread_cmd *cmd)
 /*
  * Routine that runs in the "LVM thread".
  */
-static void lvm_thread_fn(void *arg)
+static void *lvm_thread_fn(void *arg)
 {
 	struct dm_list *cmdl, *tmp;
 	sigset_t ss;
@@ -1952,7 +1964,7 @@ static void lvm_thread_fn(void *arg)
 	pthread_mutex_unlock(&lvm_start_mutex);
 
 	/* Now wait for some actual work */
-	for (;;) {
+	while (!quit) {
 		DEBUGLOG("LVM thread waiting for work\n");
 
 		pthread_mutex_lock(&lvm_thread_mutex);
@@ -1975,6 +1987,8 @@ static void lvm_thread_fn(void *arg)
 		}
 		pthread_mutex_unlock(&lvm_thread_mutex);
 	}
+
+	pthread_exit(NULL);
 }
 
 /* Pass down some work to the LVM thread */
-- 
1.7.4.1



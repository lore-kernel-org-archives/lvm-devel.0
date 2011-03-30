From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 12:36:22 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20110330123622.5813.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 12:36:20

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Better shutdown for clvmd
	
	'a small step' towards cleaner shutdown sequence.
	Normally clvmd doens't care about unreleased memory on exit -
	but for valgrind testing it's better to have them cleaned all.
	
	So - few things are left on exit path - this patch starts to remove
	just some of them.
	
	1. lvm_thread_fs is made as a thread which could be joined on exit()
	2. memory allocated to local_clien_head list is released.
	(this part is somewhat more complex if the proper reaction is
	needed - and as it requires some heavier code moving - it will
	be resolved later.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1963&r2=1.1964
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/WHATS_NEW	2011/03/30 12:30:39	1.1963
+++ LVM2/WHATS_NEW	2011/03/30 12:36:19	1.1964
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Support regular quit of the lvm_thread_fn function in clvmd.
   Fix reading of unallocated memory in lvm1 format import function.
   Replace several strncmp() calls with id_equal().
   Fix lvmcache_info transfer to orphan_vginfo in _lvmcache_update_vgname().
--- LVM2/daemons/clvmd/clvmd.c	2011/03/29 20:30:06	1.101
+++ LVM2/daemons/clvmd/clvmd.c	2011/03/30 12:36:20	1.102
@@ -103,8 +103,6 @@
 
 typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC, IF_SINGLENODE} if_type_t;
 
-typedef void *(lvm_pthread_fn_t)(void*);
-
 /* Prototypes for code further down */
 static void sigusr2_handler(int sig);
 static void sighup_handler(int sig);
@@ -134,7 +132,7 @@
 static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 				     int len, const char *csid,
 				     struct local_client **new_client);
-static void lvm_thread_fn(void *) __attribute__ ((noreturn));
+static void *lvm_thread_fn(void *);
 static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 			   int msglen, const char *csid);
 static int distribute_command(struct local_client *thisfd);
@@ -333,7 +331,7 @@
 int main(int argc, char *argv[])
 {
 	int local_sock;
-	struct local_client *newfd;
+	struct local_client *newfd, *delfd;
 	struct utsname nodeinfo;
 	struct lvm_startup_params lvm_params;
 	int opt;
@@ -581,8 +579,7 @@
 	pthread_mutex_lock(&lvm_start_mutex);
 	lvm_params.using_gulm = using_gulm;
 	lvm_params.argv = argv;
-	pthread_create(&lvm_thread, NULL, (lvm_pthread_fn_t*)lvm_thread_fn,
-			(void *)&lvm_params);
+	pthread_create(&lvm_thread, NULL, lvm_thread_fn, &lvm_params);
 
 	/* Tell the rest of the cluster our version number */
 	/* CMAN can do this immediately, gulm needs to wait until
@@ -601,9 +598,27 @@
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
+		/*
+		 * FIXME:
+		 * needs cleanup code from read_from_local_sock() for now
+		 * break of 'clvmd' may access already free memory here.
+		 */
+		safe_close(&(delfd->fd));
+		free(delfd);
+	}
+
 	return 0;
 }
 
@@ -1932,7 +1947,7 @@
 /*
  * Routine that runs in the "LVM thread".
  */
-static void lvm_thread_fn(void *arg)
+static void *lvm_thread_fn(void *arg)
 {
 	struct dm_list *cmdl, *tmp;
 	sigset_t ss;
@@ -1953,7 +1968,7 @@
 	pthread_mutex_unlock(&lvm_start_mutex);
 
 	/* Now wait for some actual work */
-	for (;;) {
+	while (!quit) {
 		DEBUGLOG("LVM thread waiting for work\n");
 
 		pthread_mutex_lock(&lvm_thread_mutex);
@@ -1976,6 +1991,8 @@
 		}
 		pthread_mutex_unlock(&lvm_thread_mutex);
 	}
+
+	pthread_exit(NULL);
 }
 
 /* Pass down some work to the LVM thread */



From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 13 Aug 2009 10:39:42 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20090813103942.13382.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-08-13 10:39:42

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Fix compilation warning in clvmd.c

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1234&r2=1.1235
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2009/08/06 19:32:26	1.1234
+++ LVM2/WHATS_NEW	2009/08/13 10:39:41	1.1235
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Fix compile warning in clvmd.
 
 Version 2.02.51 - 6th August 2009
 =================================
--- LVM2/daemons/clvmd/clvmd.c	2009/06/15 12:15:23	1.59
+++ LVM2/daemons/clvmd/clvmd.c	2009/08/13 10:39:41	1.60
@@ -110,6 +110,8 @@
 
 typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC} if_type_t;
 
+typedef void *(lvm_pthread_fn_t)(void*);
+
 /* Prototypes for code further down */
 static void sigusr2_handler(int sig);
 static void sighup_handler(int sig);
@@ -138,7 +140,7 @@
 static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 				     int len, const char *csid,
 				     struct local_client **new_client);
-static void *lvm_thread_fn(void *);
+static void lvm_thread_fn(void *) __attribute__ ((noreturn));
 static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 			   int msglen, const char *csid);
 static int distribute_command(struct local_client *thisfd);
@@ -461,7 +463,7 @@
 
 	/* Don't let anyone else to do work until we are started */
 	pthread_mutex_lock(&lvm_start_mutex);
-	pthread_create(&lvm_thread, NULL, lvm_thread_fn,
+	pthread_create(&lvm_thread, NULL, (lvm_pthread_fn_t*)lvm_thread_fn,
 			(void *)(long)using_gulm);
 
 	/* Tell the rest of the cluster our version number */
@@ -1797,7 +1799,7 @@
 /*
  * Routine that runs in the "LVM thread".
  */
-static __attribute__ ((noreturn)) void *lvm_thread_fn(void *arg)
+static void lvm_thread_fn(void *arg)
 {
 	struct dm_list *cmdl, *tmp;
 	sigset_t ss;



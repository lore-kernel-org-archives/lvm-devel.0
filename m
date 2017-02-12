From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 12 Feb 2017 16:30:42 +0000 (UTC)
Subject: master - mem: add extra mem pages for pthread stack
Message-ID: <20170212163042.ADF28610A8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a9eda1229c9d5d7150acdd3d8dd4908fbc784a8
Commit:        2a9eda1229c9d5d7150acdd3d8dd4908fbc784a8
Parent:        8296b99a89b849d7d7b5dcac6214582b3eaad639
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 18:14:00 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 11 18:23:15 2017 +0100

mem: add extra mem pages for pthread stack

Some archs can use even 64K pages and then lvm2 runs into trouble if
the stack is 'too small' to fit extra page capturing stack overwrite.

So when lvm2 limits stack - add extra mem page - be it 4K or 64K.

Relates to ppc64le bug: https://bugzilla.redhat.com/1387279
---
 WHATS_NEW                        |    1 +
 WHATS_NEW_DM                     |    1 +
 daemons/clvmd/clvmd.c            |    2 +-
 daemons/dmeventd/dmeventd.c      |    2 +-
 libdaemon/server/daemon-server.c |    2 +-
 5 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e5f1ba1..b497c7e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Add extra memory page when limiting pthread stack size in clvmd.
   Support striped/raid0* <-> raid10_near conversions
   Support shrinking of RaidLvs
   Support region size changes on existing RaidLVs
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 47f647a..f11b28c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Add extra memory page when limiting pthread stack size in dmeventd.
   Avoids immediate resume when preloaded device is smaller.
   Do not suppress kernel key description in dmsetup table output.
   Support configurable command executed from dmeventd thin plugin.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a276c63..dcc986b 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -517,7 +517,7 @@ int main(int argc, char *argv[])
 	/* Initialise the LVM thread variables */
 	dm_list_init(&lvm_cmd_head);
 	if (pthread_attr_init(&stack_attr) ||
-	    pthread_attr_setstacksize(&stack_attr, STACK_SIZE)) {
+	    pthread_attr_setstacksize(&stack_attr, STACK_SIZE + getpagesize())) {
 		log_sys_error("pthread_attr_init", "");
 		exit(1);
 	}
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 58922ac..a2883a1 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -468,7 +468,7 @@ static int _pthread_create_smallstack(pthread_t *t, void *(*fun)(void *), void *
 	/*
 	 * We use a smaller stack since it gets preallocated in its entirety
 	 */
-	pthread_attr_setstacksize(&attr, THREAD_STACK_SIZE);
+	pthread_attr_setstacksize(&attr, THREAD_STACK_SIZE + getpagesize());
 
 	/*
 	 * If no-one will be waiting, we need to detach.
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 6af6de9..10cc8f7 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -42,7 +42,7 @@ static int _pthread_create(pthread_t *t, void *(*fun)(void *), void *arg, int st
 	/*
 	 * We use a smaller stack since it gets preallocated in its entirety
 	 */
-	pthread_attr_setstacksize(&attr, stacksize);
+	pthread_attr_setstacksize(&attr, stacksize + getpagesize());
 	return pthread_create(t, &attr, fun, arg);
 }
 #endif



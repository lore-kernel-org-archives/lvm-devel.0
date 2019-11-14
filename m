From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:08:01 -0500
Subject: master - cov: more checks for failing syscalls
Message-ID: <77153.119111412075901261@us-mta-420.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9ee3af7efc4bece83769a75586ffcb0f07a74d16
Commit:        9ee3af7efc4bece83769a75586ffcb0f07a74d16
Parent:        cbabdf2fca6131660cfb5525ed9edb3f7a41525a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 16:56:12 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: more checks for failing syscalls

---
 daemons/dmeventd/dmeventd.c      |    3 ++-
 libdaemon/server/daemon-server.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 33859ef..ae1e6a6 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1745,7 +1745,8 @@ static void _init_thread_signals(void)
 	sigdelset(&my_sigset, SIGHUP);
 	sigdelset(&my_sigset, SIGQUIT);
 
-	pthread_sigmask(SIG_BLOCK, &my_sigset, NULL);
+	if (pthread_sigmask(SIG_BLOCK, &my_sigset, NULL))
+		log_sys_error("pthread_sigmask", "SIG_BLOCK");
 }
 
 /*
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 66e43d4..0368a94 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -656,7 +656,8 @@ void daemon_start(daemon_state s)
 		failed = 1; /* FD out of available selectable set */
 
 	sigfillset(&new_set);
-	sigprocmask(SIG_SETMASK, NULL, &old_set);
+	if (sigprocmask(SIG_SETMASK, NULL, &old_set))
+		perror("sigprocmask error");
 
 	while (!failed) {
 		_reset_timeout(s);




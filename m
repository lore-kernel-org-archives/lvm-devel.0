From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:18 +0000 (GMT)
Subject: main - cov: mask some warning about leakage
Message-ID: <20210920133018.DE3653858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b5245199680841fd088cf1a834b3623b3ef18d0
Commit:        1b5245199680841fd088cf1a834b3623b3ef18d0
Parent:        548c69f58174b3cb3997c0fcff09276bd7502796
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 19 20:21:55 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: mask some warning about leakage

Mask false-positive leak report.
---
 daemons/cmirrord/clogd.c         | 1 +
 daemons/dmeventd/dmeventd.c      | 1 +
 lib/device/bcache.c              | 4 +++-
 libdaemon/server/daemon-server.c | 2 ++
 libdm/dm-tools/dmfilemapd.c      | 1 +
 test/lib/brick-shelltest.h       | 1 +
 test/unit/bcache_utils_t.c       | 2 ++
 test/unit/io_engine_t.c          | 1 +
 test/unit/radix_tree_t.c         | 1 +
 test/unit/run.c                  | 1 +
 tools/toollib.c                  | 2 ++
 11 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/daemons/cmirrord/clogd.c b/daemons/cmirrord/clogd.c
index c9f65af4c..a18354784 100644
--- a/daemons/cmirrord/clogd.c
+++ b/daemons/cmirrord/clogd.c
@@ -245,6 +245,7 @@ static void daemonize(void)
 	}
 
 	LOG_OPEN("cmirrord", LOG_PID, LOG_DAEMON);
+	/* coverity[leaked_handle] devnull cannot leak here */
 }
 
 /*
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index c44fa4ed9..75672a7fd 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1072,6 +1072,7 @@ out:
 	 * "label at end of compound statement" */
 	;
 
+	/* coverity[lock_order] _global_mutex is kept locked */
 	pthread_cleanup_pop(1);
 
 	return NULL;
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 790ff71d3..82b32644d 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -392,6 +392,7 @@ struct io_engine *create_async_io_engine(void)
 
 	e->page_mask = (unsigned) _pagesize - 1;
 
+	/* coverity[leaked_storage] 'e' is not leaking */
 	return &e->e;
 }
 
@@ -606,7 +607,8 @@ struct io_engine *create_sync_io_engine(void)
         e->e.wait = _sync_wait;
         e->e.max_io = _sync_max_io;
 
-        dm_list_init(&e->complete);
+	dm_list_init(&e->complete);
+	/* coverity[leaked_storage] 'e' is not leaking */
         return &e->e;
 }
 
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index aeb1870a3..88905a7dd 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -408,6 +408,8 @@ static void _daemonise(daemon_state s)
 	}
 
 	setsid();
+
+	/* coverity[leaked_handle] 'fd' handle is not leaking */
 }
 
 response daemon_reply_simple(const char *id, ...)
diff --git a/libdm/dm-tools/dmfilemapd.c b/libdm/dm-tools/dmfilemapd.c
index 3799efd83..d7ca71d7e 100644
--- a/libdm/dm-tools/dmfilemapd.c
+++ b/libdm/dm-tools/dmfilemapd.c
@@ -664,6 +664,7 @@ static int _daemonise(struct filemap_monitor *fm)
 			if (fd > STDERR_FILENO)
 				(void) close(fd);
 			_early_log("Error redirecting stdin/out/err to null.");
+			/* coverity[leaked_handle] no leak */
 			return 0;
 		}
 		if (fd > STDERR_FILENO)
diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 517c0f7d9..b3b62a308 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -482,6 +482,7 @@ struct Source {
 
     virtual void sync( Sink *sink ) {
         ssize_t sz;
+        /* coverity[stack_use_local_overflow] */
         char buf[ 128 * 1024 ];
         if ( (sz = read(fd, buf, sizeof(buf) - 1)) > 0 )
             sink->push( std::string( buf, sz ) );
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 48dab142e..73b8902fb 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -67,6 +67,7 @@ static void *_fix_init(struct io_engine *engine)
         T_ASSERT(f);
 
         snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
+	/* coverity[secure_temp] don't care */
 	f->fd = mkstemp(f->fname);
 	T_ASSERT(f->fd >= 0);
 
@@ -243,6 +244,7 @@ static void _reopen(struct fixture *f)
 
 static uint8_t _random_pattern(void)
 {
+	/* coverity[dont_call] don't care */
 	return random();
 }
 
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index d45d8ffa7..2f6ea5b03 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -89,6 +89,7 @@ static void *_fix_init(void)
         	test_fail("posix_memalign failed");
 
         snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
+	/* coverity[secure_temp] don't care */
 	f->fd = mkstemp(f->fname);
 	T_ASSERT(f->fd >= 0);
 
diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index 88c8bd5a7..be24ce76d 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -169,6 +169,7 @@ static void test_prefix_keys_reversed(void *fixture)
 static void _gen_key(uint8_t *b, uint8_t *e)
 {
 	for (; b != e; b++)
+		/* coverity[dont_call] don't care */
 		*b = rand() % 256;
 }
 
diff --git a/test/unit/run.c b/test/unit/run.c
index 0abd47246..24624aea9 100644
--- a/test/unit/run.c
+++ b/test/unit/run.c
@@ -200,6 +200,7 @@ static void _run_test(struct test_details *t, bool use_colour, unsigned *passed,
 
 		(*passed)++;
 		fprintf(stderr, "%s[     OK]%s\n", green(use_colour), normal(use_colour));
+		/* coverity[leaked_storage]  fixture released by fixture_exit */
 	}
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index fa3b2ffe3..0576a76fb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -111,6 +111,8 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 			_exit(ECMD_FAILED);
 	}
 
+	/* coverity[leaked_handle] null_fd does not leak here */
+
 	return 1;
 }
 



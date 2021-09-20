From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:12 +0000 (GMT)
Subject: main - cov: better defined constructors
Message-ID: <20210920133012.220913858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5c82b0e73421eb57bf36578b39813915af4676b
Commit:        d5c82b0e73421eb57bf36578b39813915af4676b
Parent:        ebd150366f0852e7ebd32e7743e6a135138320a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 10:26:05 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: better defined constructors

Ensure C++ initializes all struct members.
Also some deterministic buffer initialization.
---
 test/lib/brick-shelltest.h | 8 +++++---
 test/unit/bcache_utils_t.c | 3 ++-
 test/unit/run.c            | 1 +
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index b58f3d684..8637d8a9f 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -755,7 +755,7 @@ struct TestCase {
     }
 
     void pipe() {
-        int fds[2];
+        int fds[2] = { 0 };
 
         if (socketpair( PF_UNIX, SOCK_STREAM, 0, fds )) {
             perror("socketpair");
@@ -981,7 +981,9 @@ struct TestCase {
     }
 
     TestCase( Journal &j, Options opt, std::string path, std::string _name, std::string _flavour )
-        : child( path ), name( _name ), flavour( _flavour ), timeout( false ),
+        : child( path ), name( _name ), flavour( _flavour ),
+          iobuf( NULL ), usage( { 0 } ), status( 0 ), timeout( false ),
+          pid( 0 ), start( 0 ), end( 0 ), silent_start( 0 ),
           last_update( 0 ), last_heartbeat( 0 ), options( opt ), journal( &j )
     {
     }
@@ -1085,7 +1087,7 @@ struct Main {
         return journal.count( Journal::FAILED ) || journal.count( Journal::TIMEOUT ) ? 1 : 0;
     }
 
-    Main( Options o ) : die( false ), journal( o.outdir ), options( o ) {}
+    Main( Options o ) : die( false ), start( 0 ), journal( o.outdir ), options( o ) {}
 };
 
 namespace {
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 573fc1533..df2826977 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -52,9 +52,10 @@ static void *_fix_init(struct io_engine *engine)
         uint8_t buffer[T_BLOCK_SIZE];
         struct fixture *f = malloc(sizeof(*f));
         unsigned b, i;
-	struct statvfs fsdata;
+	struct statvfs fsdata = { 0 };
 	static int _runs_is_tmpfs = -1;
 
+	memset(buffer, 0, sizeof(buffer));
 	if (_runs_is_tmpfs == -1) {
 		// With testing in tmpfs directory O_DIRECT cannot be used
 		// tmpfs has  f_fsid == 0  (unsure if this is best guess)
diff --git a/test/unit/run.c b/test/unit/run.c
index 281991c51..0abd47246 100644
--- a/test/unit/run.c
+++ b/test/unit/run.c
@@ -271,6 +271,7 @@ int main(int argc, char **argv)
 		fprintf(stderr, "out of memory\n");
 		exit(1);
 	}
+	memset(t_array, 0, sizeof(*t_array) * nr_tests);
 
 	i = 0;
 	dm_list_iterate_items (ts, &suites)



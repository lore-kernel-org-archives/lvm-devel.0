From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:31 +0000 (UTC)
Subject: master - test: Avoid sleeps in the runner monitoring loop.
Message-ID: <20150205134131.CC27C60F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8cc9254e038b59bb6cc5ec9ba7793f9a82ab150
Commit:        e8cc9254e038b59bb6cc5ec9ba7793f9a82ab150
Parent:        48275c78361578672f5f3f5c29737404cf159f6d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 23:17:47 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Avoid sleeps in the runner monitoring loop.

---
 test/lib/runner.cpp |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index fde441b..1e61a68 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -115,7 +115,7 @@ struct TestCase {
 	bool timeout;
 	pid_t pid;
 
-	time_t start, end, silent_start;
+	time_t start, end, silent_start, last_update;
 	Options options;
 
 	Journal *journal;
@@ -175,13 +175,17 @@ struct TestCase {
 		wait.tv_sec = 0;
 		wait.tv_usec = 500000; /* timeout 0.5s */
 
-		if ( !options.verbose && !options.interactive && !options.batch )
-			progress( Update ) << tag( "running" ) << pretty() << " " << end - start << std::flush;
+		if ( !options.verbose && !options.interactive && !options.batch ) {
+			if ( end - last_update >= 1 ) {
+				progress( Update ) << tag( "running" ) << pretty() << " "
+						   << end - start << std::flush;
+				last_update = end;
+			}
+		}
 
 		if ( select( io.fd + 1, &set, NULL, NULL, &wait ) > 0 )
 			silent_start = end; /* something happened */
 
-		usleep(500000);
 		io.sync();
 
 		return true;



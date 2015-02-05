From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:13 +0000 (UTC)
Subject: master - test: Make the runner's heartbeat more reliable.
Message-ID: <20150205134213.A765D6036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34e818042e2dee149207cf3889792f0b87d4738e
Commit:        34e818042e2dee149207cf3889792f0b87d4738e
Parent:        f0d314bd6dcf22cee8e18c6e21fa06829a0f01ac
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 1 21:22:58 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

test: Make the runner's heartbeat more reliable.

---
 test/lib/runner.cpp |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 1522fd5..ffc5398 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -117,7 +117,7 @@ struct TestCase {
 	bool timeout;
 	pid_t pid;
 
-	time_t start, end, silent_start, last_update;
+	time_t start, end, silent_start, last_update, last_heartbeat;
 	Options options;
 
 	Journal *journal;
@@ -152,6 +152,16 @@ struct TestCase {
 
 	bool monitor() {
 		end = time( 0 );
+
+		/* heartbeat */
+		if ( end - last_heartbeat >= 20 ) {
+			std::string stampfile( options.outdir + "/timestamp" );
+			std::ofstream stamp( stampfile.c_str() );
+			stamp << end;
+			stamp.close();
+			fsync_name( stampfile );
+		}
+
 		if ( wait4(pid, &status, WNOHANG, &usage) != 0 ) {
 			io.sync();
 			return false;
@@ -192,15 +202,6 @@ struct TestCase {
 
 		io.sync();
 
-		/* heartbeat */
-		if ( time( 0 ) % 20 == 0 ) {
-			std::string stampfile( options.outdir + "/timestamp" );
-			std::ofstream stamp( stampfile.c_str() );
-			stamp << time( 0 );
-			stamp.close();
-			fsync_name( stampfile );
-		}
-
 		return true;
 	}
 
@@ -347,7 +348,8 @@ struct TestCase {
 	}
 
 	TestCase( Journal &j, Options opt, std::string path, std::string name, std::string flavour )
-		: timeout( false ), child( path ), name( name ), flavour( flavour ), options( opt ), journal( &j )
+		: timeout( false ), child( path ), name( name ), flavour( flavour ), options( opt ), journal( &j ),
+		  last_update( 0 ), last_heartbeat( 0 )
 	{
 	}
 };



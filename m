From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:19 +0000 (UTC)
Subject: master - test: Improve tracking of silence (stuck testcases) in the runner.
Message-ID: <20150205134119.202D660F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c8fb67fc21f7f5c651ea0b30961039c868a0bc6
Commit:        8c8fb67fc21f7f5c651ea0b30961039c868a0bc6
Parent:        dc1d15787830e37480925fbd5bb3ab04982ad1dd
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:21:20 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Improve tracking of silence (stuck testcases) in the runner.

---
 test/lib/runner.cpp |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 1a91738..0c99dbd 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -112,10 +112,9 @@ struct TestCase {
 	struct rusage usage;
 	int status;
 	bool timeout;
-	int silent_ctr;
 	pid_t pid;
 
-	time_t start, end;
+	time_t start, end, silent_start;
 	Options options;
 
 	Journal *journal;
@@ -148,11 +147,13 @@ struct TestCase {
 
 	bool monitor() {
 		end = time( 0 );
-		if ( wait4(pid, &status, WNOHANG, &usage) != 0 )
+		if ( wait4(pid, &status, WNOHANG, &usage) != 0 ) {
+			io.sync();
 			return false;
+		}
 
 		/* kill off tests after a minute of silence */
-		if ( silent_ctr > 2 * 60 ) {
+		if ( end - silent_start > 60 ) {
 			kill( pid, SIGINT );
 			sleep( 5 ); /* wait a bit for a reaction */
 			if ( waitpid( pid, &status, WNOHANG ) == 0 ) {
@@ -175,14 +176,10 @@ struct TestCase {
 		if ( !options.verbose && !options.interactive )
 			progress( Update ) << tag( "running" ) << pretty() << " " << end - start << std::flush;
 
-		if ( select( io.fd + 1, &set, NULL, NULL, &wait ) <= 0 )
-		{
-			silent_ctr++;
-			return true;
-		}
+		if ( select( io.fd + 1, &set, NULL, NULL, &wait ) > 0 )
+			silent_start = end; /* something happened */
 
 		io.sync();
-		silent_ctr = 0;
 
 		return true;
 	}
@@ -216,7 +213,10 @@ struct TestCase {
 		return null;
 	}
 
-	void parent() {
+	void parent()
+	{
+		silent_start = start = time( 0 );
+
 		while ( monitor() );
 
 		Journal::R r = Journal::UNKNOWN;



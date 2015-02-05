From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:27 +0000 (UTC)
Subject: master - test: Rename the --quiet option to --batch.
Message-ID: <20150205134127.80B0660F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=246fecee277cbabe6d377b80c43dee22485e3872
Commit:        246fecee277cbabe6d377b80c43dee22485e3872
Parent:        feb2c7bc4773e88f2fa96ef838e88d5b427835b0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 21:46:07 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Rename the --quiet option to --batch.

---
 test/lib/runner.cpp |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index bfcea91..fde441b 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -58,10 +58,10 @@ bool fatal_signal = false;
 bool interrupt = false;
 
 struct Options {
-	bool verbose, quiet, interactive, cont;
+	bool verbose, batch, interactive, cont;
 	std::string testdir, outdir;
 	std::vector< std::string > flavours;
-	Options() : verbose( false ), quiet( false ), interactive( false ), cont( false ) {}
+	Options() : verbose( false ), batch( false ), interactive( false ), cont( false ) {}
 };
 
 struct TestProcess
@@ -175,7 +175,7 @@ struct TestCase {
 		wait.tv_sec = 0;
 		wait.tv_usec = 500000; /* timeout 0.5s */
 
-		if ( !options.verbose && !options.interactive )
+		if ( !options.verbose && !options.interactive && !options.batch )
 			progress( Update ) << tag( "running" ) << pretty() << " " << end - start << std::flush;
 
 		if ( select( io.fd + 1, &set, NULL, NULL, &wait ) > 0 )
@@ -445,19 +445,19 @@ int main(int argc, char **argv)
 	if ( args.has( "--continue" ) )
 		opt.cont = true;
 
-	if ( args.has( "--quiet" ) || hasenv( "QUIET" ) ) {
+	if ( args.has( "--batch" ) || hasenv( "BATCH" ) ) {
 		opt.verbose = false;
-		opt.quiet = true;
+		opt.batch = true;
 	}
 
 	if ( args.has( "--verbose" ) || hasenv( "VERBOSE" ) ) {
-		opt.quiet = false;
+		opt.batch = false;
 		opt.verbose = true;
 	}
 
 	if ( args.has( "--interactive" ) || hasenv( "INTERACTIVE" ) ) {
 		opt.verbose = false;
-		opt.quiet = false;
+		opt.batch = false;
 		opt.interactive = true;
 	}
 



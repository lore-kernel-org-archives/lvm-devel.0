From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:21 +0000 (UTC)
Subject: master - test: Improve IO handling in the runner.
Message-ID: <20150205134121.3B98160F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efb3e7ca007f57c7627ef47e084d2f03cdc906f3
Commit:        efb3e7ca007f57c7627ef47e084d2f03cdc906f3
Parent:        8c8fb67fc21f7f5c651ea0b30961039c868a0bc6
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:23:02 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Improve IO handling in the runner.

---
 test/lib/runner.cpp |   36 ++++++++++++++++++++++++++++--------
 1 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 0c99dbd..7f1f495 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -108,6 +108,7 @@ struct TestCase {
 	TestProcess child;
 	std::string name, flavour;
 	IO io;
+	BufSink *iobuf;
 
 	struct rusage usage;
 	int status;
@@ -162,6 +163,7 @@ struct TestCase {
 				waitpid( pid, &status, 0 );
 			}
 			timeout = true;
+			io.sync();
 			return false;
 		}
 
@@ -179,6 +181,7 @@ struct TestCase {
 		if ( select( io.fd + 1, &set, NULL, NULL, &wait ) > 0 )
 			silent_start = end; /* something happened */
 
+		usleep(500000);
 		io.sync();
 
 		return true;
@@ -215,8 +218,16 @@ struct TestCase {
 
 	void parent()
 	{
+		::close( child.fd );
+		setupIO();
+
+		journal->started( id() );
 		silent_start = start = time( 0 );
 
+		progress( First ) << tag( "running" ) << pretty() << std::flush;
+		if ( options.verbose || options.interactive )
+			progress() << std::endl;
+
 		while ( monitor() );
 
 		Journal::R r = Journal::UNKNOWN;
@@ -243,8 +254,12 @@ struct TestCase {
 			close(fd_debuglog);
 		} */
 
+		if ( iobuf && r == Journal::FAILED || r == Journal::TIMEOUT )
+			iobuf->dump( std::cout );
+
 		journal->done( id(), r );
 		progress( Last ) << tag( r ) << pretty() << std::endl;
+		io.clear();
 	}
 
 	void run() {
@@ -258,21 +273,26 @@ struct TestCase {
 			setenv("LVM_TEST_FLAVOUR", flavour.c_str(), 1);
 			child.exec();
 		} else {
-			::close( child.fd );
-			journal->started( id() );
-			progress( First ) << tag( "running" ) << pretty() << std::flush;
-			if ( options.verbose || options.interactive )
-				progress() << std::endl;
-			start = time( 0 );
 			parent();
 		}
 	}
 
+	void setupIO() {
+		iobuf = 0;
+		if ( options.verbose )
+			io.sinks.push_back( new FdSink( 1 ) );
+		else
+			io.sinks.push_back( iobuf = new BufSink() );
+
+		std::string n = id();
+		std::replace( n.begin(), n.end(), '/', '_' );
+		std::string fn = options.outdir + "/" + n + ".txt";
+		io.sinks.push_back( new FileSink( fn ) );
+	}
+
 	TestCase( Journal &j, Options opt, std::string path, std::string name, std::string flavour )
 		: timeout( false ), child( path ), name( name ), flavour( flavour ), options( opt ), journal( &j )
 	{
-		if ( opt.verbose )
-			io.sinks.push_back( new FdSink( 1 ) );
 	}
 };
 



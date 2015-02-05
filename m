From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:38 +0000 (UTC)
Subject: master - test: Implement specialised --batch output style w/ rusage stats.
Message-ID: <20150205134138.16CA960F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23b5a006d405cfeb2ea270377e774297e368eed4
Commit:        23b5a006d405cfeb2ea270377e774297e368eed4
Parent:        a665b9062395e69327aa3ecfb85a047f759e8db7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 23:19:43 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Implement specialised --batch output style w/ rusage stats.

---
 test/lib/runner.cpp |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 7fcf9e2..f4da315 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -123,6 +123,8 @@ struct TestCase {
 	Journal *journal;
 
 	std::string pretty() {
+		if ( options.batch )
+			return flavour + ": " + name;
 		return "[" + flavour + "] " + name;
 	}
 
@@ -228,6 +230,8 @@ struct TestCase {
 	}
 
 	std::string tag( std::string n ) {
+		if ( options.batch )
+			return "## ";
 		int pad = (12 - n.length());
 		return "### " + std::string( pad, ' ' ) + n + ": ";
 	}
@@ -245,7 +249,10 @@ struct TestCase {
 	        static struct : std::streambuf {} buf;
 		static std::ostream null(&buf);
 
-		if ( isatty( STDOUT_FILENO ) ) {
+		if ( options.batch && p == First )
+			return std::cout;
+
+		if ( isatty( STDOUT_FILENO ) && !options.batch ) {
 			if ( p != First )
 				return std::cout << "\r";
 			return std::cout;
@@ -253,6 +260,7 @@ struct TestCase {
 
 		if ( p == Last )
 			return std::cout;
+
 		return null;
 	}
 
@@ -298,7 +306,14 @@ struct TestCase {
 			iobuf->dump( std::cout );
 
 		journal->done( id(), r );
-		progress( Last ) << tag( r ) << pretty() << std::endl;
+
+		if ( options.batch ) {
+			int spaces = std::max( 64 - int(pretty().length()), 0 );
+			progress( Last ) << " " << std::string( spaces, '.' ) << " " << r << std::endl;
+			if ( r == Journal::PASSED )
+				progress( First ) << "   " << rusage() << std::endl;
+		} else
+			progress( Last ) << tag( r ) << pretty() << std::endl;
 		io.clear();
 	}
 
@@ -322,7 +337,7 @@ struct TestCase {
 		iobuf = 0;
 		if ( options.verbose )
 			io.sinks.push_back( new FdSink( 1 ) );
-		else
+		else if ( !options.batch )
 			io.sinks.push_back( iobuf = new BufSink() );
 
 		std::string n = id();



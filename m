From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:48 +0000 (UTC)
Subject: master - test: Implement --only option to runner.
Message-ID: <20150205134148.8541260F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d488f032298ee6e8bf3f0abc50e2756f11a73196
Commit:        d488f032298ee6e8bf3f0abc50e2756f11a73196
Parent:        a8eb70209322f4344b9b11d190f64a9184fe23eb
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 1 14:07:27 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Implement --only option to runner.

---
 test/lib/runner.cpp |   31 ++++++++++++++++++++++++-------
 1 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 303b66d..1522fd5 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -62,7 +62,7 @@ bool interrupt = false;
 struct Options {
 	bool verbose, batch, interactive, cont;
 	std::string testdir, outdir;
-	std::vector< std::string > flavours;
+	std::vector< std::string > flavours, filter;
 	Options() : verbose( false ), batch( false ), interactive( false ), cont( false ) {}
 };
 
@@ -375,6 +375,15 @@ struct Main {
 					continue;
 				if ( i->substr( 0, 4 ) == "lib/" )
 					continue;
+				bool filter = !options.filter.empty();
+
+				for ( std::vector< std::string >::iterator filt = options.filter.begin();
+				      filt != options.filter.end(); ++filt ) {
+					if ( i->find( *filt ) != std::string::npos )
+						filter = false;
+				}
+				if ( filter )
+					continue;
 				cases.push_back( TestCase( journal, options, options.testdir + *i, *i, *flav ) );
 				cases.back().options = options;
 			}
@@ -473,6 +482,14 @@ bool hasenv( const char *name ) {
 	return true;
 }
 
+template< typename C >
+void split( std::string s, C &c ) {
+	std::stringstream ss( s );
+	std::string item;
+	while ( std::getline( ss, item, ',' ) )
+		c.push_back( item );
+}
+
 int main(int argc, char **argv)
 {
 	Args args( argc, argv );
@@ -481,6 +498,9 @@ int main(int argc, char **argv)
 	if ( args.has( "--continue" ) )
 		opt.cont = true;
 
+	if ( args.has( "--only" ) )
+		split( args.opt( "--only" ), opt.filter );
+
 	if ( args.has( "--batch" ) || hasenv( "BATCH" ) ) {
 		opt.verbose = false;
 		opt.batch = true;
@@ -497,12 +517,9 @@ int main(int argc, char **argv)
 		opt.interactive = true;
 	}
 
-	if ( args.has( "--flavours" ) ) {
-		std::stringstream ss( args.opt( "--flavours" ) );
-		std::string item;
-		while ( std::getline( ss, item, ',' ) )
-			opt.flavours.push_back( item );
-	} else
+	if ( args.has( "--flavours" ) )
+		split( args.opt( "--flavours" ), opt.flavours );
+	else
 		opt.flavours.push_back( "vanilla" );
 
 	opt.outdir = args.opt( "--outdir" );



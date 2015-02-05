From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:14 +0000 (UTC)
Subject: master - test: Implement flavours in the runner.
Message-ID: <20150205134114.E74A360F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d27833ba7ca2e6e80a01923e311b263681d4279d
Commit:        d27833ba7ca2e6e80a01923e311b263681d4279d
Parent:        f3bf89ebcc98a1e03c1687d6b292be3274a9bc8a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:13:14 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Implement flavours in the runner.

---
 test/lib/runner.cpp |   56 ++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 14c7d9f..1a91738 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -60,6 +60,7 @@ bool interrupt = false;
 struct Options {
 	bool verbose, quiet, interactive, cont;
 	std::string testdir, outdir;
+	std::vector< std::string > flavours;
 	Options() : verbose( false ), quiet( false ), interactive( false ), cont( false ) {}
 };
 
@@ -105,7 +106,7 @@ struct TestProcess
 
 struct TestCase {
 	TestProcess child;
-	std::string name;
+	std::string name, flavour;
 	IO io;
 
 	struct rusage usage;
@@ -119,6 +120,14 @@ struct TestCase {
 
 	Journal *journal;
 
+	std::string pretty() {
+		return "[" + flavour + "] " + name;
+	}
+
+	std::string id() {
+		return flavour + ":" + name;
+	}
+
 	void pipe() {
 		int fds[2];
 
@@ -164,7 +173,7 @@ struct TestCase {
 		wait.tv_usec = 500000; /* timeout 0.5s */
 
 		if ( !options.verbose && !options.interactive )
-			progress( Update ) << tag( "running" ) << name << " " << end - start << std::flush;
+			progress( Update ) << tag( "running" ) << pretty() << " " << end - start << std::flush;
 
 		if ( select( io.fd + 1, &set, NULL, NULL, &wait ) <= 0 )
 		{
@@ -234,8 +243,8 @@ struct TestCase {
 			close(fd_debuglog);
 		} */
 
-		journal->done( name, r );
-		progress( Last ) << tag( r ) << name << std::endl;
+		journal->done( id(), r );
+		progress( Last ) << tag( r ) << pretty() << std::endl;
 	}
 
 	void run() {
@@ -246,11 +255,12 @@ struct TestCase {
 			exit(201);
 		} else if (pid == 0) {
 			io.close();
+			setenv("LVM_TEST_FLAVOUR", flavour.c_str(), 1);
 			child.exec();
 		} else {
 			::close( child.fd );
-			journal->started( name );
-			progress( First ) << tag( "running" ) << name << std::flush;
+			journal->started( id() );
+			progress( First ) << tag( "running" ) << pretty() << std::flush;
 			if ( options.verbose || options.interactive )
 				progress() << std::endl;
 			start = time( 0 );
@@ -258,8 +268,8 @@ struct TestCase {
 		}
 	}
 
-	TestCase( Journal &j, Options opt, std::string path, std::string name )
-		: timeout( false ), silent_ctr( 0 ), child( path ), name( name ), options( opt ), journal( &j )
+	TestCase( Journal &j, Options opt, std::string path, std::string name, std::string flavour )
+		: timeout( false ), child( path ), name( name ), flavour( flavour ), options( opt ), journal( &j )
 	{
 		if ( opt.verbose )
 			io.sinks.push_back( new FdSink( 1 ) );
@@ -271,6 +281,7 @@ struct Main {
 	time_t start;
 
 	typedef std::vector< TestCase > Cases;
+	typedef std::vector< std::string > Flavours;
 
 	Journal journal;
 	Options options;
@@ -280,13 +291,17 @@ struct Main {
 		Listing l = listdir( options.testdir, true );
 		std::sort( l.begin(), l.end() );
 
-		for ( Listing::iterator i = l.begin(); i != l.end(); ++i ) {
-			if ( i->substr( i->length() - 3, i->length() ) != ".sh" )
-				continue;
-			if ( i->substr( 0, 4 ) == "lib/" )
-				continue;
-			cases.push_back( TestCase( journal, options, options.testdir + *i, *i ) );
-			cases.back().options = options;
+		for ( Flavours::iterator flav = options.flavours.begin();
+		      flav != options.flavours.end(); ++flav ) {
+
+			for ( Listing::iterator i = l.begin(); i != l.end(); ++i ) {
+				if ( i->substr( i->length() - 3, i->length() ) != ".sh" )
+					continue;
+				if ( i->substr( 0, 4 ) == "lib/" )
+					continue;
+				cases.push_back( TestCase( journal, options, options.testdir + *i, *i, *flav ) );
+				cases.back().options = options;
+			}
 		}
 
 		if ( options.cont )
@@ -300,7 +315,7 @@ struct Main {
 
 		for ( Cases::iterator i = cases.begin(); i != cases.end(); ++i ) {
 
-			if ( options.cont && journal.done( i->name ) )
+			if ( options.cont && journal.done( i->id() ) )
 				continue;
 
 			i->run();
@@ -316,6 +331,7 @@ struct Main {
 
 		journal.banner();
 		journal.write( options.outdir + "/list" );
+		fsync_name( options.outdir + "/list" );
 		if ( die || fatal_signal )
 			exit( 1 );
 	}
@@ -424,6 +440,14 @@ int main(int argc, char **argv)
 		opt.interactive = true;
 	}
 
+	if ( args.has( "--flavours" ) ) {
+		std::stringstream ss( args.opt( "--flavours" ) );
+		std::string item;
+		while ( std::getline( ss, item, ',' ) )
+			opt.flavours.push_back( item );
+	} else
+		opt.flavours.push_back( "vanilla" );
+
 	opt.outdir = args.opt( "--outdir" );
 	opt.testdir = args.opt( "--testdir" );
 



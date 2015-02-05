From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:47 +0000 (UTC)
Subject: master - test: Implement journalling and --continue.
Message-ID: <20150205134047.C519E602BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2dbc65f00abe5ccf44af3545a1ec1ddd5ebdad7
Commit:        d2dbc65f00abe5ccf44af3545a1ec1ddd5ebdad7
Parent:        9dfbce0aa72735048a788dd23f91f76fbc21dd23
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Jun 26 01:02:13 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:16 2015 +0100

test: Implement journalling and --continue.

---
 test/lib/journal.h  |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++
 test/lib/runner.cpp |   36 +++++++++++++++++++++-------
 2 files changed, 92 insertions(+), 9 deletions(-)

diff --git a/test/lib/journal.h b/test/lib/journal.h
index ff662f3..6d0e243 100644
--- a/test/lib/journal.h
+++ b/test/lib/journal.h
@@ -1,7 +1,10 @@
 // -*- C++ -*-
 
 #include <map>
+#include <string>
 #include <iostream>
+#include <fstream>
+#include <iterator>
 
 #ifndef RUNNER_JOURNAL_H
 #define RUNNER_JOURNAL_H
@@ -9,6 +12,7 @@
 struct Journal {
 	enum R {
 		STARTED,
+		RETRIED,
 		UNKNOWN,
 		FAILED,
 		INTERRUPTED,
@@ -32,9 +36,59 @@ struct Journal {
 		}
 	}
 
+	friend std::istream &operator>>( std::istream &i, R &r ) {
+		std::string x;
+		i >> x;
+
+		r = UNKNOWN;
+		if ( x == "started" ) r = STARTED;
+		if ( x == "retried" ) r = RETRIED;
+		if ( x == "failed" ) r = FAILED;
+		if ( x == "interrupted" ) r = INTERRUPTED;
+		if ( x == "passed" ) r = PASSED;
+		if ( x == "skipped" ) r = SKIPPED;
+		if ( x == "timeout" ) r = TIMEOUT;
+		if ( x == "warnings" ) r = WARNED;
+		return i;
+	}
+
+	template< typename S, typename T >
+	friend std::istream &operator>>( std::istream &i, std::pair< S, T > &r ) {
+		return i >> r.first >> r.second;
+	}
+
 	typedef std::map< std::string, R > Status;
 	Status status;
 
+	std::string location_tmp, location;
+
+	void sync() {
+		std::ofstream of( location_tmp.c_str() );
+		for ( Status::iterator i = status.begin(); i != status.end(); ++i )
+			of << i->first << " " << i->second << std::endl;
+		of.close();
+		rename( location_tmp.c_str(), location.c_str() );
+	}
+
+	void started( std::string n ) {
+		if ( status.count( n ) && status[ n ] == STARTED )
+			status[ n ] = RETRIED;
+		else
+			status[ n ] = STARTED;
+		sync();
+	}
+
+	void done( std::string n, R r ) {
+		status[ n ] = r;
+		sync();
+	}
+
+	bool done( std::string n ) {
+		if ( !status.count( n ) )
+			return false;
+		return status[ n ] != STARTED && status[ n ] != INTERRUPTED;
+	}
+
 	int count( R r ) {
 		int c = 0;
 		for ( Status::iterator i = status.begin(); i != status.end(); ++i )
@@ -53,6 +107,17 @@ struct Journal {
 			if ( i->second != PASSED )
 				std::cout << i->second << ": " << i->first << std::endl;
 	}
+
+	void read() {
+		std::ifstream ifs( location.c_str() );
+		typedef std::istream_iterator< std::pair< std::string, R > > It;
+		std::copy( It( ifs ), It(), std::inserter( status, status.begin() ) );
+	}
+
+	Journal( std::string dir )
+		: location( dir + "/journal" ),
+		  location_tmp( dir + "/journal.tmp" )
+	{}
 };
 
 #endif
diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 4180de3..0875b02 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -55,11 +55,12 @@
 
 pid_t kill_pid = 0;
 bool fatal_signal = false;
+bool interrupt = false;
 
 struct Options {
-	bool verbose, quiet, interactive;
+	bool verbose, quiet, interactive, cont;
 	std::string testdir, outdir;
-	Options() : verbose( false ), quiet( false ), interactive( false ) {}
+	Options() : verbose( false ), quiet( false ), interactive( false ), cont( false ) {}
 };
 
 struct TestProcess
@@ -115,6 +116,8 @@ struct TestCase {
 	time_t start, end;
 	Options options;
 
+	Journal *journal;
+
 	void pipe() {
 		int fds[2];
 
@@ -175,7 +178,7 @@ struct TestCase {
 	}
 
 	std::string tag( std::string n ) {
-		int pad = (8 - n.length());
+		int pad = (12 - n.length());
 		return "### " + std::string( pad, ' ' ) + n + ": ";
 	}
 
@@ -217,7 +220,9 @@ struct TestCase {
 				r = Journal::SKIPPED;
 			else
 				r = Journal::FAILED;
-		} else
+		} else if ( interrupt && WIFSIGNALED( status ) && WTERMSIG( status ) == SIGINT )
+			r = Journal::INTERRUPTED;
+		else
 			r = Journal::FAILED;
 
 		::close( io.fd );
@@ -228,6 +233,7 @@ struct TestCase {
 			close(fd_debuglog);
 		} */
 
+		journal->done( name, r );
 		progress( Last ) << tag( r ) << name << std::endl;
 	}
 
@@ -241,6 +247,7 @@ struct TestCase {
 			io.close();
 			child.exec();
 		} else {
+			journal->started( name );
 			progress( First ) << tag( "running" ) << name << std::flush;
 			if ( options.verbose || options.interactive )
 				progress() << std::endl;
@@ -249,8 +256,8 @@ struct TestCase {
 		}
 	}
 
-	TestCase( Options opt, std::string path, std::string name )
-		: timeout( false ), silent_ctr( 0 ), child( path ), name( name ), options( opt )
+	TestCase( Journal &j, Options opt, std::string path, std::string name )
+		: timeout( false ), silent_ctr( 0 ), child( path ), name( name ), options( opt ), journal( &j )
 	{
 		if ( opt.verbose )
 			io.sinks.push_back( new FdSink( 1 ) );
@@ -276,10 +283,12 @@ struct Main {
 				continue;
 			if ( i->substr( 0, 4 ) == "lib/" )
 				continue;
-			cases.push_back( TestCase( options, options.testdir + *i, *i ) );
+			cases.push_back( TestCase( journal, options, options.testdir + *i, *i ) );
 			cases.back().options = options;
 		}
 
+		if ( options.cont )
+			journal.read();
 	}
 
 	void run() {
@@ -288,6 +297,10 @@ struct Main {
 		std::cerr << "running " << cases.size() << " tests" << std::endl;
 
 		for ( Cases::iterator i = cases.begin(); i != cases.end(); ++i ) {
+
+			if ( options.cont && journal.done( i->name ) )
+				continue;
+
 			i->run();
 
 			if ( time(0) - start > 3 * 3600 ) {
@@ -304,14 +317,16 @@ struct Main {
 			exit( 1 );
 	}
 
-	Main( Options o ) : die( false ), options( o ) {}
+	Main( Options o ) : die( false ), options( o ), journal( o.outdir ) {}
 };
 
 static void handler( int sig ) {
-	signal( sig, SIG_DFL );
+	signal( sig, SIG_DFL ); /* die right away next time */
 	if ( kill_pid > 0 )
 		kill( -kill_pid, sig );
 	fatal_signal = true;
+	if ( sig == SIGINT )
+		interrupt = true;
 }
 
 void setup_handlers() {
@@ -378,6 +393,9 @@ int main(int argc, char **argv)
 	Args args( argc, argv );
 	Options opt;
 
+	if ( args.has( "--continue" ) )
+		opt.cont = true;
+
 	if ( args.has( "--quiet" ) || getenv( "QUIET" ) ) {
 		opt.verbose = false;
 		opt.quiet = true;



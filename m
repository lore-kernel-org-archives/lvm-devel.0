From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:15 +0000 (UTC)
Subject: master - test: Implement --fatal-timeouts to allow a timely VM restart.
Message-ID: <20150205134215.BD9A260755@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eec99ffa8c953883c7c22e9e39a42a63b452d611
Commit:        eec99ffa8c953883c7c22e9e39a42a63b452d611
Parent:        34e818042e2dee149207cf3889792f0b87d4738e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 1 21:34:06 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

test: Implement --fatal-timeouts to allow a timely VM restart.

---
 test/lib/journal.h  |    8 +++++++-
 test/lib/runner.cpp |   16 ++++++++++++++--
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/test/lib/journal.h b/test/lib/journal.h
index 8913d7c..1e0a742 100644
--- a/test/lib/journal.h
+++ b/test/lib/journal.h
@@ -89,6 +89,7 @@ struct Journal {
 	Status status, written;
 
 	std::string location, list;
+	int timeouts;
 
 	void append( std::string path ) {
 		std::ofstream of( path.c_str(), std::fstream::app );
@@ -126,6 +127,10 @@ struct Journal {
 
 	void done( std::string n, R r ) {
 		status[ n ] = r;
+		if ( r == TIMEOUT )
+			++ timeouts;
+		else
+			timeouts = 0;
 		sync();
 	}
 
@@ -165,7 +170,8 @@ struct Journal {
 
 	Journal( std::string dir )
 		: location( dir + "/journal" ),
-		  list( dir + "/list" )
+		  list( dir + "/list" ),
+		  timeouts( 0 )
 	{}
 };
 
diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index ffc5398..67a9b87 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -60,10 +60,11 @@ bool fatal_signal = false;
 bool interrupt = false;
 
 struct Options {
-	bool verbose, batch, interactive, cont;
+	bool verbose, batch, interactive, cont, fatal_timeouts;
 	std::string testdir, outdir;
 	std::vector< std::string > flavours, filter;
-	Options() : verbose( false ), batch( false ), interactive( false ), cont( false ) {}
+	Options() : verbose( false ), batch( false ), interactive( false ),
+		    cont( false ), fatal_timeouts( false ) {}
 };
 
 struct TestProcess
@@ -409,6 +410,14 @@ struct Main {
 
 			i->run();
 
+			if ( options.fatal_timeouts && journal.timeouts >= 2 ) {
+				journal.started( i->id() ); // retry the test on --continue
+				std::cerr << "E: Hit 2 timeouts in a row with --fatal-timeouts" << std::endl;
+				std::cerr << "Suspending (please restart the VM)." << std::endl;
+				sleep( 3600 );
+				die = 1;
+			}
+
 			if ( time(0) - start > 3 * 3600 ) {
 				std::cerr << "3 hours passed, giving up..." << std::endl;
 				die = 1;
@@ -503,6 +512,9 @@ int main(int argc, char **argv)
 	if ( args.has( "--only" ) )
 		split( args.opt( "--only" ), opt.filter );
 
+	if ( args.has( "--fatal-timeouts" ) )
+		opt.fatal_timeouts = true;
+
 	if ( args.has( "--batch" ) || hasenv( "BATCH" ) ) {
 		opt.verbose = false;
 		opt.batch = true;



From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:40 +0000 (UTC)
Subject: master - test: Use append for journal maintenance instead of rename.
Message-ID: <20150205134140.353CC60F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3caba849d28b7dd82a89f9cedbc0e9d0de273b7
Commit:        b3caba849d28b7dd82a89f9cedbc0e9d0de273b7
Parent:        23b5a006d405cfeb2ea270377e774297e368eed4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Jun 28 11:15:13 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Use append for journal maintenance instead of rename.

---
 test/lib/journal.h  |   36 ++++++++++++++++++++----------------
 test/lib/runner.cpp |    4 ++--
 2 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/test/lib/journal.h b/test/lib/journal.h
index 020afe3..4335f71 100644
--- a/test/lib/journal.h
+++ b/test/lib/journal.h
@@ -61,9 +61,21 @@ struct Journal {
 	}
 
 	typedef std::map< std::string, R > Status;
-	Status status;
+	Status status, written;
 
-	std::string location_tmp, location;
+	std::string location, list;
+
+	void append( std::string path ) {
+		std::ofstream of( path.c_str(), std::fstream::app );
+		Status::iterator writ;
+		for ( Status::iterator i = status.begin(); i != status.end(); ++i ) {
+			writ = written.find( i->first );
+			if ( writ == written.end() || writ->second != i->second )
+				of << i->first << " " << i->second << std::endl;
+		}
+		written = status;
+		of.close();
+	}
 
 	void write( std::string path ) {
 		std::ofstream of( path.c_str() );
@@ -73,9 +85,10 @@ struct Journal {
 	}
 
 	void sync() {
-		write( location_tmp );
-		fsync_name( location_tmp );
-		rename( location_tmp.c_str(), location.c_str() );
+		append( location );
+		fsync_name( location );
+		write ( list );
+		fsync_name( list );
 	}
 
 	void started( std::string n ) {
@@ -122,20 +135,11 @@ struct Journal {
 		std::copy( It( ifs ), It(), std::inserter( status, status.begin() ) );
 	}
 
-	void read() {
-		struct stat64 stat;
-		if ( ::stat64( location.c_str(), &stat ) == 0 )
-			read( location );
-		/* on CIFS, rename might fail halfway through, with journal
-	         * already gone but journal.tmp not yet replacing it... in that
-	         * case, pick up journal.tmp */
-		else if ( ::stat64( location_tmp.c_str(), &stat ) == 0 )
-			read( location_tmp );
-	}
+	void read() { read( location ); }
 
 	Journal( std::string dir )
 		: location( dir + "/journal" ),
-		  location_tmp( dir + "/journal.tmp" )
+		  list( dir + "/list" )
 	{}
 };
 
diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index f4da315..027f216 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -382,6 +382,8 @@ struct Main {
 
 		if ( options.cont )
 			journal.read();
+		else
+			::unlink( journal.location.c_str() );
 	}
 
 	void run() {
@@ -406,8 +408,6 @@ struct Main {
 		}
 
 		journal.banner();
-		journal.write( options.outdir + "/list" );
-		fsync_name( options.outdir + "/list" );
 		if ( die || fatal_signal )
 			exit( 1 );
 	}



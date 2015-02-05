From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:17 +0000 (UTC)
Subject: master - test: Make the runner's journal more reliable.
Message-ID: <20150205134117.0C04D60F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc1d15787830e37480925fbd5bb3ab04982ad1dd
Commit:        dc1d15787830e37480925fbd5bb3ab04982ad1dd
Parent:        d27833ba7ca2e6e80a01923e311b263681d4279d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:19:15 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Make the runner's journal more reliable.

---
 test/lib/filesystem.h |    9 +++++++++
 test/lib/journal.h    |   19 +++++++++++++++++--
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/test/lib/filesystem.h b/test/lib/filesystem.h
index 718c433..2ae0c09 100644
--- a/test/lib/filesystem.h
+++ b/test/lib/filesystem.h
@@ -48,6 +48,15 @@ struct dir {
 
 typedef std::vector< std::string > Listing;
 
+inline void fsync_name( std::string n )
+{
+	int fd = open( n.c_str(), O_WRONLY );
+	if ( fd >= 0 ) {
+		fsync( fd );
+		close( fd );
+	}
+}
+
 inline Listing listdir( std::string p, bool recurse = false, std::string prefix = "" )
 {
 	Listing r;
diff --git a/test/lib/journal.h b/test/lib/journal.h
index d2f028c..020afe3 100644
--- a/test/lib/journal.h
+++ b/test/lib/journal.h
@@ -1,5 +1,7 @@
 // -*- C++ -*-
 
+#include "filesystem.h"
+
 #include <map>
 #include <string>
 #include <iostream>
@@ -26,6 +28,7 @@ struct Journal {
 	friend std::ostream &operator<<( std::ostream &o, R r ) {
 		switch ( r ) {
 			case STARTED: return o << "started";
+			case RETRIED: return o << "retried";
 			case FAILED: return o << "failed";
 			case INTERRUPTED: return o << "interrupted";
 			case PASSED: return o << "passed";
@@ -71,6 +74,7 @@ struct Journal {
 
 	void sync() {
 		write( location_tmp );
+		fsync_name( location_tmp );
 		rename( location_tmp.c_str(), location.c_str() );
 	}
 
@@ -112,12 +116,23 @@ struct Journal {
 				std::cout << i->second << ": " << i->first << std::endl;
 	}
 
-	void read() {
-		std::ifstream ifs( location.c_str() );
+	void read( std::string n ) {
+		std::ifstream ifs( n.c_str() );
 		typedef std::istream_iterator< std::pair< std::string, R > > It;
 		std::copy( It( ifs ), It(), std::inserter( status, status.begin() ) );
 	}
 
+	void read() {
+		struct stat64 stat;
+		if ( ::stat64( location.c_str(), &stat ) == 0 )
+			read( location );
+		/* on CIFS, rename might fail halfway through, with journal
+	         * already gone but journal.tmp not yet replacing it... in that
+	         * case, pick up journal.tmp */
+		else if ( ::stat64( location_tmp.c_str(), &stat ) == 0 )
+			read( location_tmp );
+	}
+
 	Journal( std::string dir )
 		: location( dir + "/journal" ),
 		  location_tmp( dir + "/journal.tmp" )



From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:51 +0000 (UTC)
Subject: master - test: Write a results/list at the end of a test run.
Message-ID: <20150205134051.EBF386105C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa46385164e971d998ef89f20162fe547efeaea0
Commit:        fa46385164e971d998ef89f20162fe547efeaea0
Parent:        bf1693786905777d0ad0857797fe742889eebcd4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Jun 26 01:11:19 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Write a results/list at the end of a test run.

---
 test/lib/journal.h  |    8 ++++++--
 test/lib/runner.cpp |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/test/lib/journal.h b/test/lib/journal.h
index 6d0e243..d2f028c 100644
--- a/test/lib/journal.h
+++ b/test/lib/journal.h
@@ -62,11 +62,15 @@ struct Journal {
 
 	std::string location_tmp, location;
 
-	void sync() {
-		std::ofstream of( location_tmp.c_str() );
+	void write( std::string path ) {
+		std::ofstream of( path.c_str() );
 		for ( Status::iterator i = status.begin(); i != status.end(); ++i )
 			of << i->first << " " << i->second << std::endl;
 		of.close();
+	}
+
+	void sync() {
+		write( location_tmp );
 		rename( location_tmp.c_str(), location.c_str() );
 	}
 
diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index a0f9fbd..287b8f9 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -315,6 +315,7 @@ struct Main {
 		}
 
 		journal.banner();
+		journal.write( options.outdir + "/list" );
 		if ( die || fatal_signal )
 			exit( 1 );
 	}



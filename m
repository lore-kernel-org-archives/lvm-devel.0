From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:33 +0000 (UTC)
Subject: master - test: Print a heartbeat file (every 20s) in the runner.
Message-ID: <20150205134133.E40CC60F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fbea6029d77ce49434d0680b34d9dd367bce755
Commit:        3fbea6029d77ce49434d0680b34d9dd367bce755
Parent:        e8cc9254e038b59bb6cc5ec9ba7793f9a82ab150
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 23:18:14 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Print a heartbeat file (every 20s) in the runner.

---
 test/lib/runner.cpp |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 1e61a68..b617110 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -188,6 +188,15 @@ struct TestCase {
 
 		io.sync();
 
+		/* heartbeat */
+		if ( time( 0 ) % 20 == 0 ) {
+			std::string stampfile( options.outdir + "/timestamp" );
+			std::ofstream stamp( stampfile.c_str() );
+			stamp << time( 0 );
+			stamp.close();
+			fsync_name( stampfile );
+		}
+
 		return true;
 	}
 



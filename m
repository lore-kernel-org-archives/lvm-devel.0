From: David Teigland <teigland@sourceware.org>
Date: Mon, 16 Sep 2019 12:46:03 -0400
Subject: master - tests: don't change real test output
Message-ID: <201909161646.x8GGk3g3009540@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df36a8eadfbbfe547cc734259dfc598cb773b59c
Commit:        df36a8eadfbbfe547cc734259dfc598cb773b59c
Parent:        196a9ed59fa65666a1efa26440166ace6206e545
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 12 14:45:13 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 12 14:45:13 2019 -0500

tests: don't change real test output

---
 test/lib/brick-shelltest.h |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 56429c7..b58f3d6 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -376,20 +376,6 @@ struct Substitute {
     std::string prefix;
 
     std::string map( std::string line ) {
-        if ( std::string( line, 0, 9 ) == "@TESTDIR=" )
-            testdir = std::string( line, 9, line.length() - 10 ); // skip \n
-        else if ( std::string( line, 0, 8 ) == "@PREFIX=" )
-            prefix = std::string( line, 8, line.length() - 9 );  // skip \n
-        else {
-            size_t off;
-            if (!testdir.empty())
-                while ( (off = line.find( testdir )) != std::string::npos )
-                    line.replace( off, testdir.length(), "@TESTDIR@" );
-
-            if (!prefix.empty())
-                while ( (off = line.find( prefix )) != std::string::npos )
-                    line.replace( off, prefix.length(), "@PREFIX@" );
-        }
         return line;
     }
 };



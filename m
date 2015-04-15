From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Apr 2015 11:38:26 +0000 (UTC)
Subject: master - tests: align test result in batch mode
Message-ID: <20150415113826.1CD3360F79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53c2c4562555cbc00b2b78cb4394ee3f2b7f0729
Commit:        53c2c4562555cbc00b2b78cb4394ee3f2b7f0729
Parent:        e478471dd54835b88d68d6d5b372e00b311807a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 15 09:49:19 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 15 13:35:42 2015 +0200

tests: align test result in batch mode

---
 test/lib/brick-shelltest.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 362ee8a..54114db 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -921,7 +921,8 @@ struct TestCase {
 
         if ( options.batch ) {
             int spaces = std::max( 64 - int(pretty().length()), 0 );
-            progress( Last ) << " " << std::string( spaces, '.' ) << " " << r;
+            progress( Last ) << " " << std::string( spaces, '.' ) << " "
+                << std::left << std::setw( 9 ) << std::setfill( ' ' ) << r;
             if ( r != Journal::SKIPPED )
                 progress( First ) << "   " << rusage();
             progress( Last ) << std::endl;



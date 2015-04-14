From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 14 Apr 2015 11:31:32 +0000 (UTC)
Subject: master - tests: rusage skipped only for skipped
Message-ID: <20150414113132.F094A60B47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75454c2b32c7f9dfd7c75a04ca2926fbf44ebb9e
Commit:        75454c2b32c7f9dfd7c75a04ca2926fbf44ebb9e
Parent:        4cdf155a87211d269ae31c70856f580111fca186
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 14 11:15:42 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 14 13:29:43 2015 +0200

tests: rusage skipped only for skipped

---
 test/lib/brick-shelltest.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 00f1616..4540a71 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -917,7 +917,7 @@ struct TestCase {
         if ( options.batch ) {
             int spaces = std::max( 64 - int(pretty().length()), 0 );
             progress( Last ) << " " << std::string( spaces, '.' ) << " " << r;
-            if ( r == Journal::PASSED )
+            if ( r != Journal::SKIPPED )
                 progress( First ) << "   " << rusage();
             progress( Last ) << std::endl;
         } else



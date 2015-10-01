From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu,  1 Oct 2015 11:20:11 +0000 (UTC)
Subject: master - test: Fix timeout handling
Message-ID: <20151001112011.9B65860553@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efcb3bbc8d2ebcc39031cc0d7b446daf864d281e
Commit:        efcb3bbc8d2ebcc39031cc0d7b446daf864d281e
Parent:        309979d57891912b977edbd89970bf25614ee9eb
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Oct 1 13:17:00 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Oct 1 13:19:29 2015 +0200

test: Fix timeout handling

Timeouts were considered as warnings only. Signalling failure is
preferred.
---
 test/lib/brick-shelltest.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index b29e626..0659d8e 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -267,7 +267,7 @@ struct Journal {
         std::cout << std::endl << "### " << status.size() << " tests: "
                   << count( PASSED ) << " passed, "
                   << count( SKIPPED ) << " skipped, "
-                  << count( TIMEOUT ) + count( WARNED ) << " broken, "
+                  << count( TIMEOUT ) << " timed out, " << count( WARNED ) << " warned, "
                   << count( FAILED ) << " failed" << std::endl;
     }
 
@@ -1047,7 +1047,7 @@ struct Main {
         if ( die || fatal_signal )
             return 1;
 
-        return journal.count( Journal::FAILED ) ? 1 : 0;
+        return journal.count( Journal::FAILED ) || journal.count( Journal::TIMEOUT ) ? 1 : 0;
     }
 
     Main( Options o ) : die( false ), journal( o.outdir ), options( o ) {}



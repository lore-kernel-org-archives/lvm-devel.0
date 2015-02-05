From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:42 +0000 (UTC)
Subject: master - test: Fix a precedence bug in the runner.
Message-ID: <20150205134142.4B9B560F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10c992e861175498b9007067db493d5ba0a97727
Commit:        10c992e861175498b9007067db493d5ba0a97727
Parent:        b3caba849d28b7dd82a89f9cedbc0e9d0de273b7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Jun 28 11:15:28 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Fix a precedence bug in the runner.

---
 test/lib/runner.cpp |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 027f216..303b66d 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -302,7 +302,7 @@ struct TestCase {
 			close(fd_debuglog);
 		} */
 
-		if ( iobuf && r == Journal::FAILED || r == Journal::TIMEOUT )
+		if ( iobuf && ( r == Journal::FAILED || r == Journal::TIMEOUT ) )
 			iobuf->dump( std::cout );
 
 		journal->done( id(), r );



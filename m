From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:44 +0000 (UTC)
Subject: master - test: Fix a segfault in the test runner.
Message-ID: <20150205134344.93D3E60FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4686b8cea57d0c36759b73a5448e6c0f99405132
Commit:        4686b8cea57d0c36759b73a5448e6c0f99405132
Parent:        45e2aee8f9173cc2858da93a4bb9bc289a36bf9d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 16:04:21 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: Fix a segfault in the test runner.

---
 test/lib/brick-shelltest.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 7a2b8f0..99e6639 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -600,11 +600,11 @@ struct IO : Sink {
     Observer &observer() { return *_observer; }
 
     IO() {
-        sinks.push_back( _observer = new Observer );
+        clear();
     }
 
     /* a stealing copy constructor */
-    IO( const IO &io ) : sinks( io.sinks ), sources( io.sources )
+    IO( const IO &io ) : sinks( io.sinks ), sources( io.sources ), _observer( io._observer )
     {
         io.sinks.clear();
         io.sources.clear();
@@ -619,6 +619,7 @@ struct IO : Sink {
         for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
             delete *i;
         sinks.clear();
+        sinks.push_back( _observer = new Observer );
     }
 
     ~IO() { close(); clear(); }



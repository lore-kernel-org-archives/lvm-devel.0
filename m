From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 23:16:36 +0000 (UTC)
Subject: master - tests: avoid loop on older system
Message-ID: <20150311231636.9CB3260D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eded54df7ba781afa9da14dd1a79b132aba255eb
Commit:        eded54df7ba781afa9da14dd1a79b132aba255eb
Parent:        26f5ec0e98ff067d7198a41908f35a62dda8f88b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 12 00:07:45 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 12 00:07:45 2015 +0100

tests: avoid loop on older system

Cleanup overload of 'push'.
Don't busy-loop when reading is finished.
---
 test/lib/brick-shelltest.h |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 9bdc94b..60aab20 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -463,6 +463,19 @@ struct Source {
         char buf[ 128 * 1024 ];
         if ( (sz = read(fd, buf, sizeof(buf) - 1)) > 0 )
             sink->push( std::string( buf, sz ) );
+
+        /*
+         * On RHEL5 box this code busy-loops here, while
+         * parent process no longer writes anything.
+         *
+         * Unclear why 'select()' is anouncing available
+         * data, while we read 0 bytes with errno == 0.
+         *
+         * Temporarily resolved with usleep() instead of loop.
+         */
+        if (!sz && (!errno || errno == EINTR))
+            usleep(50000);
+
         if ( sz < 0 && errno != EAGAIN )
             throw syserr( "reading pipe" );
     }
@@ -625,11 +638,11 @@ struct IO : Sink {
         return *new (this) IO( io );
     }
 
-    void clear(int push = 1) {
+    void clear( int to_push = 1 ) {
         for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
             delete *i;
         sinks.clear();
-        if (push)
+        if ( to_push )
             sinks.push_back( _observer = new Observer );
     }
 



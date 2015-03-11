From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 20:17:48 +0000 (UTC)
Subject: master - tests: update runner
Message-ID: <20150311201748.11DEC60F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26f5ec0e98ff067d7198a41908f35a62dda8f88b
Commit:        26f5ec0e98ff067d7198a41908f35a62dda8f88b
Parent:        1ad9677cb363f0f38b07a7d82add0f4479c08411
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 21:13:41 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 21:17:23 2015 +0100

tests: update runner

Avoid busy-looping on CPU while reading socket pipe
and always call read only when select tells there is
something for read.

Change the batch output to old nicer output.
---
 test/lib/brick-shelltest.h |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 7c49fa3..9bdc94b 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -461,7 +461,7 @@ struct Source {
     virtual void sync( Sink *sink ) {
         ssize_t sz;
         char buf[ 128 * 1024 ];
-        while ( (sz = read(fd, buf, sizeof(buf) - 1)) > 0 )
+        if ( (sz = read(fd, buf, sizeof(buf) - 1)) > 0 )
             sink->push( std::string( buf, sz ) );
         if ( sz < 0 && errno != EAGAIN )
             throw syserr( "reading pipe" );
@@ -720,10 +720,12 @@ struct TestCase {
             exit(201);
         }
 
+#if 0
         if (fcntl( fds[0], F_SETFL, O_NONBLOCK ) == -1) {
             perror("fcntl on socket");
             exit(202);
         }
+#endif
 
         io.sources.push_back( new Source( fds[0] ) );
         child.fd = fds[1];
@@ -747,7 +749,7 @@ struct TestCase {
             return false;
         }
 
-        /* kill off tests after a minute of silence */
+        /* kill off tests after a timeout silence */
         if ( !options.interactive )
             if ( end - silent_start > options.timeout ) {
                 kill( pid, SIGINT );
@@ -777,11 +779,10 @@ struct TestCase {
                 last_update = end;
             }
         }
-
-        if ( select( nfds, &set, NULL, NULL, &wait ) > 0 )
+        if ( select( nfds, &set, NULL, NULL, &wait ) > 0 ) {
             silent_start = end; /* something happened */
-
-        io.sync( false );
+            io.sync( false );
+        }
 
         return true;
     }
@@ -890,9 +891,10 @@ struct TestCase {
 
         if ( options.batch ) {
             int spaces = std::max( 64 - int(pretty().length()), 0 );
-            progress( Last ) << " " << std::string( spaces, '.' ) << " " << r << std::endl;
+            progress( Last ) << " " << std::string( spaces, '.' ) << " " << r;
             if ( r == Journal::PASSED )
-                progress( First ) << "   " << rusage() << std::endl;
+                progress( First ) << "   " << rusage();
+            progress( Last ) << std::endl;
         } else
             progress( Last ) << tag( r ) << pretty() << std::endl;
 



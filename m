From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 20:17:39 +0000 (UTC)
Subject: master - tests: do not leak in mem in destructor
Message-ID: <20150311201739.B655660242@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bdf4e3e2f20dd186f3640e808930c152fc8d77e9
Commit:        bdf4e3e2f20dd186f3640e808930c152fc8d77e9
Parent:        e7e499e80fa31c7c465d43e11e14c2342477ee53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 15:41:53 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 21:17:23 2015 +0100

tests: do not leak in mem in destructor

---
 test/lib/brick-shelltest.h |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 820aa81..7c49fa3 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -625,14 +625,15 @@ struct IO : Sink {
         return *new (this) IO( io );
     }
 
-    void clear() {
+    void clear(int push = 1) {
         for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
             delete *i;
         sinks.clear();
-        sinks.push_back( _observer = new Observer );
+        if (push)
+            sinks.push_back( _observer = new Observer );
     }
 
-    ~IO() { close(); clear(); }
+    ~IO() { close(); clear(0); }
 
 };
 
@@ -659,7 +660,7 @@ struct TestProcess
     bool interactive;
     int fd;
 
-    void exec() {
+    void exec() __attribute__ ((noreturn)) {
         assert( fd >= 0 );
         if ( !interactive ) {
             int devnull = ::open( "/dev/null", O_RDONLY );
@@ -858,7 +859,8 @@ struct TestCase {
         if ( options.verbose || options.interactive )
             progress() << std::endl;
 
-        while ( monitor() );
+        while ( monitor() )
+            /* empty */ ;
 
         Journal::R r = Journal::UNKNOWN;
 



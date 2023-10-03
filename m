From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Tue, 03 Oct 2023 10:48:16 +0000
Subject: [Git][lvmteam/lvm2][main] 2 commits: tests: restore old fsync method
Message-ID: <651bf17040e45_29a5294891ed@gitlab-sidekiq-low-urgency-cpu-bound-v2-5b59ddf494-jmzct.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
48fd6d6d by Zdenek Kabelac at 2023-10-03T12:46:32+02:00
tests: restore old fsync method

New code isn&#39;t portable across wider range of c++ compilers.

- - - - -
c818f3da by Zdenek Kabelac at 2023-10-03T12:46:32+02:00
tests: give some more time to die

VMs are not top performers here...

- - - - -


2 changed files:

- test/lib/brick-shelltest.h
- test/shell/dmeventd-restart.sh


Changes:

=====================================
test/lib/brick-shelltest.h
=====================================
@@ -153,14 +153,13 @@ public:
     }
 };
 
-int get_fd(std::filebuf& filebuf)
+static void _fsync_name( std::string n )
 {
-    class my_filebuf : public std::filebuf {
-    public:
-        int handle() { return _M_file.fd(); }
-    };
-
-    return static_cast<my_filebuf&>(filebuf).handle();
+    int fd = open( n.c_str(), O_WRONLY );
+    if ( fd >= 0 ) {
+        (void) fsync( fd );
+        (void) close( fd );
+    }
 }
 
 struct dir {
@@ -308,7 +307,6 @@ struct Journal {
         }
         written = status;
         of.flush();
-        fsync( get_fd( *of.rdbuf() ) );
         of.close();
     }
 
@@ -316,14 +314,15 @@ struct Journal {
         std::ofstream of( path.c_str() );
         for ( Status::const_iterator i = status.begin(); i != status.end(); ++i )
             of << i->first << " "  << i->second << std::endl;
-        of.flush();
-        fsync( get_fd( *of.rdbuf() ) );
+         of.flush();
          of.close();
     }
 
     void sync() {
         append( location );
+        _fsync_name( location );
         write ( list );
+        _fsync_name( list );
     }
 
     void started( const std::string &n ) {
@@ -910,8 +909,8 @@ struct TestCase {
             std::ofstream hb( options.heartbeat.c_str(), std::fstream::app );
             hb << ".";
             hb.flush();
-            fsync( get_fd( *hb.rdbuf() ) );
             hb.close();
+            _fsync_name( options.heartbeat );
             last_heartbeat.gettime();
         }
 


=====================================
test/shell/dmeventd-restart.sh
=====================================
@@ -80,9 +80,9 @@ pgrep -o dmeventd
 
 # Create a file simulating 'shutdown in progress'
 touch test_nologin
-sleep 1.1
+sleep 2
 
-# Should be now dead (within 1 second)
+# Should be now dead (within ~1 second)
 not pgrep -o dmeventd
 rm -f LOCAL_DMEVENTD
 



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/6f520916688f0fce9f6dfde4747e45f1bf54c9ad...c818f3dabc2390303b45820ddfcb3fbb5de694c0

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/6f520916688f0fce9f6dfde4747e45f1bf54c9ad...c818f3dabc2390303b45820ddfcb3fbb5de694c0
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231003/d42bcf56/attachment-0001.htm>

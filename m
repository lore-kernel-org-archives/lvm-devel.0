From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Tue, 03 Oct 2023 00:02:12 +0000
Subject: [Git][lvmteam/lvm2][main] 3 commits: tests: restore fsync for runner
Message-ID: <651b5a04e94eb_2aa526c9332@gitlab-sidekiq-low-urgency-cpu-bound-v2-5cf6c75464-zxxks.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
13bf42b8 by Zdenek Kabelac at 2023-10-03T01:58:23+02:00
tests: restore fsync for runner

Restore fsync() call For more accurate tracking by buildbot.
Try different rather tricky way of static_cast to use
already opened FD instead of seperate open(),fsync(),close().

It&#39;s pretty strange there is no way to enforce fsync() for
C++ iostreams.  Flush() is actully not equal.

- - - - -
d01e9de8 by Zdenek Kabelac at 2023-10-03T02:01:29+02:00
tests: add RT_LIBS for older g++

- - - - -
6f520916 by Zdenek Kabelac at 2023-10-03T02:01:29+02:00
tests: give dmeventd some time to restart

We need to wait for a new dmeventd as fork new daemon from bash.

- - - - -


3 changed files:

- test/Makefile.in
- test/lib/brick-shelltest.h
- test/shell/dmeventd-restart.sh


Changes:

=====================================
test/Makefile.in
=====================================
@@ -264,7 +264,7 @@ lib/should lib/invalid lib/fail: lib/not
 
 lib/runner: lib/runner.o .lib-dir-stamp
 	$(SHOW) "    [LD] $@"
-	$(Q) $(CXX) $(CXXFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
+	$(Q) $(CXX) $(CXXFLAGS) $(LDFLAGS) $(RT_LIBS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
 
 lib/securetest: lib/dmsecuretest.o .lib-dir-stamp
 	$(SHOW) "    [LD] $@"


=====================================
test/lib/brick-shelltest.h
=====================================
@@ -153,6 +153,16 @@ public:
     }
 };
 
+int get_fd(std::filebuf& filebuf)
+{
+    class my_filebuf : public std::filebuf {
+    public:
+        int handle() { return _M_file.fd(); }
+    };
+
+    return static_cast<my_filebuf&>(filebuf).handle();
+}
+
 struct dir {
     DIR *d;
     dir( const std::string &p ) {
@@ -298,6 +308,7 @@ struct Journal {
         }
         written = status;
         of.flush();
+        fsync( get_fd( *of.rdbuf() ) );
         of.close();
     }
 
@@ -306,7 +317,8 @@ struct Journal {
         for ( Status::const_iterator i = status.begin(); i != status.end(); ++i )
             of << i->first << " "  << i->second << std::endl;
         of.flush();
-        of.close();
+        fsync( get_fd( *of.rdbuf() ) );
+         of.close();
     }
 
     void sync() {
@@ -898,6 +910,7 @@ struct TestCase {
             std::ofstream hb( options.heartbeat.c_str(), std::fstream::app );
             hb << ".";
             hb.flush();
+            fsync( get_fd( *hb.rdbuf() ) );
             hb.close();
             last_heartbeat.gettime();
         }


=====================================
test/shell/dmeventd-restart.sh
=====================================
@@ -67,7 +67,11 @@ rm -f debug.log*
 dmeventd -R -f -e "$PWD/test_nologin" -ldddd > debug.log_DMEVENTD_$RANDOM 2>&1 &
 echo $! >LOCAL_DMEVENTD
 
-pgrep -o dmeventd
+for i in $(seq 1 10); do
+  test "$(pgrep -o dmeventd)" = "$(< LOCAL_DMEVENTD)" && break
+  sleep .1
+done
+
 kill -INT "$(< LOCAL_DMEVENTD)"
 sleep 1
 



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/a540b3f189a9aaaf87222190035db4161e336964...6f520916688f0fce9f6dfde4747e45f1bf54c9ad

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/a540b3f189a9aaaf87222190035db4161e336964...6f520916688f0fce9f6dfde4747e45f1bf54c9ad
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231003/902206d8/attachment-0001.htm>

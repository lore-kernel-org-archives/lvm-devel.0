From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Tue, 03 Oct 2023 11:00:44 +0000
Subject: [Git][lvmteam/lvm2][main] tests: old g++ needs explicit cast
Message-ID: <651bf45c876f0_2aa52a869022@gitlab-sidekiq-low-urgency-cpu-bound-v2-5b59ddf494-brpsk.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
0e8c631f by Zdenek Kabelac at 2023-10-03T12:59:38+02:00
tests: old g++ needs explicit cast

- - - - -


1 changed file:

- test/lib/brick-shelltest.h


Changes:

=====================================
test/lib/brick-shelltest.h
=====================================
@@ -103,8 +103,8 @@ class Timespec {
     struct timespec ts;
     static const long _NSEC_PER_SEC = 1000000000;
 public:
-    Timespec( time_t _sec = 0, long _nsec = 0 ) { ts = { _sec, _nsec }; }
-    Timespec( const struct timeval &tv ) { ts = { tv.tv_sec, tv.tv_usec * 1000 }; }
+    Timespec( time_t _sec = 0, long _nsec = 0 ) { ts = (struct timespec) { _sec, _nsec }; }
+    Timespec( const struct timeval &tv ) { ts = (struct timespec) { tv.tv_sec, tv.tv_usec * 1000 }; }
     long sec() const { return (long)ts.tv_sec; }
     long nsec() const { return (long)ts.tv_nsec; }
     void gettime() {
@@ -941,7 +941,7 @@ struct TestCase {
                 return false;
             }
 
-        struct timeval wait = { 0, 500000 /* timeout 0.5s */ };
+        struct timeval wait = (struct timeval) { 0, 500000 /* timeout 0.5s */ };
         fd_set set;
 
         FD_ZERO( &set );



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/0e8c631f5e58473d7f802ccaaf3fe61cf4dc403e

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/0e8c631f5e58473d7f802ccaaf3fe61cf4dc403e
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231003/868eead9/attachment.htm>

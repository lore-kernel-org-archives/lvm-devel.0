From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 12 Feb 2014 16:59:27 +0000 (UTC)
Subject: master - cache: Do not configure cache[pool] support by default
Message-ID: <20140212165927.B26176092B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8225b86158cb3ea8edc678327a2c33543a73c01
Commit:        e8225b86158cb3ea8edc678327a2c33543a73c01
Parent:        5bfe4aaf95434d4289c7f030a354564b9375ab3d
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 12 10:58:20 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 12 10:58:20 2014 -0600

cache: Do not configure cache[pool] support by default

Users wanting cache[_pool] segment type support need to include
"--with-cache=internal" when configure'ing.
---
 configure    |    4 ++--
 configure.in |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index f6463f0..ab4f534 100755
--- a/configure
+++ b/configure
@@ -1625,7 +1625,7 @@ Optional Packages:
   --with-thin-dump=PATH   thin_dump tool: [[autodetect]]
   --with-thin-repair=PATH thin_repair tool: [[autodetect]]
   --with-cache=TYPE       cache support: internal/shared/none
-                          [[TYPE=internal]]
+                          [[TYPE=none]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-default-pid-dir=PID_DIR
@@ -7543,7 +7543,7 @@ $as_echo_n "checking whether to include cache... " >&6; }
 if test "${with_cache+set}" = set; then :
   withval=$with_cache; CACHE=$withval
 else
-  CACHE=internal
+  CACHE=none
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE" >&5
diff --git a/configure.in b/configure.in
index 8fdc8b1..58c7bdc 100644
--- a/configure.in
+++ b/configure.in
@@ -482,8 +482,8 @@ AC_MSG_CHECKING(whether to include cache)
 AC_ARG_WITH(cache,
 	    AC_HELP_STRING([--with-cache=TYPE],
 			   [cache support: internal/shared/none
-			    [[TYPE=internal]]]),
-	    CACHE=$withval, CACHE=internal)
+			    [[TYPE=none]]]),
+	    CACHE=$withval, CACHE=none)
 AC_MSG_RESULT($CACHE)
 
 if [[ "x$CACHE" != xnone -a "x$CACHE" != xinternal -a "x$CACHE" != xshared ]];



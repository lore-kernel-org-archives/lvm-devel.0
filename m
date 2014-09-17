From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 17 Sep 2014 22:13:50 +0000 (UTC)
Subject: master - cache: Enable cache segment type by default.
Message-ID: <20140917221350.79FB360E36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8cbb04563ac240346693ec4da1587df20b049df7
Commit:        8cbb04563ac240346693ec4da1587df20b049df7
Parent:        ab2dacf6f6aa18328a848238e45aeaac2ed0d064
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 17 23:13:15 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 17 23:13:15 2014 +0100

cache: Enable cache segment type by default.

---
 WHATS_NEW    |    1 +
 configure    |    5 +++--
 configure.in |    4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 67c6482..bceed61 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Enable cache segment type by default.
   Ensure only supported volume types are used with cache segments.
   Fix inablility to specify cachemode when 'lvconvert'ing to cache-pool.
   Grab cluster lock for active LVs when setting clustered attribute.
diff --git a/configure b/configure
index be3d34d..6a15ed8 100755
--- a/configure
+++ b/configure
@@ -1668,7 +1668,8 @@ Optional Packages:
   --with-thin-repair=PATH thin_repair tool: [[autodetect]]
   --with-thin-restore=PATH
                           thin_restore tool: [[autodetect]]
-  --with-cache=TYPE       cache support: internal/shared/none [[TYPE=none]]
+  --with-cache=TYPE       cache support: internal/shared/none
+                          [[TYPE=internal]]
   --with-cache-check=PATH cache_check tool: [[autodetect]]
   --with-cache-dump=PATH  cache_dump tool: [[autodetect]]
   --with-cache-repair=PATH
@@ -7830,7 +7831,7 @@ $as_echo_n "checking whether to include cache... " >&6; }
 if test "${with_cache+set}" = set; then :
   withval=$with_cache; CACHE=$withval
 else
-  CACHE="none"
+  CACHE="internal"
 fi
 
 
diff --git a/configure.in b/configure.in
index 70f3b78..3956ff0 100644
--- a/configure.in
+++ b/configure.in
@@ -500,8 +500,8 @@ dnl -- cache inclusion type
 AC_MSG_CHECKING(whether to include cache)
 AC_ARG_WITH(cache,
 	    AC_HELP_STRING([--with-cache=TYPE],
-			   [cache support: internal/shared/none [[TYPE=none]]]),
-			   CACHE=$withval, CACHE="none")
+			   [cache support: internal/shared/none [[TYPE=internal]]]),
+			   CACHE=$withval, CACHE="internal")
 AC_ARG_WITH(cache-check,
 	    AC_HELP_STRING([--with-cache-check=PATH],
 			   [cache_check tool: [[autodetect]]]),



From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Tue, 13 Oct 2009 07:28:37 +0200
Subject: [PATCH 1/2] configure.in: don't set default file owner and group
In-Reply-To: <1255411718-12077-1-git-send-email-fdinitto@redhat.com>
References: <1255411718-12077-1-git-send-email-fdinitto@redhat.com>
Message-ID: <65a458b2db3a9e79318281c38f94672e4cc585dc.1255411547.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Per discussion on lvm-devel mailing list and part of debian patch set,
don't set defaults for owner and group, since nobody seems to use them, and
still allow override.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 5f06333... 6ff56b9... M	WHATS_NEW
:100755 100755 eedc60c... 8542492... M	configure
:100644 100644 fb99c9f... 116cf6b... M	configure.in
 WHATS_NEW    |    1 +
 configure    |    4 ++--
 configure.in |    4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5f06333..6ff56b9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Set default owner and group to null.
   Add dmeventd.static to the build.
   Disable realtime support code by default.
   Make clvmd return 0 on success rather than 1.
diff --git a/configure b/configure
index eedc60c..8542492 100755
--- a/configure
+++ b/configure
@@ -9078,7 +9078,7 @@ $as_echo "$STATIC_LINK" >&6; }
 ################################################################################
 { $as_echo "$as_me:$LINENO: checking file owner" >&5
 $as_echo_n "checking file owner... " >&6; }
-OWNER="root"
+OWNER=""
 
 
 # Check whether --with-user was given.
@@ -9096,7 +9096,7 @@ fi
 ################################################################################
 { $as_echo "$as_me:$LINENO: checking group owner" >&5
 $as_echo_n "checking group owner... " >&6; }
-GROUP="root"
+GROUP=""
 
 # Check whether --with-group was given.
 if test "${with_group+set}" = set; then
diff --git a/configure.in b/configure.in
index fb99c9f..116cf6b 100644
--- a/configure.in
+++ b/configure.in
@@ -144,7 +144,7 @@ AC_PREFIX_DEFAULT(/usr)
 ################################################################################
 dnl -- Setup the ownership of the files
 AC_MSG_CHECKING(file owner)
-OWNER="root"
+OWNER=""
 
 AC_ARG_WITH(user,
   [  --with-user=USER        Set the owner of installed files [[USER=root]] ],
@@ -158,7 +158,7 @@ fi
 ################################################################################
 dnl -- Setup the group ownership of the files
 AC_MSG_CHECKING(group owner)
-GROUP="root"
+GROUP=""
 AC_ARG_WITH(group,
   [  --with-group=GROUP      Set the group owner of installed files [[GROUP=root]] ],
   [ GROUP="$withval" ])
-- 
1.5.4.3



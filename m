From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 24 Feb 2016 19:23:11 +0000 (UTC)
Subject: master - configure: require sanlock 3.3.0
Message-ID: <20160224192311.4E48060FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=718a695b0c0fe0c9088758499e5daae2cb0652a2
Commit:        718a695b0c0fe0c9088758499e5daae2cb0652a2
Parent:        664fa6d1be10a807f8edc13801b1cd62248ae76f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 24 13:22:23 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 24 13:22:23 2016 -0600

configure: require sanlock 3.3.0

For a sanlock flag added in that version.
---
 configure.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index 7a5aa5d..e8723f4 100644
--- a/configure.in
+++ b/configure.in
@@ -1159,7 +1159,7 @@ BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
 
 dnl -- Look for sanlock libraries
 if test "$BUILD_LOCKDSANLOCK" = yes; then
-	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client, [HAVE_LOCKD_SANLOCK=yes], $bailout)
+	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client >= 3.3.0, [HAVE_LOCKD_SANLOCK=yes], $bailout)
 	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
 	BUILD_LVMLOCKD=yes
 fi



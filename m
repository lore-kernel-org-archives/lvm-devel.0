From: Ferenc Wágner <wferi@niif.hu>
Date: Fri, 26 Jun 2015 09:00:16 +0200
Subject: [PATCH] The == operator is Bash syntax, use = instead
Message-ID: <1435302016-7016-1-git-send-email-wferi@niif.hu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Commit e587b0677b705786a78f21bac1966621f70b2752 broke the build on
systems where /bin/sh is Dash, for example.
---
 libdaemon/Makefile.in |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libdaemon/Makefile.in b/libdaemon/Makefile.in
index c0379a4..7a637c4 100644
--- a/libdaemon/Makefile.in
+++ b/libdaemon/Makefile.in
@@ -19,7 +19,7 @@ top_builddir = @top_builddir@
 
 SUBDIRS += client
 
-ifeq (yes, $(shell test @BUILD_LVMETAD@ == yes -o @BUILD_LVMPOLLD@ == yes && echo yes))
+ifeq (yes, $(shell test @BUILD_LVMETAD@ = yes -o @BUILD_LVMPOLLD@ = yes && echo yes))
   SUBDIRS += server
 server: client
 endif
-- 
1.7.10.4



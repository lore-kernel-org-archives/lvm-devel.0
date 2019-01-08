From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 8 Jan 2019 07:16:41 -0500
Subject: master - mirror: regenerate config
Message-ID: <201901081216.x08CGfKF031881@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c0c202e60600b2d7460ce0e7825f2ec89956c68f
Commit:        c0c202e60600b2d7460ce0e7825f2ec89956c68f
Parent:        54a569be4068d7e08ad7d6d2f6e0ee64dad0797e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 8 13:05:06 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 8 13:13:57 2019 +0100

mirror: regenerate config

Drop extra line in source file - since this line is auto-generated
and would appear twice in resuling .in file with 'make generate'.
---
 conf/example.conf.in         |    5 ++---
 lib/config/config_settings.h |    1 -
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 39584b3..dfe8006 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -911,13 +911,12 @@ global {
 
 	# Configuration option global/support_mirrored_mirror_log.
 	# Enable mirrored 'mirror' log type for testing.
-	#
+	# 
 	# This type is deprecated to create or convert to but can
 	# be enabled to test that activation of existing mirrored
 	# logs and conversion to disk/core works.
-	#
+	# 
 	# Not supported for regular operation!
-	#
 	support_mirrored_mirror_log = 0
 
 	# Configuration option global/raid10_segtype_default.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 248d204..f1d2826 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -969,7 +969,6 @@ cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECT
 	"#\n")
 
 cfg(global_support_mirrored_mirror_log_CFG, "support_mirrored_mirror_log", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 3, 2), NULL, 0, NULL,
-	"Configuration option global/support_mirrored_mirror_log.\n"
 	"Enable mirrored 'mirror' log type for testing.\n"
 	"#\n"
 	"This type is deprecated to create or convert to but can\n"



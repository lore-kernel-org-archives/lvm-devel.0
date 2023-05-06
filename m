From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:13 +0000 (GMT)
Subject: main - vdo: document feature option
Message-ID: <20230506204613.285F23858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=534269d0fb834fb9a3b115bf859319fc1acb2275
Commit:        534269d0fb834fb9a3b115bf859319fc1acb2275
Parent:        58293173cf4d05d3bffa905875442567e5ca4780
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 27 23:17:40 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 20:38:57 2023 +0200

vdo: document feature option

---
 conf/example.conf.in         | 4 ++--
 lib/config/config_settings.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 923d238e4..0b9b06a17 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1313,10 +1313,10 @@ global {
 	# Configuration option global/vdo_disabled_features.
 	# Features to not use in the vdo driver.
 	# This can be helpful for testing, or to avoid using a feature that is
-	# causing problems. Features include: online_rename
+	# causing problems. Features include: online_rename, version4
 	#
 	# Example
-	# vdo_disabled_features = [ "online_rename" ]
+	# vdo_disabled_features = [ "online_rename", "version4" ]
 	#
 	# This configuration option does not have a default value defined.
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 9d19a554e..2d6d957af 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1263,10 +1263,10 @@ cfg_array(global_vdo_format_options_CFG, "vdo_format_options", global_CFG_SECTIO
 cfg_array(global_vdo_disabled_features_CFG, "vdo_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 3, 11), NULL, 0, NULL,
 	"Features to not use in the vdo driver.\n"
 	"This can be helpful for testing, or to avoid using a feature that is\n"
-	"causing problems. Features include: online_rename\n"
+	"causing problems. Features include: online_rename, version4\n"
 	"#\n"
 	"Example\n"
-	"vdo_disabled_features = [ \"online_rename\" ]\n"
+	"vdo_disabled_features = [ \"online_rename\", \"version4\" ]\n"
 	"#\n")
 
 cfg(global_fsadm_executable_CFG, "fsadm_executable", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_FSADM_PATH, vsn(2, 2, 170), "@FSADM_PATH@", 0, NULL,


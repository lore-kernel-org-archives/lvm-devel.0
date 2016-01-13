From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 14:47:44 +0000 (UTC)
Subject: master - conf: fix 'the volume list' vs 'volume list' and '@*'
Message-ID: <20160113144744.CF394602F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=939d29652579e4759d445c87dc21d1a6b37fd97d
Commit:        939d29652579e4759d445c87dc21d1a6b37fd97d
Parent:        9a81881965f1c990632c13699f2184cd1680cf39
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 15:47:26 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 15:47:26 2016 +0100

conf: fix 'the volume list' vs 'volume list' and '@*'

---
 conf/example.conf.in         |   12 ++++++------
 lib/config/config_settings.h |   12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index e567a73..4dbe289 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1108,8 +1108,8 @@ activation {
 	#     or VG.
 	#   @*
 	#     Selects an LV if a tag defined on the host is also set on the LV
-	#     or VG. See tags/hosttags. If any host tags exist but the volume
-	#     list is not defined, a default single-entry list containing '@*'
+	#     or VG. See tags/hosttags. If any host tags exist but volume_list
+	#     is not defined, a default single-entry list containing '@*'
 	#     is assumed.
 	# 
 	# Example
@@ -1145,8 +1145,8 @@ activation {
 	#     or VG.
 	#   @*
 	#     Selects an LV if a tag defined on the host is also set on the LV
-	#     or VG. See tags/hosttags. If any host tags exist but the volume
-	#     list is not defined, a default single-entry list containing '@*'
+	#     or VG. See tags/hosttags. If any host tags exist but volume_list
+	#     is not defined, a default single-entry list containing '@*'
 	#     is assumed.
 	# 
 	# Example
@@ -1171,8 +1171,8 @@ activation {
 	#     or VG.
 	#   @*
 	#     Selects an LV if a tag defined on the host is also set on the LV
-	#     or VG. See tags/hosttags. If any host tags exist but the volume
-	#     list is not defined, a default single-entry list containing '@*'
+	#     or VG. See tags/hosttags. If any host tags exist but volume_list
+	#     is not defined, a default single-entry list containing '@*'
 	#     is assumed.
 	# 
 	# Example
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 60b5110..dcebe99 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1066,8 +1066,8 @@ cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG
 	"    or VG.\n"
 	"  @*\n"
 	"    Selects an LV if a tag defined on the host is also set on the LV\n"
-	"    or VG. See tags/hosttags. If any host tags exist but the volume\n"
-	"    list is not defined, a default single-entry list containing '@*'\n"
+	"    or VG. See tags/hosttags. If any host tags exist but volume_list\n"
+	"    is not defined, a default single-entry list containing '@*'\n"
 	"    is assumed.\n"
 	"#\n"
 	"Example\n"
@@ -1102,8 +1102,8 @@ cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_li
 	"    or VG.\n"
 	"  @*\n"
 	"    Selects an LV if a tag defined on the host is also set on the LV\n"
-	"    or VG. See tags/hosttags. If any host tags exist but the volume\n"
-	"    list is not defined, a default single-entry list containing '@*'\n"
+	"    or VG. See tags/hosttags. If any host tags exist but volume_list\n"
+	"    is not defined, a default single-entry list containing '@*'\n"
 	"    is assumed.\n"
 	"#\n"
 	"Example\n"
@@ -1127,8 +1127,8 @@ cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activat
 	"    or VG.\n"
 	"  @*\n"
 	"    Selects an LV if a tag defined on the host is also set on the LV\n"
-	"    or VG. See tags/hosttags. If any host tags exist but the volume\n"
-	"    list is not defined, a default single-entry list containing '@*'\n"
+	"    or VG. See tags/hosttags. If any host tags exist but volume_list\n"
+	"    is not defined, a default single-entry list containing '@*'\n"
 	"    is assumed.\n"
 	"#\n"
 	"Example\n"



From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  3 Nov 2015 17:08:55 +0000 (UTC)
Subject: master - config: fix copy error in examples
Message-ID: <20151103170855.F342561124@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b47ee529639c7dd5ced56d7729747fe26b458e7
Commit:        4b47ee529639c7dd5ced56d7729747fe26b458e7
Parent:        cf06d942b8aad5643fe0a20be49279d06f3bee62
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 3 11:07:27 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 3 11:07:27 2015 -0600

config: fix copy error in examples

The same example was copied without
changing the variable name.
---
 lib/config/config_settings.h |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index dd2b407..52954d5 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1066,9 +1066,9 @@ cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG
 	"    or VG.\n"
 	"  @*\n"
 	"    Selects an LV if a tag defined on the host is also set on the LV\n"
-	"    or VG. See tags/hosttags. If any host tags exist but volume_list\n"
-	"    is not defined, a default single-entry list containing '@*' is\n"
-	"    assumed.\n"
+	"    or VG. See tags/hosttags. If any host tags exist but the volume\n"
+	"    list is not defined, a default single-entry list containing '@*'\n"
+	"    is assumed.\n"
 	"#\n"
 	"Example\n"
 	"volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n"
@@ -1102,12 +1102,12 @@ cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_li
 	"    or VG.\n"
 	"  @*\n"
 	"    Selects an LV if a tag defined on the host is also set on the LV\n"
-	"    or VG. See tags/hosttags. If any host tags exist but volume_list\n"
-	"    is not defined, a default single-entry list containing '@*' is\n"
-	"    assumed.\n"
+	"    or VG. See tags/hosttags. If any host tags exist but the volume\n"
+	"    list is not defined, a default single-entry list containing '@*'\n"
+	"    is assumed.\n"
 	"#\n"
 	"Example\n"
-	"volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n"
+	"auto_activation_volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n"
 	"#\n")
 
 cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL, 0, NULL,
@@ -1127,12 +1127,12 @@ cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activat
 	"    or VG.\n"
 	"  @*\n"
 	"    Selects an LV if a tag defined on the host is also set on the LV\n"
-	"    or VG. See tags/hosttags. If any host tags exist but volume_list\n"
-	"    is not defined, a default single-entry list containing '@*' is\n"
-	"    assumed.\n"
+	"    or VG. See tags/hosttags. If any host tags exist but the volume\n"
+	"    list is not defined, a default single-entry list containing '@*'\n"
+	"    is assumed.\n"
 	"#\n"
 	"Example\n"
-	"volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n"
+	"read_only_volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n"
 	"#\n")
 
 cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL, vsn(2, 2, 99),



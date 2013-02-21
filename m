From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 21 Feb 2013 13:33:43 +0000 (UTC)
Subject: master - RAID: Add new 'raid10_segtype_default' setting in lvm.conf
Message-ID: <20130221133343.B369FA1045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70f57996b3b9ba126a9cbf69afed79a7d66c793c
Commit:        70f57996b3b9ba126a9cbf69afed79a7d66c793c
Parent:        dc2ce71313cef15efa2ba0addfb0f4115af80ca6
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 20 15:10:04 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 20 15:10:04 2013 -0600

RAID:  Add new 'raid10_segtype_default' setting in lvm.conf

If '--mirrors/-m' and '--stripes/-i' are used together when creating
a logical volume, mirrors-over-stripes is currently chosen.  The user
can override this by using the '--type raid10' option on creation.
However, we want a place where we can set the default behavior to
'raid10' explicitly - similar to the "mirror" and "raid1" tunable,
mirror_segtype_default.

A follow-on patch should use this new setting to change the default
from "mirror" to "raid10", as this is the preferred segment type.
---
 doc/example.conf.in   |   17 +++++++++++++++++
 lib/config/defaults.h |    1 +
 tools/lvcreate.c      |   11 ++++++-----
 3 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index a1ba5f8..e6494e5 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -498,6 +498,23 @@ global {
     # setting.
     mirror_segtype_default = "mirror"
 
+    # 'raid10_segtype_default' determines the segment types used by default
+    # when the '--stripes/-i' and '--mirrors/-m' arguments are both specified
+    # during the creation of a logical volume.
+    # Possible settings include:
+    #
+    # "raid10" - This implementation leverages MD's RAID10 personality through
+    #            device-mapper.
+    #
+    # "mirror" - LVM will layer the 'mirror' and 'stripe' segment types.  It
+    #            will do this by creating a mirror on top of striped sub-LVs;
+    #            effectively creating a RAID 0+1 array.  This is suboptimal
+    #            in terms of providing redunancy and performance.  Changing to
+    #            this setting is not advised.
+    # Specify the '--type <raid10|mirror>' option to override this default
+    # setting.
+    raid10_segtype_default "mirror"
+
     # The default format for displaying LV names in lvdisplay was changed 
     # in version 2.02.89 to show the LV name and path separately.
     # Previously this was always shown as /dev/vgname/lvname even when that
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 0a98254..d39995e 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -56,6 +56,7 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
+#define DEFAULT_RAID10_SEGTYPE "mirror"
 #define DEFAULT_RAID_FAULT_POLICY "warn"
 #define DEFAULT_DMEVENTD_RAID_LIB "libdevmapper-event-lvm2raid.so"
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8919ba4..a2626c0 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -673,11 +673,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 
 	/* Set default segtype */
 	if (arg_count(cmd, mirrors_ARG))
-		/*
-		 * FIXME: Add default setting for when -i and -m arguments
-		 *        are both given.  We should default to "raid10".
-		 */
-		segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+		if (arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ?
+				   stripes_long_ARG : stripes_ARG, 1) > 1) {
+			segtype_str = find_config_tree_str(cmd, "global/raid10_segtype_default", DEFAULT_RAID10_SEGTYPE);
+		} else {
+			segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+		}
 	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG))
 		segtype_str = "thin";
 	else



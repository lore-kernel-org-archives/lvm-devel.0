From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  6 Aug 2013 19:18:39 +0000 (UTC)
Subject: master - RAID: Make "raid10" the default striped + mirror segment type
Message-ID: <20130806191839.B780760082@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c13d1b11b2eb30c215a4233d6f641d0d1c62114b
Commit:        c13d1b11b2eb30c215a4233d6f641d0d1c62114b
Parent:        7e1083c985fd130b240c2471643350cc5c0f05cf
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Aug 6 14:15:08 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Aug 6 14:15:08 2013 -0500

RAID: Make "raid10" the default striped + mirror segment type

When both the '-i' and '-m' arguments are specified on the command
line, use the "raid10" segment type.  This way, the native RAID10
personality is used through dm-raid rather than layering a mirror
on striped LVs.  If the old behavior is desired, the '--type'
argument to use would be "mirror" rather than "raid10".
---
 conf/example.conf.in  |    2 +-
 lib/config/defaults.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index c3ba2b9..78c69e5 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -529,7 +529,7 @@ global {
     #            this setting is not advised.
     # Specify the '--type <raid10|mirror>' option to override this default
     # setting.
-    raid10_segtype_default = "mirror"
+    raid10_segtype_default = "raid10"
 
     # The default format for displaying LV names in lvdisplay was changed 
     # in version 2.02.89 to show the LV name and path separately.
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 59282c5..5a456cf 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -56,7 +56,7 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
-#define DEFAULT_RAID10_SEGTYPE "mirror"
+#define DEFAULT_RAID10_SEGTYPE "raid10"
 #define DEFAULT_RAID_FAULT_POLICY "warn"
 #define DEFAULT_DMEVENTD_RAID_LIB "libdevmapper-event-lvm2raid.so"
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"



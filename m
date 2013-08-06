From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  6 Aug 2013 19:14:51 +0000 (UTC)
Subject: master - RAID: Make "raid1" the default mirror segment type
Message-ID: <20130806191451.F216960F6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e1083c985fd130b240c2471643350cc5c0f05cf
Commit:        7e1083c985fd130b240c2471643350cc5c0f05cf
Parent:        f74e8fe04471a44fe1ab0645e48c9cb06ef6fb4f
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Aug 6 14:13:55 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Aug 6 14:13:55 2013 -0500

RAID: Make "raid1" the default mirror segment type

---
 WHATS_NEW             |    1 +
 conf/example.conf.in  |    2 +-
 lib/config/defaults.h |    2 +-
 man/lvconvert.8.in    |    7 ++++++-
 man/lvcreate.8.in     |   17 ++++++++++++-----
 5 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fd7e39f..3590e64 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Make "raid1" the default mirror segment type.
   Fix clogd descriptor leak when daemonizing.
   Fix clvmd descriptor leak on restart.
   Add pipe_open/close() to replace less secure popen() glibc call.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 0e313c8..c3ba2b9 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -512,7 +512,7 @@ global {
     #
     # Specify the '--type <mirror|raid1>' option to override this default
     # setting.
-    mirror_segtype_default = "mirror"
+    mirror_segtype_default = "raid1"
 
     # 'raid10_segtype_default' determines the segment types used by default
     # when the '--stripes/-i' and '--mirrors/-m' arguments are both specified
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 5af0f00..59282c5 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -51,7 +51,7 @@
 #define DEFAULT_METADATA_READ_ONLY 0
 #define DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH 0
 
-#define DEFAULT_MIRROR_SEGTYPE "mirror"
+#define DEFAULT_MIRROR_SEGTYPE "raid1"
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index d4faf27..0fe5ab3 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -141,7 +141,12 @@ Run the daemon in the background.
 Specifies the degree of the mirror you wish to create.
 For example, "\fB-m 1\fP" would convert the original logical
 volume to a mirror volume with 2-sides; that is, a
-linear volume plus one copy.
+linear volume plus one copy.  There are two implementations of mirroring
+which correspond to the "raid1" and "mirror" segment types.  The default
+mirroring segment type is "raid1".  If the legacy "mirror" segment type
+is desired, the \fB\-\-type\fP argument must be used to explicitly
+select the desired type.  The \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP
+options below are only relevant to the legacy "mirror" segment type.
 .TP
 .IR \fB\-\-mirrorlog " {" disk | core | mirrored }
 Specifies the type of log to use.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 681ff68..4a29720 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -232,16 +232,23 @@ afterwards will be mirrored, but the original contents will not be
 copied.  This is useful for skipping a potentially long and resource
 intensive initial sync of an empty device.
 
-The optional argument \fB\-\-mirrorlog\fP specifies the type of log to be used.
+There are two implementations of mirroring which can be used and correspond
+to the "raid1" and "mirror" segment types.  The default is "raid1".  See the
+\fB\-\-type\fP option for more information if you would like to use the
+legacy "mirror" segment type.  The \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP
+options apply to the "mirror" segment type only.
+
+The optional argument \fB\-\-mirrorlog\fP specifies the type of log to be
+used for logical volumes utilizing the legacy "mirror" segment type.
 The default is \fIdisk\fP, which is persistent and requires
 a small amount of storage space, usually on a separate device from the
 data being mirrored.  Using \fIcore\fP means the mirror is regenerated
-by copying the data from the first device again each time the
-device is activated, for example, after every reboot.  Using \fImirrored\fP
+by copying the data from the first device each time the logical
+volume is activated, like after every reboot.  Using \fImirrored\fP
 will create a persistent log that is itself mirrored.
 
-The optional argument \fB\-\-corelog\fP is equivalent
-to \fB\-\-mirrorlog\fP \fIcore\fP.
+When the legacy "mirror" segment type is used, the optional argument
+\fB\-\-corelog\fP is equivalent to \fB\-\-mirrorlog\fP \fIcore\fP.
 .TP
 .IR \fB\-M ", " \fB\-\-persistent " {" y | n }
 Set to \fIy\fP to make the minor number specified persistent.



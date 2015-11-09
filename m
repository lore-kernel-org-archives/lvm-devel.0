From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:29:04 +0000 (UTC)
Subject: master - cleanup: keep using enum typedef
Message-ID: <20151109092904.4CE1060F71@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e262d5e596202498c5b0d773cd54c1b2ecdb4f94
Commit:        e262d5e596202498c5b0d773cd54c1b2ecdb4f94
Parent:        9b9b5d0ea23baf043d0a936662f0741d769cee04
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 7 17:17:37 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:52 2015 +0100

cleanup: keep using enum typedef

Using enum instead of unsigned.
---
 lib/device/device.h    |    2 +-
 lib/misc/lvm-globals.c |    6 +++---
 lib/misc/lvm-globals.h |    6 ++++--
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/device/device.h b/lib/device/device.h
index 733b0d0..b5e07d5 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -33,7 +33,7 @@
  * Any new external device info source needs to be
  * registered using EXT_REGISTER macro in dev-ext.c.
  */
-typedef enum {
+typedef enum dev_ext_e {
 	DEV_EXT_NONE,
 	DEV_EXT_UDEV,
 	DEV_EXT_NUM
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 06c36e2..01f10a7 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -30,7 +30,7 @@ static int _fwraid_filtering = 0;
 static int _pvmove = 0;
 static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
 static int _obtain_device_list_from_udev = DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV;
-static unsigned _external_device_info_source = DEV_EXT_NONE;
+static enum dev_ext_e _external_device_info_source = DEV_EXT_NONE;
 static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
 static int _debug_classes_logged = 0;
@@ -98,7 +98,7 @@ void init_obtain_device_list_from_udev(int device_list_from_udev)
 	_obtain_device_list_from_udev = device_list_from_udev;
 }
 
-void init_external_device_info_source(unsigned src)
+void init_external_device_info_source(enum dev_ext_e src)
 {
 	_external_device_info_source = src;
 }
@@ -261,7 +261,7 @@ int obtain_device_list_from_udev(void)
 	return _obtain_device_list_from_udev;
 }
 
-unsigned external_device_info_source(void)
+enum dev_ext_e external_device_info_source(void)
 {
 	return _external_device_info_source;
 }
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 132af96..185a45f 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -20,6 +20,8 @@
 #define SECURITY_LEVEL 0
 #define PV_MIN_SIZE_KB 512
 
+enum dev_ext_e;
+
 void init_verbose(int level);
 void init_silent(int silent);
 void init_test(int level);
@@ -27,7 +29,7 @@ void init_md_filtering(int level);
 void init_fwraid_filtering(int level);
 void init_pvmove(int level);
 void init_full_scan_done(int level);
-void init_external_device_info_source(unsigned src);
+void init_external_device_info_source(enum dev_ext_e src);
 void init_obtain_device_list_from_udev(int device_list_from_udev);
 void init_trust_cache(int trustcache);
 void init_debug(int level);
@@ -61,7 +63,7 @@ int fwraid_filtering(void);
 int pvmove_mode(void);
 int full_scan_done(void);
 int obtain_device_list_from_udev(void);
-unsigned external_device_info_source(void);
+enum dev_ext_e external_device_info_source(void);
 int trust_cache(void);
 int verbose_level(void);
 int silent_mode(void);



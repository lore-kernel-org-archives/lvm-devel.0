From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 16 Jun 2015 20:14:19 +0000 (UTC)
Subject: master - Add a global get_cmd_name()
Message-ID: <20150616201419.D1D2D610EA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da1f88706060baf03bceb9e4d788c65646b831b7
Commit:        da1f88706060baf03bceb9e4d788c65646b831b7
Parent:        e043e03cd853f9dbeb653ecdd63957d39c7136cc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 16 15:13:10 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 15:13:10 2015 -0500

Add a global get_cmd_name()

Which returns the string set by set_cmd_name().
---
 lib/misc/lvm-globals.c |    5 +++++
 lib/misc/lvm-globals.h |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 6455788..4fa0779 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -193,6 +193,11 @@ void set_cmd_name(const char *cmd)
 	_cmd_name[sizeof(_cmd_name) - 1] = '\0';
 }
 
+const char *get_cmd_name(void)
+{
+	return _cmd_name;
+}
+
 void set_sysfs_dir_path(const char *path)
 {
 	strncpy(_sysfs_dir_path, path, sizeof(_sysfs_dir_path) - 1);
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index b25f4ae..8628a89 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -51,6 +51,7 @@ void init_detect_internal_vg_cache_corruption(int detect);
 void init_retry_deactivation(int retry);
 
 void set_cmd_name(const char *cmd_name);
+const char *get_cmd_name(void);
 void set_sysfs_dir_path(const char *path);
 
 int test_mode(void);



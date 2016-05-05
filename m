From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:22 +0000 (UTC)
Subject: master - cleanup: gather version info with single check
Message-ID: <20160505220122.EEA9D60C56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d116d7a28974648183623c46014b9dcff48748d
Commit:        4d116d7a28974648183623c46014b9dcff48748d
Parent:        def65507e6beab7d1830622492772cc89abe4ccb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 27 11:11:58 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:34:30 2016 +0200

cleanup: gather version info with single check

As we already collect version info anyway, allow to use it through
a single call (can makes logs shorter and saves ioctl).
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   21 ++++++++++++++-------
 lib/activate/activate.h |    3 +++
 3 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7291482..d0943f5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.153 - 
 ==================================
+  Add function to check for target presence and version via 1 ioctl.
 
 Version 2.02.152 - 30th April 2016
 ==================================
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 5a7e99e..712f86c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -632,25 +632,32 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 	return ret;
 }
 
-int target_present(struct cmd_context *cmd, const char *target_name,
-		   int use_modprobe)
+int target_present_version(struct cmd_context *cmd, const char *target_name,
+			   int use_modprobe,
+			   uint32_t *maj, uint32_t *min, uint32_t *patchlevel)
 {
-	uint32_t maj, min, patchlevel;
-
 	if (!activation())
-		return 0;
+		return_0;
 
 #ifdef MODPROBE_CMD
 	if (use_modprobe) {
-		if (target_version(target_name, &maj, &min, &patchlevel))
+		if (target_version(target_name, maj, min, patchlevel))
 			return 1;
 
 		if (!module_present(cmd, target_name))
 			return_0;
 	}
 #endif
+	return target_version(target_name, maj, min, patchlevel);
+}
+
+int target_present(struct cmd_context *cmd, const char *target_name,
+		   int use_modprobe)
+{
+	uint32_t maj, min, patchlevel;
 
-	return target_version(target_name, &maj, &min, &patchlevel);
+	return target_present_version(cmd, target_name, use_modprobe,
+				      &maj, &min, &patchlevel);
 }
 
 static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 089355d..1e8d7a8 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -92,6 +92,9 @@ int library_version(char *version, size_t size);
 int lvm1_present(struct cmd_context *cmd);
 
 int module_present(struct cmd_context *cmd, const char *target_name);
+int target_present_version(struct cmd_context *cmd, const char *target_name,
+			   int use_modprobe, uint32_t *maj,
+			   uint32_t *min, uint32_t *patchlevel);
 int target_present(struct cmd_context *cmd, const char *target_name,
 		   int use_modprobe);
 int target_version(const char *target_name, uint32_t *maj,



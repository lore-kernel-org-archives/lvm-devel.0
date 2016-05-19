From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 May 2016 16:41:31 +0000 (UTC)
Subject: master - libdm: trace missing settings
Message-ID: <20160519164131.EBCDE602F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8fd886f735125de4b3e32fc0a188af0192a0d173
Commit:        8fd886f735125de4b3e32fc0a188af0192a0d173
Parent:        e8ba5c9bd4f8a1ff5d67b597c10eea3d176b27e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 18 15:23:08 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 19 18:27:34 2016 +0200

libdm: trace missing settings

These settings have been missed in very verbose log.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-config.c |   15 ++++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d446997..165cb90 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -12,6 +12,7 @@ Version 1.02.124 - 30th April 2016
 
 Version 1.02.123 - 23rd April 2016
 ==================================
+  Trace more settings in very verbose mode for libdm-config.
   Do not strip LVM- when debug reporting not found uuid.
 
 Version 1.02.122 - 9th April 2016
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index dcb7c3f..86955c5 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -1154,8 +1154,11 @@ int dm_config_get_uint32(const struct dm_config_node *cn, const char *path,
 	if (!n || !n->v || n->v->type != DM_CFG_INT)
 		return 0;
 
-	if (result)
+	if (result) {
+		log_very_verbose("Setting %s to %u", path, (uint32_t) n->v->v.i);
 		*result = n->v->v.i;
+	}
+
 	return 1;
 }
 
@@ -1169,8 +1172,11 @@ int dm_config_get_uint64(const struct dm_config_node *cn, const char *path,
 	if (!n || !n->v || n->v->type != DM_CFG_INT)
 		return 0;
 
-	if (result)
+	if (result) {
+		log_very_verbose("Setting %s to " FMTu64 , path, (uint64_t) n->v->v.i);
 		*result = (uint64_t) n->v->v.i;
+	}
+
 	return 1;
 }
 
@@ -1184,8 +1190,11 @@ int dm_config_get_str(const struct dm_config_node *cn, const char *path,
 	if (!n || !n->v || n->v->type != DM_CFG_STRING)
 		return 0;
 
-	if (result)
+	if (result) {
+		log_very_verbose("Setting %s to %s", path, n->v->v.str);
 		*result = n->v->v.str;
+	}
+
 	return 1;
 }
 



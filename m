From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 27 May 2016 13:46:05 +0000 (UTC)
Subject: master - Revert "libdm: trace missing settings"
Message-ID: <20160527134605.40A1D6030A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=780424639afe3e9a91e85bf3f88142606833f310
Commit:        780424639afe3e9a91e85bf3f88142606833f310
Parent:        b762c37555dec3c2e99df05a721787d2223807b6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri May 27 14:35:11 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri May 27 14:35:11 2016 +0100

Revert "libdm: trace missing settings"

This reverts commit 8fd886f735125de4b3e32fc0a188af0192a0d173.

This was a deliberate omission because logging token-by-token metadata
parsing greatly increases the amount of logging for hardly any benefit.

In general, only LVM config file settings need to be logged, and in
places where it's considered important to log particular elements of
metadata that should be done using specific log_* lines.

This area can be revisited.
---
 WHATS_NEW_DM         |    1 -
 libdm/libdm-config.c |   15 +++------------
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 165cb90..d446997 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -12,7 +12,6 @@ Version 1.02.124 - 30th April 2016
 
 Version 1.02.123 - 23rd April 2016
 ==================================
-  Trace more settings in very verbose mode for libdm-config.
   Do not strip LVM- when debug reporting not found uuid.
 
 Version 1.02.122 - 9th April 2016
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 86955c5..dcb7c3f 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -1154,11 +1154,8 @@ int dm_config_get_uint32(const struct dm_config_node *cn, const char *path,
 	if (!n || !n->v || n->v->type != DM_CFG_INT)
 		return 0;
 
-	if (result) {
-		log_very_verbose("Setting %s to %u", path, (uint32_t) n->v->v.i);
+	if (result)
 		*result = n->v->v.i;
-	}
-
 	return 1;
 }
 
@@ -1172,11 +1169,8 @@ int dm_config_get_uint64(const struct dm_config_node *cn, const char *path,
 	if (!n || !n->v || n->v->type != DM_CFG_INT)
 		return 0;
 
-	if (result) {
-		log_very_verbose("Setting %s to " FMTu64 , path, (uint64_t) n->v->v.i);
+	if (result)
 		*result = (uint64_t) n->v->v.i;
-	}
-
 	return 1;
 }
 
@@ -1190,11 +1184,8 @@ int dm_config_get_str(const struct dm_config_node *cn, const char *path,
 	if (!n || !n->v || n->v->type != DM_CFG_STRING)
 		return 0;
 
-	if (result) {
-		log_very_verbose("Setting %s to %s", path, n->v->v.str);
+	if (result)
 		*result = n->v->v.str;
-	}
-
 	return 1;
 }
 



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Apr 2013 10:32:46 +0000 (UTC)
Subject: master - config: merge timestamps
Message-ID: <20130423103246.18A081C6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45eeb70b02df0f196ccd851c23c42fc29d6efb39
Commit:        45eeb70b02df0f196ccd851c23c42fc29d6efb39
Parent:        2925023411ff9c7a32fa7660617c94a9d9dcd653
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 23 12:24:17 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 23 12:31:16 2013 +0200

config: merge timestamps

Merging multiple config files together needs to know newest (highest)
timestamp of merged files. Persistent cache file is being used
only in case, the config file is older then .cache file.
---
 WHATS_NEW           |    1 +
 lib/config/config.c |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c1324de..4139557 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Find newest timestamp of merged config files.
   Fix assignment order for vg fid for lvm1 and pool format.
   Fix memleak in dmeventd thin plugin in device list obtaining err path.
   Add explicit message about unsupported pvmove for thin/thinpool volumes.
diff --git a/lib/config/config.c b/lib/config/config.c
index e999fc6..0af57d5 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -768,6 +768,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 	struct dm_config_node *root = cft->root;
 	struct dm_config_node *cn, *nextn, *oldn, *cn2;
 	const struct dm_config_node *tn;
+	struct config_file *cf, *cfn;
 
 	for (cn = newdata->root; cn; cn = nextn) {
 		nextn = cn->sib;
@@ -797,6 +798,16 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 		_merge_section(oldn, cn);
 	}
 
+	/*
+	 * Persistent filter loading is based on timestamp,
+	 * so we need to know the newest timestamp to make right decision
+	 * whether the .cache isn't older then any of configs
+	 */
+	if ((cf = dm_config_get_custom(cft)) &&
+	    (cfn = dm_config_get_custom(newdata)) &&
+	    cf->timestamp < cfn->timestamp)
+		cf->timestamp = cfn->timestamp;
+
 	return 1;
 }
 



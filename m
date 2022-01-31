From: David Teigland <teigland@sourceware.org>
Date: Mon, 31 Jan 2022 23:02:54 +0000 (GMT)
Subject: main - writecache: look for settings in lvm.conf
Message-ID: <20220131230254.B7A583858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f0cd54a873880286e0932c5cb38a9572677bee25
Commit:        f0cd54a873880286e0932c5cb38a9572677bee25
Parent:        ffa07c8e398232150794767e05b95893c7b737b6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 31 16:12:24 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 31 16:59:37 2022 -0600

writecache: look for settings in lvm.conf

Restore the lvm.conf cache_settings for writecache
added by c6639056e0bb2fc5f072b2c0d6bb629ad17eee6e.
Shorter method reduces and isolates the complexity
of config trees.
---
 WHATS_NEW       |  1 +
 tools/toollib.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index e2f6e166b..16235514e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.15 - 
 ===================================
+  Improve support for metadata profiles for --type writecache.
   Use cache or active DM device when available with new kernels.
   Introduce function to utilize UUIDs from DM_DEVICE_LIST.
   Increase some hash table size to better support large device sets.
diff --git a/tools/toollib.c b/tools/toollib.c
index c23f55c07..b08c044fa 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1317,12 +1317,15 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 int get_writecache_settings(struct cmd_context *cmd, struct writecache_settings *settings,
 			    uint32_t *block_size_sectors)
 {
+	const struct dm_config_node *cns, *cn1, *cn2;
 	struct arg_value_group_list *group;
 	const char *str;
 	char key[64];
 	char val[64];
 	int num;
 	int pos;
+	int rn;
+	int found = 0;
 
 	/*
 	 * "grouped" means that multiple --cachesettings options can be used.
@@ -1354,8 +1357,51 @@ int get_writecache_settings(struct cmd_context *cmd, struct writecache_settings
 			if (!_get_one_writecache_setting(cmd, settings, key, val, block_size_sectors))
 				return_0;
 		}
+		found = 1;
 	}
 
+	if (found)
+		goto out;
+
+	/*
+	 * If there were no settings on the command line, look for settings in
+	 * lvm.conf
+	 *
+	 * TODO: support profiles
+	 */
+
+	if (!(cns = find_config_tree_node(cmd, allocation_cache_settings_CFG_SECTION, NULL)))
+		goto out;
+
+	for (cn1 = cns->child; cn1; cn1 = cn1->sib) {
+		if (!cn1->child)
+			continue; /* Ignore section without settings */
+
+		if (cn1->v || strcmp(cn1->key, "writecache") != 0)
+			continue; /* Ignore non-matching settings */
+
+		cn2 = cn1->child;
+
+		for (; cn2; cn2 = cn2->sib) {
+			memset(val, 0, sizeof(val));
+
+			if (cn2->v->type == DM_CFG_INT)
+				rn = dm_snprintf(val, sizeof(val), FMTd64, cn2->v->v.i);
+			else if (cn2->v->type == DM_CFG_STRING)
+				rn = dm_snprintf(val, sizeof(val), "%s", cn2->v->v.str);
+			else
+				rn = -1;
+			if (rn < 0) {
+				log_error("Invalid lvm.conf writecache setting value for %s.", cn2->key);
+				return 0;
+			}
+
+			if (!_get_one_writecache_setting(cmd, settings, (char *)cn2->key, val, block_size_sectors))
+				return_0;
+		}
+	}
+
+ out:
 	if (settings->high_watermark_set && settings->low_watermark_set &&
 	    (settings->high_watermark <= settings->low_watermark)) {
 		log_error("High watermark must be greater than low watermark.");



From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 20 Jul 2016 15:46:38 +0000 (UTC)
Subject: master - lvconvert: allow implied cache pool convert
Message-ID: <20160720154638.1627A602C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b203d5e745ae779c5686868f1b4c461916ef73b9
Commit:        b203d5e745ae779c5686868f1b4c461916ef73b9
Parent:        6ea250e2d05aeb55c883aafa0a98e97660dfd633
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 20 10:44:28 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 20 10:44:28 2016 -0500

lvconvert: allow implied cache pool convert

Just as with the implied thin pool convert when
given ambiguous command line options.
---
 tools/lvconvert.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2e84348..2fd6094 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4201,7 +4201,9 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN_POOL)) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_raid_thin_pool(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE_POOL))
+	/* Using --cachepool is ambiguous and not preferred. */
+
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE_POOL)) || arg_is_set(cmd, cachepool_ARG))
 		return _convert_raid_cache_pool(cmd, lv, lp);
 
 	if (new_type && new_segtype && segtype_is_raid(new_segtype))
@@ -4261,7 +4263,9 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_THIN_POOL)) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_striped_thin_pool(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE_POOL))
+	/* Using --cachepool is ambiguous and not preferred. */
+
+	if ((new_type && !strcmp(new_type, SEG_TYPE_NAME_CACHE_POOL)) || arg_is_set(cmd, cachepool_ARG))
 		return _convert_striped_cache_pool(cmd, lv, lp);
 
 	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_MIRROR))



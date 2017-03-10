From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:34:49 -0500
Subject: master - lvconvert: validate name before prompt
Message-ID: <201703101834.v2AIYnfx030849@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb38426d289ab010d2083a394dca685eed13e7ff
Commit:        fb38426d289ab010d2083a394dca685eed13e7ff
Parent:        7ad57d55aff1f5647aed707fe22d2ff0d309d09d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 24 12:56:40 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

lvconvert: validate name before prompt

Before prompting make sure name fits.
---
 tools/lvconvert.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4e8dbc8..3d7259e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2719,6 +2719,16 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	}
 
 	/*
+	 * The internal LV names for pool data/meta LVs.
+	 */
+
+	if ((dm_snprintf(meta_name, sizeof(meta_name), "%s%s", lv->name, to_cachepool ? "_cmeta" : "_tmeta") < 0) ||
+	    (dm_snprintf(data_name, sizeof(data_name), "%s%s", lv->name, to_cachepool ? "_cdata" : "_tdata") < 0)) {
+		log_error("Failed to create internal lv names, pool name is too long.");
+		return 0;
+	}
+
+	/*
 	 * If an existing LV is to be used as the metadata LV,
 	 * verify that it's in a usable state.  These checks are
 	 * not done by command def rules because this LV is not
@@ -2842,7 +2852,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 	log_verbose("Pool metadata extents %u chunk_size %u", meta_extents, chunk_size);
 
-
 	/*
 	 * Verify that user wants to use these LVs.
 	 */
@@ -2870,16 +2879,6 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	}
 
 	/*
-	 * The internal LV names for pool data/meta LVs.
-	 */
-
-	if ((dm_snprintf(meta_name, sizeof(meta_name), "%s%s", lv->name, to_cachepool ? "_cmeta" : "_tmeta") < 0) ||
-	    (dm_snprintf(data_name, sizeof(data_name), "%s%s", lv->name, to_cachepool ? "_cdata" : "_tdata") < 0)) {
-		log_error("Failed to create internal lv names, pool name is too long.");
-		return 0;
-	}
-
-	/*
 	 * If a new metadata LV needs to be created, collect the settings for
 	 * the new LV and create it.
 	 *



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:49 +0000 (GMT)
Subject: main - make: replace legacy use rindex with strrchr
Message-ID: <20210927165749.DB229385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9971459d19e93ff652eeaff165da72e51b256299
Commit:        9971459d19e93ff652eeaff165da72e51b256299
Parent:        e585c10fade006e5fe3643b76b09501d54c20c9b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 17:40:35 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

make: replace legacy use rindex with strrchr

Seems already dropped by some systems.

Reported-by: adamboardman of gemian
---
 device_mapper/libdm-deptree.c | 2 +-
 lib/activate/dev_manager.c    | 2 +-
 libdm/libdm-deptree.c         | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index a0f386e77..e4bf4c814 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -604,7 +604,7 @@ static struct dm_tree_node *_find_dm_tree_node_by_uuid(struct dm_tree *dtree,
 	default_uuid_prefix = dm_uuid_prefix();
 	default_uuid_prefix_len = strlen(default_uuid_prefix);
 
-	if (suffix_list && (suffix_position = rindex(uuid, '-'))) {
+	if (suffix_list && (suffix_position = strrchr(uuid, '-'))) {
 		while ((suffix = suffix_list[i++])) {
 			if (strcmp(suffix_position + 1, suffix))
 				continue;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a8516d661..a73a556b2 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -838,7 +838,7 @@ static int _info(struct cmd_context *cmd,
 		return 1;
 
 	/* Check for original version of dlid before the suffixes got added in 2.02.106 */
-	if ((suffix_position = rindex(dlid, '-'))) {
+	if ((suffix_position = strrchr(dlid, '-'))) {
 		while ((suffix = uuid_suffix_list[i++])) {
 			if (strcmp(suffix_position + 1, suffix))
 				continue;
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d7fb5ef13..c14b6ef56 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -566,7 +566,7 @@ static struct dm_tree_node *_find_dm_tree_node_by_uuid(struct dm_tree *dtree,
 	default_uuid_prefix = dm_uuid_prefix();
 	default_uuid_prefix_len = strlen(default_uuid_prefix);
 
-	if (suffix_list && (suffix_position = rindex(uuid, '-'))) {
+	if (suffix_list && (suffix_position = strrchr(uuid, '-'))) {
 		while ((suffix = suffix_list[i++])) {
 			if (strcmp(suffix_position + 1, suffix))
 				continue;



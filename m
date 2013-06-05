From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:53 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lv_manip: use lv_is_active
Message-ID: <20130605120353.B102B610C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8cbacd2474b288a581274dba9b623ec2e9ac9d28
Commit:        8cbacd2474b288a581274dba9b623ec2e9ac9d28
Parent:        2ada982e73872e45215e68e57b2b6b4168dc26f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 16 23:12:39 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 20 16:47:33 2013 +0200

lv_manip: use lv_is_active

Updated reverted commit.
The usage of lv_is_active() is needed here, so the
(!lv_is_active_exclusive_locally) gives the correct
report.
---
 lib/metadata/lv_manip.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fadef6b..af000af 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4394,8 +4394,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	struct logical_volume *pool_lv;
 	struct lv_list *lvl;
 	const char *thin_name = NULL;
-	int origin_active = 0;
-	struct lvinfo info;
 
 	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
@@ -4525,15 +4523,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
 			}
 
-			if (!lv_info(cmd, org, 0, &info, 0, 0)) {
-				log_error("Check for existence of active snapshot "
-					  "origin '%s' failed.", org->name);
-				return NULL;
-			}
-
-			origin_active = info.exists;
-
-			if (vg_is_clustered(vg) &&
+			if (vg_is_clustered(vg) && lv_is_active(org) &&
 			    !lv_is_active_exclusive_locally(org)) {
 				log_error("%s must be active exclusively to"
 					  " create snapshot", org->name);



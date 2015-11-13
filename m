From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:13 +0000 (UTC)
Subject: master - cleanup: missing check for PV2
Message-ID: <20151113101913.00936610A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70af08122e26a3b7397e3f35b0e80a65543e157e
Commit:        70af08122e26a3b7397e3f35b0e80a65543e157e
Parent:        e0828e885b298537554d8b751fb52e1a69a04c9d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 11 22:05:52 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:17:06 2015 +0100

cleanup: missing check for PV2

Patch missed also check this pointer dereference.
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 68a8ac0..0022cb7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2143,7 +2143,7 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 			}
 			if (!pv_tags)
 				log_debug_alloc("Matched allocation PV tag %s on existing %s with free space on %s.",
-						str, pv_dev_name(pv1), pv_dev_name(pv2));
+						str, pv_dev_name(pv1), pv2 ? pv_dev_name(pv2) : "-");
 			else
 				log_debug_alloc("Eliminating allocation area %" PRIu32 " at PV %s start PE %" PRIu32
 						" from consideration: PV tag %s already used.",



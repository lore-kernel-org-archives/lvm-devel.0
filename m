From: David Teigland <teigland@sourceware.org>
Date: Tue, 25 Apr 2023 19:50:02 +0000 (GMT)
Subject: main - lvmcache: fix valgrind error when dropping md duplicate
Message-ID: <20230425195002.93EF83858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d262eaf640dead7861c1a7716e216b9bcea75e5
Commit:        6d262eaf640dead7861c1a7716e216b9bcea75e5
Parent:        ffead4f333d4d2a80a6913842a50fd265d5c4018
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 25 14:46:36 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 25 14:46:36 2023 -0500

lvmcache: fix valgrind error when dropping md duplicate

When lvmcache info is dropped because it's an md component,
then the lvmcache vginfo can also be dropped, but the list
iterator was still using the list head in vginfo, so break
from the loop earlier to avoid it.
---
 lib/cache/lvmcache.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b8a9eac25..127d29229 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1503,6 +1503,9 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 	 */
 
 	dm_list_iterate_items_safe(vginfo, vginfo2, &_vginfos) {
+		char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+		memcpy(vgid, vginfo->vgid, ID_LEN);
+
 		dm_list_iterate_items_safe(info, info2, &vginfo->infos) {
 			dev = info->dev;
 			device_hint = _get_pvsummary_device_hint(dev->pvid);
@@ -1557,6 +1560,10 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 				/* lvmcache_del will also delete vginfo if info was last one */
 				lvmcache_del(info);
 				cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
+
+				/* If vginfo was deleted don't continue using vginfo->infos */
+				if (!_search_vginfos_list(NULL, vgid))
+					break;
 			}
 		}
 	}


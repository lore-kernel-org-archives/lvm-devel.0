From: okozina <okozina@fedoraproject.org>
Date: Mon,  4 May 2015 14:57:34 +0000 (UTC)
Subject: master - polldaemon: respect lv_attr parm in poll_get_copy_lv
Message-ID: <20150504145734.0B50860D02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32527861d02bbd0bd3d0e0adec0f193f1f5eb98b
Commit:        32527861d02bbd0bd3d0e0adec0f193f1f5eb98b
Parent:        26f4b1da88ed1b26be232cbdab1d000697ef5aa9
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon May 4 15:41:27 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 4 16:56:52 2015 +0200

polldaemon: respect lv_attr parm in poll_get_copy_lv

as a part of bigger effort to unify polling intefaces
poll_get_copy_lv should be able to look up LVs based
on theirs lv->status field.

Effective after pvmove starts using poll_get_copy_lv
fn as well.
---
 tools/polldaemon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index a90bcfb..75a1224 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -66,11 +66,11 @@ struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd __attribute__((u
 					struct volume_group *vg,
 					const char *name,
 					const char *uuid,
-					uint64_t lv_type __attribute__((unused)))
+					uint64_t lv_type)
 {
 	struct logical_volume *lv = find_lv(vg, name);
 
-	if (!lv || (uuid && strcmp(uuid, (char *)&lv->lvid)))
+	if (!lv || (uuid && strcmp(uuid, (char *)&lv->lvid)) || (lv_type && !(lv->status & lv_type)))
 		return NULL;
 
 	return lv;



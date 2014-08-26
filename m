From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Aug 2014 12:17:38 +0000 (UTC)
Subject: master - cleanup: check pv_count is not 0
Message-ID: <20140826121738.E2B1E61291@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24001a08ab92737b32968aeba5f6b2b9c036c480
Commit:        24001a08ab92737b32968aeba5f6b2b9c036c480
Parent:        3b5afac9b433dd26f4461d4f59401bbb299219ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 21 15:38:18 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 26 14:13:06 2014 +0200

cleanup: check pv_count is not 0

Since we already detect writemostly_ARG is non-zero
make it obvious pv_count will also be non-zero in this case.
---
 tools/lvchange.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 42769c2..0981f2c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -740,9 +740,8 @@ static int lvchange_writemostly(struct logical_volume *lv)
 	if (arg_count(cmd, writebehind_ARG))
 		raid_seg->writebehind = arg_uint_value(cmd, writebehind_ARG, 0);
 
-	if (arg_count(cmd, writemostly_ARG)) {
+	if ((pv_count = arg_count(cmd, writemostly_ARG))) {
 		/* writemostly can be specified more than once */
-		pv_count = arg_count(cmd, writemostly_ARG);
 		pv_names = dm_pool_alloc(lv->vg->vgmem, sizeof(char *) * pv_count);
 		if (!pv_names)
 			return_0;



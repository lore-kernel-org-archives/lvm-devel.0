From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:59 +0000 (GMT)
Subject: main - cleanup: compare only LV uuid part
Message-ID: <20210308144659.2B84E395340E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d6e1ae8873cc4b91425e8f2edeba88cf79d8321
Commit:        6d6e1ae8873cc4b91425e8f2edeba88cf79d8321
Parent:        64447e9d9b237bf7955a84ab028a0d9b552e6ac7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 8 08:07:47 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:43:27 2021 +0100

cleanup: compare only LV uuid part

Match VG uuid just once per list of all LVs in VG.

TODO: maybe some more efficeint tree or hash could be better here,
but since it's used not so often, the total benefit is not so great,
so ATM just reducing amount of checked bytes.
---
 lib/metadata/metadata.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5410eac60..5de144616 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1664,9 +1664,12 @@ struct logical_volume *find_lv_in_vg_by_lvid(struct volume_group *vg,
 {
 	struct lv_list *lvl;
 
+	if (memcmp(&lvid->id[0], &vg->id, sizeof(vg->id)))
+		return NULL; /* Check VG does not match */
+
 	dm_list_iterate_items(lvl, &vg->lvs)
-		if (!strncmp(lvl->lv->lvid.s, lvid->s, sizeof(*lvid)))
-			return lvl->lv;
+		if (!memcmp(&lvid->id[1], &lvl->lv->lvid.id[1], sizeof(lvid->id[1])))
+			return lvl->lv; /* LV uuid match */
 
 	return NULL;
 }



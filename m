From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jun 2021 18:42:26 +0000 (GMT)
Subject: master - lvconvert: fix vdo virtual size when specified
Message-ID: <20210628184226.4F2083877424@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e773bb196d7e45fbecf0619f8993e6cf4534fa2
Commit:        6e773bb196d7e45fbecf0619f8993e6cf4534fa2
Parent:        d9cb1d398320420280cd7dde28fca77d2459457c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 28 18:12:19 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 28 20:41:07 2021 +0200

lvconvert: fix vdo virtual size when specified

Correctly use virtual size specified by:
lvconvert --type vdo-pool --virtualsize
---
 lib/metadata/vdo_manip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 7d5a2cb5a..afc513ae5 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -393,7 +393,8 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 	} else {
 		log_verbose("Skiping VDO formating %s.", display_lvname(data_lv));
 		/* TODO: parse existing VDO data and retrieve vdo_logical_size */
-		vdo_logical_size = data_lv->size;
+		if (!*virtual_extents)
+			vdo_logical_size = data_lv->size;
 	}
 
 	if (!deactivate_lv(data_lv->vg->cmd, data_lv)) {



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:12 +0000 (GMT)
Subject: master - lvcreate: change error message
Message-ID: <20200915212112.C1534397249F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=187cc8d344ed806194ac7a8ce7582d043cf1d673
Commit:        187cc8d344ed806194ac7a8ce7582d043cf1d673
Parent:        39198eb2cebb6a45e148d554d1ed474bda5cbbde
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 22:45:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 22:52:25 2020 +0200

lvcreate: change error message

Provide more useful error message.
---
 lib/metadata/vdo_manip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 7862682d8..30682449c 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -390,7 +390,8 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 	}
 
 	if (!deactivate_lv(data_lv->vg->cmd, data_lv)) {
-		log_error("Aborting. Manual intervention required.");
+		log_error("Cannot deactivate formated VDO pool volume %s.",
+			  display_lvname(data_lv));
 		return NULL;
 	}
 



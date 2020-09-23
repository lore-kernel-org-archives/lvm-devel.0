From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 23 Sep 2020 12:59:32 +0000 (GMT)
Subject: master - vdo: disable support for online rename of vdopool LV
Message-ID: <20200923125932.31754398E477@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c19186271d3bf37412b7e7dcc271bc9b79f9f4a
Commit:        7c19186271d3bf37412b7e7dcc271bc9b79f9f4a
Parent:        3869c9c4f630f33ef1b7e8c4e7e08968e6ef3c09
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 13:18:23 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 23 13:18:23 2020 +0200

vdo: disable support for online rename of vdopool LV

Since ATM kernel does not support this operation,
disable 'lvrename' of an active vdopool.

As a workaround, user may simply deactivate, rename and activate.
---
 lib/metadata/lv_manip.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9f15e9f21..ff86a7ab3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4717,6 +4717,12 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_vdo_pool(lv) && lv_is_active(lv_lock_holder(lv))) {
+		log_error("Cannot rename active VDOPOOL volume %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	if (update_mda && !archive(vg))
 		return_0;
 



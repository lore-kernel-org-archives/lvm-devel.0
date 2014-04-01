From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:56:13 +0000 (UTC)
Subject: master - debug: add internal error for passed LV
Message-ID: <20140401185613.B8D9D60CB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc5a3c9964229a5b7a23c7ceb76523d662ddbc27
Commit:        dc5a3c9964229a5b7a23c7ceb76523d662ddbc27
Parent:        1eaef2b705f82969e0a463f122ddda569676ce13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 20:11:50 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:54:09 2014 +0200

debug: add internal error for passed LV

TODO: in fact we should parameter LV.
---
 lib/metadata/lv_manip.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5d2cdb9..740eef0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5202,10 +5202,15 @@ int remove_layer_from_lv(struct logical_volume *lv,
 
 	if (!(parent_seg = get_only_segment_using_this_lv(layer_lv))) {
 		log_error("Failed to find layer %s in %s",
-		layer_lv->name, lv->name);
+			  layer_lv->name, lv->name);
 		return 0;
 	}
 	parent = parent_seg->lv;
+	if (parent != lv) {
+		log_error(INTERNAL_ERROR "Wrong layer %s in %s",
+			  layer_lv->name, lv->name);
+		return 0;
+	}
 
 	/*
 	 * Before removal, the layer should be cleaned up,



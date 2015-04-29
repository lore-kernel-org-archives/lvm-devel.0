From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 29 Apr 2015 13:10:26 +0000 (UTC)
Subject: master - lvmetad: drop unused vars
Message-ID: <20150429131026.2AC1C60ECF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=923902013c6d47f02abe2d6171bdeed9f16f413c
Commit:        923902013c6d47f02abe2d6171bdeed9f16f413c
Parent:        5d8b31ffad4fb6e3f1e9a4f20387cd7f1e141085
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 29 15:00:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 29 15:09:58 2015 +0200

lvmetad: drop unused vars

Squash some unused vars introduced in some previous commit.s
---
 daemons/lvmetad/lvmetad-core.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index e3394ab..398ef38 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -809,8 +809,7 @@ static response pv_gone(lvmetad_state *s, request r)
 	int64_t device = daemon_request_int(r, "device", 0);
 	int64_t alt_device = 0;
 	struct dm_config_tree *pvmeta;
-	struct dm_config_node *pvmeta_tmp;
-	char *pvid_old, *vgid;
+	char *vgid;
 
 	DEBUGLOG(s, "pv_gone: %s / %" PRIu64, pvid, device);
 
@@ -825,7 +824,6 @@ static response pv_gone(lvmetad_state *s, request r)
 	DEBUGLOG(s, "pv_gone (updated): %s / %" PRIu64, pvid, device);
 
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
-	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
 	vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 
 	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));



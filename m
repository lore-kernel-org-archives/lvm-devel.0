From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:49:01 +0000 (UTC)
Subject: master - cleanup: move declaration to the front
Message-ID: <20131128114901.764CA60F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c787d9b6ed9c9ef2964431881884dd3879f4dc1
Commit:        6c787d9b6ed9c9ef2964431881884dd3879f4dc1
Parent:        50e1fad86a5ca85965222d2ba9b8a7076d07cbbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 25 13:43:25 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:48:01 2013 +0100

cleanup: move declaration to the front

---
 daemons/lvmetad/lvmetad-core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 87374e8..7e64d9d 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -791,7 +791,7 @@ static response pv_gone(lvmetad_state *s, request r)
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	int64_t device = daemon_request_int(r, "device", 0);
 	struct dm_config_tree *pvmeta;
-	char *pvid_old;
+	char *pvid_old, *vgid;
 
 	DEBUGLOG(s, "pv_gone: %s / %" PRIu64, pvid, device);
 
@@ -807,7 +807,7 @@ static response pv_gone(lvmetad_state *s, request r)
 
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
-	char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
+	vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
 
 	if (vgid && !(vgid = dm_strdup(vgid))) {
 		unlock_pvid_to_pvmeta(s);



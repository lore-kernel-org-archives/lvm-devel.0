From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 05:52:55 +0000 (UTC)
Subject: master - lvmetad: Fix a typo-induced leak in destroy_metadata_hashes.
Message-ID: <20121009055255.1105C2E1B@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=138b4e1719324139426d894f666d00b8f5b86965
Commit:        138b4e1719324139426d894f666d00b8f5b86965
Parent:        a19a5953433c86811df80c59de7ec6346c62be32
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 20:15:09 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 20:35:29 2012 +0200

lvmetad: Fix a typo-induced leak in destroy_metadata_hashes.

---
 daemons/lvmetad/lvmetad-core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index dce7535..1dc05d6 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -51,6 +51,7 @@ static void destroy_metadata_hashes(lvmetad_state *s)
 {
 	struct dm_hash_node *n = NULL;
 
+	n = dm_hash_get_first(s->vgid_to_metadata);
 	while (n) {
 		dm_config_destroy(dm_hash_get_data(s->vgid_to_metadata, n));
 		n = dm_hash_get_next(s->vgid_to_metadata, n);



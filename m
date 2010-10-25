From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:27 +0200
Subject: [PATCH 20/30] Fix constness warning
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <af618d30d3fffc82a0d504efa542210f80afe790.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2da4085..77fdd02 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3141,7 +3141,7 @@ struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
 	lvid = (const union lvid *) lvid_s;
 
 	log_very_verbose("Finding volume group for uuid %s", lvid_s);
-	if (!(vg = _vg_read_by_vgid(cmd, (char *)lvid->id[0].uuid, precommitted))) {
+	if (!(vg = _vg_read_by_vgid(cmd, (const char *)lvid->id[0].uuid, precommitted))) {
 		log_error("Volume group for uuid not found: %s", lvid_s);
 		return NULL;
 	}
-- 
1.7.3.1



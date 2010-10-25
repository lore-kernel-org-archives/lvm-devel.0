From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:11 +0200
Subject: [PATCH 04/30] Fix NULL pointer dereference
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <12027a536f66f50657c23bb7bed13380c590f423.1287994529.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

vg pointer is not yet initialized in this place and vgname must be used.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/format-text.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index eee0114..0102a15 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -507,7 +507,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 
 	if (wrap > rlocn->offset) {
 		log_error("VG %s metadata too large for circular buffer",
-			  vg->name);
+			  vgname);
 		goto out;
 	}
 
-- 
1.7.3.1



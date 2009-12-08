From: Milan Broz <mbroz@redhat.com>
Date: Tue,  8 Dec 2009 16:39:41 +0100
Subject: [PATCH 06/10] Allow manipulation with precommited metadata even when a PV is missing.
In-Reply-To: <cover.1260284754.git.mbroz@redhat.com>
References: <cover.1260284754.git.mbroz@redhat.com>
Message-ID: <33fcbfd139c20cca8680adb9560728c351eee224.1260284754.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The new recovery code first tries to repair LV and then removes failed PV
from VG. It means that during operation there can be VG with PV missing,
and vg_read code handles it like not consistent VG.

We already allows returning "inconsistent" commited metadata,
for mirror repair we need this for precommited too.
(The suspend call prepares precommited metadata to inactive table on
other cluster nodes.)

"Inconsistent" here means - correct metadata, just with some metadata areas
not found (obviously on missing or failed PVs).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9d5b1ae..c8099b5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2706,8 +2706,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (use_precommitted) {
 			log_error("Inconsistent pre-commit metadata copies "
 				  "for volume group %s", vgname);
-			vg_release(correct_vg);
-			return NULL;
+			*consistent = 0;
+			return correct_vg;
 		}
 
 		if (!*consistent)
-- 
1.6.5.4



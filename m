From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:41 -0400
Subject: [PATCH 10/38] Use vg_mda_count() in vgdisplay.
In-Reply-To: <1277520789-6808-10-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/display/display.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index a835327..7a8e325 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -664,7 +664,7 @@ void vgdisplay_full(const struct volume_group *vg)
 	log_print("Format                %s", vg->fid->fmt->name);
 	if (vg->fid->fmt->features & FMT_MDAS) {
 		log_print("Metadata Areas        %d",
-			  dm_list_size(&vg->fid->metadata_areas));
+			  vg_mda_count(vg));
 		log_print("Metadata Sequence No  %d", vg->seqno);
 	}
 	access_str = vg->status & (LVM_READ | LVM_WRITE);
-- 
1.6.0.6



From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:43 -0400
Subject: [PATCH 10/35] Use vg_mda_count() in vgdisplay.
In-Reply-To: <1277175968-9661-10-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-11-git-send-email-dwysocha@redhat.com>
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



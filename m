From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:06:06 -0400
Subject: [PATCH 33/35] Update _vgmerge_single() to move fid->metadata_areas_ignored.
In-Reply-To: <1277175968-9661-33-git-send-email-dwysocha@redhat.com>
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
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-18-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-25-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-26-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-27-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-28-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-29-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-30-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-31-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-32-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-33-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-34-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When vgmerge is called we move the mdas from the source to the
destination.  With metadata balancing we now have another mda
list, fid->metadata_areas_ignored, so move the mdas on this list
as well.

This patch should not matter as the code is written today.  However
we include it for completeness in the case that _vgmerge_single()
is refactored and/or moved into a library function.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgmerge.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 299bed7..ff74705 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -126,6 +126,12 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		dm_list_move(&vg_to->fid->metadata_areas, mdah);
 	}
 
+	while (!dm_list_empty(&vg_from->fid->metadata_areas_ignored)) {
+		struct dm_list *mdah = vg_from->fid->metadata_areas_ignored.n;
+
+		dm_list_move(&vg_to->fid->metadata_areas_ignored, mdah);
+	}
+
 	vg_to->extent_count += vg_from->extent_count;
 	vg_to->free_count += vg_from->free_count;
 
-- 
1.6.0.6



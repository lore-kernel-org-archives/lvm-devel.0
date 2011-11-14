From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Nov 2011 16:12:58 -0500
Subject: [PATCH 2/5] Call _check_pv_sizes() from vg_read_internal(), print warning.
In-Reply-To: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
References: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1321305181-28158-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If we read a vg with any PVs that have changed sizes since pvcreate,
flag it as a warning for now.

We probably want to provide a command to safely repair this condition,
perhaps vgck and/or pvck.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3ee39f7..56d78fa 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3358,6 +3358,11 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 	if (!(vg = _vg_read(cmd, vgname, vgid, warnings, consistent, 0)))
 		return NULL;
 
+	if (!_check_pv_sizes(vg)) {
+		log_warn("WARNING: One or more PVs have changed sizes in %s.",
+			  vg->name);
+	}
+
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);
-- 
1.7.4.4



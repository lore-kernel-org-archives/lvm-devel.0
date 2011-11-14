From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Nov 2011 16:12:59 -0500
Subject: [PATCH 3/5] Call _check_pv_sizes() from vg_validate().
In-Reply-To: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
References: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1321305181-28158-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Check PV sizes from vg_validate(), which gets called from pvck,
as well as vg_write() (before any metadata changes).  We'll need
to relax this check if we want to add a repair function.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 56d78fa..8fd2d23 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2394,6 +2394,11 @@ int vg_validate(struct volume_group *vg)
 		}
 	}
 
+	if (!_check_pv_sizes(vg)) {
+		log_error("One or more PVs have changed sizes in %s.",
+			  vg->name);
+		r = 0;
+	}
 
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
-- 
1.7.4.4



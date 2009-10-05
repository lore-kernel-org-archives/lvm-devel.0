From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:36 +0200
Subject: [PATCH 09/13] Replicator: do not remove of replicators' LVs
In-Reply-To: <1254751240-17431-8-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-3-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-4-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-5-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-6-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-7-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-8-git-send-email-zkabelac@redhat.com>
Message-ID: <1254751240-17431-9-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 51e100e..5e21fca 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2084,6 +2084,15 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_replicator_dev(lv) ||
+	    lv_is_rimage(lv) ||
+	    lv_is_rlog(lv) ||
+	    lv_is_slog(lv)) {
+		log_error("Can't remove logical volume %s used by a replicator",
+			  lv->name);
+		return 0;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;
-- 
1.6.5.rc2



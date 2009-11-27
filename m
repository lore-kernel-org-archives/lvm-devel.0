From: Milan Broz <mbroz@redhat.com>
Date: Fri, 27 Nov 2009 15:01:58 +0100
Subject: [PATCH 2/2] Do not allow creating mirros of more then 8 images.
In-Reply-To: <1259330518-18390-1-git-send-email-mbroz@redhat.com>
References: <1259330518-18390-1-git-send-email-mbroz@redhat.com>
Message-ID: <1259330518-18390-2-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is kernel limitation in all kernel versions,
so better detect this early.
---
 lib/config/defaults.h |    1 +
 tools/lvconvert.c     |    6 ++++++
 tools/lvcreate.c      |    6 ++++++
 3 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 824fec2..c4a23a4 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -47,6 +47,7 @@
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_DEV_FAULT_POLICY "remove"
+#define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_MONITOR 1
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0821c30..b179f60 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -571,6 +571,12 @@ static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv
 	else
 		lp->mirrors += 1;
 
+	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
+		log_error("Only up to %d images in mirror supported currently.",
+			  DEFAULT_MIRROR_MAX_IMAGES);
+		return 0;
+	}
+
 	if (repair) {
 		cmd->handles_missing_pvs = 1;
 		cmd->partial_activation = 1;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f250f37..2b2d135 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -500,6 +500,12 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
+	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
+		log_error("Only up to %d images in mirror supported currently.",
+			  DEFAULT_MIRROR_MAX_IMAGES);
+		return 0;
+	}
+
 	/*
 	 * Read ahead.
 	 */
-- 
1.6.5.3



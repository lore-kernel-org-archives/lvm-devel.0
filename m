From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 20 Jan 2010 13:19:40 -0500
Subject: [PATCH 1/3] Correct 'void *' usage in pvcreate_single.
In-Reply-To: <1264011582-11548-1-git-send-email-dwysocha@redhat.com>
References: <1264011582-11548-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1264011582-11548-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4df187f..f464cf8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1348,7 +1348,7 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 					 const char *pv_name,
 					 struct pvcreate_params *pp)
 {
-	void *pv;
+	struct physical_volume *pv;
 	struct device *dev;
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
-- 
1.6.0.6



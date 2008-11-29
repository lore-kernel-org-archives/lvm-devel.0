From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 29 Nov 2008 16:02:31 -0500
Subject: [PATCH 2/4] Allow pvcreate_single() to be called with NULL for pvcreate parameters.
In-Reply-To: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1227992553-4381-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 265b619..09c345f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -993,10 +993,28 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
 		    void *handle)
 {
-	struct pvcreate_params *pp = (struct pvcreate_params *) handle;
+	struct pvcreate_params *pp;
 	void *pv;
 	struct device *dev;
 	struct dm_list mdas;
+	struct pvcreate_params default_pp = { 0, /* zero Y/N */
+					      0, /* size */
+					      DEFAULT_PVMETADATACOPIES,
+					      DEFAULT_PVMETADATASIZE,
+					      DEFAULT_LABELSECTOR,
+					      { { 0 } }, /* id */
+					      0, /* idp */
+					      0, /* pe_start */
+					      0, /* extent_count */
+					      0, /* extent_size */
+					      0, /* restorefile */
+					      PROMPT, /* force option */
+					      0 /* yes */};
+
+	if (!handle)
+		pp = &default_pp;
+	else
+		pp = (struct pvcreate_params *) handle;
 
 	if (pp->idp) {
 		if ((dev = device_from_pvid(cmd, pp->idp)) &&
-- 
1.5.5.1



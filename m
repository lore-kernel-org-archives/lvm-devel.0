From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 00:05:48 -0400
Subject: [PATCH 3/8] Allow pvcreate_single to be called with NULL for default pvcreate params.
In-Reply-To: <1248235553-13519-3-git-send-email-dwysocha@redhat.com>
References: <1248235553-13519-1-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-2-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1248235553-13519-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Passing NULL for pvcreate parameters gives you default parameters for
pvcreate_single.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f843fb8..6b7039f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1097,12 +1097,37 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	return 1;
 }
 
+static void fill_default_pvcreate_params(struct pvcreate_params *pp)
+{
+	memset(pp, 0, sizeof(*pp));
+	pp->zero = 0;
+	pp->size = 0;
+	pp->data_alignment = UINT64_C(0);
+	pp->pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
+	pp->pvmetadatasize = DEFAULT_PVMETADATASIZE;
+	pp->labelsector = DEFAULT_LABELSECTOR;
+	pp->idp = 0;
+	pp->pe_start = 0;
+	pp->extent_count = 0;
+	pp->extent_size = 0;
+	pp->restorefile = 0;
+	pp->force = PROMPT;
+	pp->yes = 0;
+}
+
 int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle)
 {
-	struct pvcreate_params *pp = (struct pvcreate_params *) handle;
+	struct pvcreate_params *pp;
 	void *pv;
 	struct device *dev;
 	struct dm_list mdas;
+	struct pvcreate_params default_pp;
+
+	fill_default_pvcreate_params(&default_pp);
+	if (!handle)
+		pp = &default_pp;
+	else
+		pp = (struct pvcreate_params *) handle;
 
 	if (pp->idp) {
 		if ((dev = device_from_pvid(cmd, pp->idp)) &&
-- 
1.6.0.6



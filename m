From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 21:41:32 +0000 (GMT)
Subject: master - gcc: hide warn about possible uninitialized use of dev_ret
Message-ID: <20200901214132.B4683386F823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=672d5ad98b289663b51b2e34f5fb937c64222abb
Commit:        672d5ad98b289663b51b2e34f5fb937c64222abb
Parent:        11f08dacc920dba49d932ccdf378331a32bad9d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 1 20:46:18 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 23:40:24 2020 +0200

gcc: hide warn about possible uninitialized use of dev_ret

Older gcc reports this fp problem.
---
 lib/metadata/metadata.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bf3669b10..8b8c491c0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4679,7 +4679,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct volume_group *vg, *vg_ret = NULL;
 	struct metadata_area *mda, *mda2;
 	unsigned use_precommitted = precommitted;
-	struct device *mda_dev, *dev_ret, *dev;
+	struct device *mda_dev, *dev_ret = NULL, *dev;
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
 	struct pv_list *pvl;
 	int found_old_metadata = 0;



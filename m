From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  2 Jul 2014 13:57:20 +0000 (UTC)
Subject: master - report: Exclude hidden devices from lv_path field.
Message-ID: <20140702135720.D214B60285@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bfa2ec21d79b090276676076917808207ad4dd1
Commit:        5bfa2ec21d79b090276676076917808207ad4dd1
Parent:        c6811dd51218e88467d91a1b2b309bbfed5eaf0e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 2 14:57:00 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 2 14:57:00 2014 +0100

report: Exclude hidden devices from lv_path field.

---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dfbb4e3..c55b3fb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Change lv_path field to suppress devices that never appear in /dev/vg.
   Postpone thin pool lvconvert prompts (2.02.107).
   Require --yes option to skip prompt to lvconvert thin pool chunksize.
   Support lvremove -ff to remove thin volumes from broken thin pools.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index f1d93a9..55395ce 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -370,7 +370,8 @@ char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	char *repstr;
 	size_t len;
 
-	if (!*lv->vg->name)
+	/* Only for visible devices that get a link from /dev/vg */
+	if (!*lv->vg->name || !lv_is_visible(lv) || lv_is_thin_pool(lv))
 		return dm_pool_strdup(mem, "");
 
 	len = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) +



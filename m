From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Jun 2021 16:14:03 +0000 (GMT)
Subject: main - writecache: fix lv_on_pmem
Message-ID: <20210602161403.2DBA1396EC42@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=247f69f9aafe731ef85268da1e6ce817295b265d
Commit:        247f69f9aafe731ef85268da1e6ce817295b265d
Parent:        b725b5ea6ecfeef428fd7ffcd6855a38378d761b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 2 10:51:12 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 2 10:51:12 2021 -0500

writecache: fix lv_on_pmem

dev_is_pmem on pv->dev requires a pv segment or it could segfault.
---
 lib/metadata/metadata.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 110cbaed4..0b284435b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4412,6 +4412,9 @@ int lv_on_pmem(struct logical_volume *lv)
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_PV)
+				continue;
+
 			pv = seg_pv(seg, s);
 
 			if (dev_is_pmem(lv->vg->cmd->dev_types, pv->dev)) {



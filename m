From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 08:54:42 +0000 (UTC)
Subject: master - lvm2app: fix lvm_lv_get_attr regression causing unknown values
Message-ID: <20150130085442.07F3860FA9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=531cc58d899b7dd1421bfe83f5503aa266390334
Commit:        531cc58d899b7dd1421bfe83f5503aa266390334
Parent:        8dc1da2cbed42e9c5a4dee5b342bb4aff8c9d9a3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 30 09:45:22 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 09:53:34 2015 +0100

lvm2app: fix lvm_lv_get_attr regression causing unknown values

This is a regression from v115 where some of the fields/properties
were converted to using the common "struct lvinfo" and
"struct lv_seg_status" so we don't need to issue info and status
ioctl several times per one reported line. Not all fields are
converted yet, but one that *is* converted is the lv_attr field
with the lv_attr_dup counterpart used in lvm_lv_get_attr lvm2app fn.

These changes were introduced with e34b004422f0d51263e0d34f4064556cfc9148f6
and later - this patch introduced the "info_ok" field in the
lv_with_info_and_seg_status structure which encapsulates the lvinfo
and lv_seg_status struct.

For the lv_attr_dup, the lv_attr_dup code  missed the
assignment for the "info_ok" flag which saves the result of the
lv_info_with_seg_status call. Hence such info was marked
as unusable - unknown and it was returned as such via lvm_lv_get_attr
lvm2app fn.
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f2546a9..62f03ef 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Fix lvm2app regression in lvm_lv_get_attr causing unknown values (2.02.115).
   Set default cache_mode to writehrough when missing in metadata.
   Preserve chunk size with repair and metadata swap of a thin pool.
   Fix raid --splitmirror 1 functionality (2.02.112).
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9052e63..c3c5d4a 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -831,7 +831,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024)))
 		return_0;
 
-	if (!lv_info_with_seg_status(lv->vg->cmd, lv, first_seg(lv), 1, &status, 1, 1))
+	if (!(status.info_ok = lv_info_with_seg_status(lv->vg->cmd, lv, first_seg(lv), 1, &status, 1, 1)))
 		goto_bad;
 
 	ret = lv_attr_dup_with_info_and_seg_status(mem, &status);



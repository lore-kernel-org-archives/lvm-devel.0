From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 31 Aug 2021 20:06:08 +0000 (GMT)
Subject: main - vdo: fix conversion of large virtual sizes
Message-ID: <20210831200608.139B63858400@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4afe872fd6c43fcfcd519c862574d010cdbda653
Commit:        4afe872fd6c43fcfcd519c862574d010cdbda653
Parent:        88360b0c512d96dfe05c11362ff389ef6bfec6b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 30 18:12:59 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 31 22:05:47 2021 +0200

vdo: fix conversion of large virtual sizes

Properly accept virtual sizes above 2TiB.
---
 tools/lvconvert.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 83dfe5c71..d73e16e3a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5428,7 +5428,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		return_0;
 
 	lvc.virtual_extents = extents_from_size(cmd,
-						arg_uint_value(cmd, virtualsize_ARG, 0),
+						arg_uint64_value(cmd, virtualsize_ARG, UINT64_C(0)),
 						vg->extent_size);
 
 	if (!(lvc.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_VDO)))



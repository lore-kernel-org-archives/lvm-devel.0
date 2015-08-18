From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 14:05:15 +0000 (UTC)
Subject: master - cleanup: compare fgets pointer
Message-ID: <20150818140515.AE11560DD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7abade088b5085eed248ab4369fa70263a40bfc
Commit:        a7abade088b5085eed248ab4369fa70263a40bfc
Parent:        abb24370e9bee7e218c333a23c574fed0b4d95ff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 15:48:05 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 16:05:04 2015 +0200

cleanup: compare fgets pointer

Check pointer for not being NULL.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0897e09..37ae197 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2430,7 +2430,7 @@ static int _lvconvert_pool_repair(struct cmd_context *cmd,
 			 * Scan only the 1st. line for transation id.
 			 * Watch out, if the thin_dump format changes
 			 */
-			if ((fgets(meta_path, sizeof(meta_path), f) > 0) &&
+			if (fgets(meta_path, sizeof(meta_path), f) &&
 			    (trans_id_str = strstr(meta_path, "transaction=\"")) &&
 			    (sscanf(trans_id_str + 13, FMTu64, &trans_id) == 1) &&
 			    (trans_id != first_seg(pool_lv)->transaction_id) &&



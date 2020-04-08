From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Apr 2020 13:37:45 +0000 (GMT)
Subject: master - lvconvert: no validation for thin-pools not used by lvm2
Message-ID: <20200408133745.880E3385BF81@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=98e33ee3fbce8c43c312a2e6b8e42cddb3e6874c
Commit:        98e33ee3fbce8c43c312a2e6b8e42cddb3e6874c
Parent:        06cbe3cfc6958b016d97243b807aaf29b9908b23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 8 11:46:42 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 15:22:44 2020 +0200

lvconvert: no validation for thin-pools not used by lvm2

lvm2 supports thin-pool to be later used by other tools doing
virtual volumes themself (i.e. docker) - in this case we
shall not validate transaction Id - is this is used by
other tools and lvm2 keeps value 0 - so the transationId
validation need to be skipped in this case.
---
 tools/lvconvert.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f6d9a29f6..bb40930cb 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2388,7 +2388,8 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 		goto deactivate_mlv;
 	}
 
-	if (thin_dump[0]) {
+	/* Check matching transactionId when thin-pool is used by lvm2 (transactionId != 0) */
+	if (first_seg(pool_lv)->transaction_id && thin_dump[0]) {
 		argv[0] = thin_dump;
 		argv[1] = pms_path;
 		argv[2] = NULL;




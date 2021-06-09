From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  9 Jun 2021 14:21:41 +0000 (GMT)
Subject: main - archive: avoid abuse of internal flag
Message-ID: <20210609142141.6E67D3848420@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17b27464868ac7049624d9b90f68c59200866997
Commit:        17b27464868ac7049624d9b90f68c59200866997
Parent:        bb45e33518b56a06df8a52226e383ca9ce938d0d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 9 16:16:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 9 16:18:20 2021 +0200

archive: avoid abuse of internal flag

Since archive is now postponned we use internal variable 'changed'
to mark we need to commit new metadata.
---
 WHATS_NEW        | 1 +
 tools/vgchange.c | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 04c6dcdf2..2c4704310 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.13 - 
 ===============================
+  Simplified handling of archive() and backup() internal calls.
   Fix load of kvdo target when it is not present in memory (2.03.12).
 
 Version 2.03.12 - 07th May 2021
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 9f972acdb..22038ba9b 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -640,6 +640,7 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	int ret = ECMD_PROCESSED;
 	unsigned i;
 	activation_change_t activate;
+	int changed = 0;
 
 	static const struct {
 		int arg;
@@ -677,10 +678,11 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		if (arg_is_set(cmd, _vgchange_args[i].arg)) {
 			if (!_vgchange_args[i].fn(cmd, vg))
 				return_ECMD_FAILED;
+			changed = 1;
 		}
 	}
 
-	if (vg_is_archived(vg)) {
+	if (changed) {
 		if (!vg_write(vg) || !vg_commit(vg))
 			return_ECMD_FAILED;
 



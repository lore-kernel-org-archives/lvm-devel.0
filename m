From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu,  5 May 2022 09:14:18 +0000 (GMT)
Subject: master - toollib: fix segfault when handling selection with historical LVs
Message-ID: <20220505091418.41EE13858434@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ec0726ce331a4dc1ab5dc5e1b9ae503e5d758da
Commit:        7ec0726ce331a4dc1ab5dc5e1b9ae503e5d758da
Parent:        ff6022d400430df2f51160ce9eec4010ac55696c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 5 11:02:32 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 5 11:13:39 2022 +0200

toollib: fix segfault when handling selection with historical LVs

When processing historical LVs inside process_each_lv_in_vg for
selection, we need to use dummy "_historical_lv" for select_match_lv.

This is because a historical LV is not an actual LV, but only a tiny
representation with subset of original properties that we recorded
(name, uuid...).

To use the same processing functions we use for full-fledged non-historical
LVs, we need to use the prefilled "_historical_lv" structure which has all
the other missing properties hard-coded.
---
 WHATS_NEW       | 1 +
 tools/toollib.c | 7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fad32ab08..db8265a78 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.16 - 
 ====================================
+  Fix segfault when handling selection with historical LVs.
   Add support --vdosettings with lvcreate, lvconvert, lvchange.
   Fix lossing of delete message on thin-pool extension.
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 545407c2f..d77092d89 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3447,13 +3447,14 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 				process_lv = 1;
 			}
 
-			process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv) && _select_matches(handle);
+			_historical_lv.this_glv = glvl->glv;
+			_historical_lv.name = glvl->glv->historical->name;
+
+			process_lv = process_lv && select_match_lv(cmd, handle, vg, &_historical_lv) && _select_matches(handle);
 
 			if (!process_lv)
 				continue;
 
-			_historical_lv.this_glv = glvl->glv;
-			_historical_lv.name = glvl->glv->historical->name;
 			log_very_verbose("Processing historical LV %s in VG %s.", glvl->glv->historical->name, vg->name);
 
 			ret = process_single_lv(cmd, &_historical_lv, handle);


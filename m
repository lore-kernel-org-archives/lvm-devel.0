From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 10:44:34 -0400
Subject: master - activation: drop removed declaration
Message-ID: <201910311444.x9VEiY5N018568@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cca5aec0ef3bd8481a07e2f6d37134340e49684a
Commit:        cca5aec0ef3bd8481a07e2f6d37134340e49684a
Parent:        50b50039d927f1e30d769639022f1b483a909def
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 31 15:33:09 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 31 15:33:09 2019 +0100

activation: drop removed declaration

Seems this function has been removed long time ago with:
3e781ea446bb7ddc9a494cbba6b6104dd51c3910
---
 lib/activate/activate.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 4bb755c..a5ee438 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -144,8 +144,6 @@ int revert_lv(struct cmd_context *cmd, const struct logical_volume *lv);
  */
 int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_layer,
 	    struct lvinfo *info, int with_open_count, int with_read_ahead);
-int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
-		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 int lv_info_with_name_check(struct cmd_context *cmd, const struct logical_volume *lv,
 			    int use_layer, struct lvinfo *info);
 



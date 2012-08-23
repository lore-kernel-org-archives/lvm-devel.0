From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 14:32:22 +0000 (UTC)
Subject: master - clenaup: compatible definition for older gcc
Message-ID: <20120823143222.161EAA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=329c46d36ee16cc374c31af7aaf3bb84b21ab462
Commit:        329c46d36ee16cc374c31af7aaf3bb84b21ab462
Parent:        7b300a803c0878e6c9a42aeb5d2c53ac7f64afed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 23 16:12:45 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 16:30:22 2012 +0200

clenaup: compatible definition for older gcc

Fixes previous commit, it seems older gcc compilers do not
recognize same typedef.

(Easiest would be probably to directly include proper header here).
---
 lib/cache/lvmetad.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 932a9f1..9c49440 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -18,10 +18,10 @@
 struct volume_group;
 struct cmd_context;
 struct dm_config_tree;
-typedef enum activation_change activation_change_t;
+enum activation_change;
 
 typedef int (*activation_handler) (struct volume_group *vg, int partial,
-				   activation_change_t activate);
+				   enum activation_change activate);
 
 #ifdef LVMETAD_SUPPORT
 /*



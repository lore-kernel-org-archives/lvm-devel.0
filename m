From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:19 +0000 (GMT)
Subject: main - cleanup: improving message
Message-ID: <20210223140419.CD189393A407@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c842ee8adc4f5566e49b59abee5d43a15b85f0c
Commit:        0c842ee8adc4f5566e49b59abee5d43a15b85f0c
Parent:        5237175cb6486c782589d7c9afb4f532ee5897b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 20 23:23:00 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:56:48 2021 +0100

cleanup: improving message

lvconvert -Z can be used with snaps & pools.
---
 tools/lvconvert.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a67b4ee72..87539be49 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -255,7 +255,7 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
 			}
 
 			if (arg_is_set(cmd, zero_ARG)) {
-				log_error("--zero is only available with snapshots or thin pools.");
+				log_error("--zero is only available with snapshots or pools.");
 				return 0;
 			}
 



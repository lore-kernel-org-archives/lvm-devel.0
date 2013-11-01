From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 Nov 2013 12:05:46 +0000 (UTC)
Subject: master - locking: activate_lv_excl return correct error code
Message-ID: <20131101120546.BCFAE61028@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bde9f68cea61c7ee085588f2595ed52277da084
Commit:        1bde9f68cea61c7ee085588f2595ed52277da084
Parent:        de7531d384b1b505801ac232da45b9ffe58f061b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 10:26:43 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 13:02:13 2013 +0100

locking: activate_lv_excl return correct error code

Correct return code of activate_lv_excl().

Function is not supposed to return activation state of
activated volume, but return code of the operation.
Since i.e. when activation filter is allowing to activate
volume on current system, it is still success even though
no volume is activated.
---
 WHATS_NEW             |    1 +
 lib/locking/locking.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b8a9bf7..2bf95d2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104 -
 ===================================
+  Return proper error state for remote exclusive activation.
   Fix missing lvmetad scan for PVs found on MD partitions.
   Respect DM_UDEV_DISABLE_OTHER_RULES_FLAG in lvmetad udev rules.
   Fix clvmd message verification to not reject REMOTE flag. (2.02.100)
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 9183ee6..9433e40 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -559,10 +559,10 @@ int activate_lv_excl(struct cmd_context *cmd, struct logical_volume *lv)
 		return 1;
 
 	/* FIXME Deal with error return codes. */
-	if (activate_lv_excl_remote(cmd, lv))
-		stack;
+	if (!activate_lv_excl_remote(cmd, lv))
+		return_0;
 
-	return lv_is_active_exclusive(lv);
+	return 1;
 }
 
 /* Lock a list of LVs */



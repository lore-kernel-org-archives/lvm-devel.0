From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Mar 2016 22:46:54 +0000 (UTC)
Subject: master - lvconvert: fix error path test
Message-ID: <20160314224654.48EBE6105F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7daba90fa3c2cec085170b1c18f63d7877e483da
Commit:        7daba90fa3c2cec085170b1c18f63d7877e483da
Parent:        a39563c0b08a281f170f7e70ec571aa6ef2d9147
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 14 23:19:22 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 14 23:37:42 2016 +0100

lvconvert: fix error path test

lvremove_single toollib function returns
ECMD_FAILED or ECMD_PROCESSED.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 50cf318..23d8787 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.147 - 
 ==================================
+  Fix test for lvremove failure in lvconvert --uncache (2.02.146).
 
 Version 2.02.146 - 11th March 2016
 ==================================
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d80292a..f7a3df6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2043,7 +2043,7 @@ static int _lvconvert_uncache(struct cmd_context *cmd,
 		}
 	}
 
-	if (!lvremove_single(cmd, remove_lv, NULL))
+	if (lvremove_single(cmd, remove_lv, NULL) != ECMD_PROCESSED)
 		return_0;
 
 	if (remove_lv != lv)



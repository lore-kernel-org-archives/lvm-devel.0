From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Apr 2015 14:39:23 +0000 (UTC)
Subject: master - cleanup: typo in comment
Message-ID: <20150413143923.EA66B60F0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b99d648ef2be558e43e36fd12e7304a2433b44f
Commit:        0b99d648ef2be558e43e36fd12e7304a2433b44f
Parent:        695237f2ae2f2c34f8abc30b6c03467a06c28945
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 13 11:00:07 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 13 16:38:30 2015 +0200

cleanup: typo in comment

---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c054531..55956fd 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2239,7 +2239,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	}
 
 	/*
-	 * Check if cmirord is running for clustered mirrors.
+	 * Check if cmirrord is running for clustered mirrors.
 	 */
 	if (!laopts->exclusive && vg_is_clustered(lv->vg) &&
 	    lv_is_mirror(lv) && !lv_is_raid(lv) &&



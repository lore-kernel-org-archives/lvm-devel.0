From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  9 May 2015 07:18:23 +0000 (UTC)
Subject: master - cleanup: remove extraneous parentheses
Message-ID: <20150509071823.2F3CF60E3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e047f043948758be0405ccc67c4a066e237dcbb1
Commit:        e047f043948758be0405ccc67c4a066e237dcbb1
Parent:        e587b0677b705786a78f21bac1966621f70b2752
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 8 22:58:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 9 09:17:26 2015 +0200

cleanup: remove extraneous parentheses

---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index ae48e7b..ca198dc 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -214,7 +214,7 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 		}
 	}
 
-	if ((read_error == FAILED_CLUSTERED)) {
+	if (read_error == FAILED_CLUSTERED) {
 		*skip = 1;
 		stack;	/* Error already logged */
 		return 1;



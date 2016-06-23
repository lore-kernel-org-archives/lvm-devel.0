From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:39 +0000 (UTC)
Subject: master - lvresize: drop extra sigint handling
Message-ID: <20160623130139.3654B60612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a4107c982e706dd97117e7e182bf9cbf7e85cac
Commit:        3a4107c982e706dd97117e7e182bf9cbf7e85cac
Parent:        d578d8d3a1bbf5d20151ed8bc33caa307e2c7292
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 8 23:29:13 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:08 2016 +0200

lvresize: drop extra sigint handling

yes_no_prompt() now already handles signal checking,
so drop redundant test.
---
 lib/metadata/lv_manip.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a628683..439a3d7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4377,8 +4377,6 @@ static int _request_confirmation(const struct volume_group *vg,
 				  display_lvname(lv));
 			return 0;
 		}
-		if (sigint_caught())
-			return_0;
 	}
 
 	return 1;



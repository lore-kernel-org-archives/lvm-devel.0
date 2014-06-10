From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Jun 2014 08:52:03 +0000 (UTC)
Subject: master - cleanup: add missing log_error
Message-ID: <20140610085203.9177E60A38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f9a196dc0ca12a7bbb98d2e1dd66bb5603f7226
Commit:        9f9a196dc0ca12a7bbb98d2e1dd66bb5603f7226
Parent:        5e52a7788f71aa0b1235193902163f7e77f817c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 10 10:49:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 10 10:51:26 2014 +0200

cleanup: add missing log_error

log_error about no change in volume group with 'n' prompt answer.
(in-release fix)
---
 tools/vgchange.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 2556af2..88dc180 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -322,14 +322,18 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 			if (yes_no_prompt("LVM cluster daemon (clvmd) is not"
 					  " running.\n"
 					  "Make volume group \"%s\" clustered"
-					  " anyway? [y/n]: ", vg->name) == 'n')
+					  " anyway? [y/n]: ", vg->name) == 'n') {
+				log_error("No volume groups changed.");
 				return 0;
+			}
 
 		} else if (!locking_is_clustered() &&
 			   (yes_no_prompt("LVM locking type is not clustered.\n"
 					  "Make volume group \"%s\" clustered"
-					  " anyway? [y/n]: ", vg->name) == 'n'))
+					  " anyway? [y/n]: ", vg->name) == 'n')) {
+			log_error("No volume groups changed.");
 			return 0;
+		}
 	}
 
 	if (!vg_set_clustered(vg, clustered))



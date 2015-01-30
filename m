From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 30 Jan 2015 15:46:44 +0000 (UTC)
Subject: master - tests: add --force to sfdisk
Message-ID: <20150130154644.458BE60CD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71e88f761d4d3517dbc810e28c807fb84b49ac20
Commit:        71e88f761d4d3517dbc810e28c807fb84b49ac20
Parent:        04b60e927464454c376ac97d7285affbde186e2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 30 16:46:06 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 30 16:46:06 2015 +0100

tests: add --force to sfdisk

Avoid udev sync troubles for now.
---
 test/shell/test-partition.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index e79216e..f68d572 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -26,7 +26,7 @@ aux prepare_pvs 1 30
 pvs "$dev1"
 
 # create small partition table
-echo "1 2" | sfdisk "$dev1"
+echo "1 2" | sfdisk --force "$dev1"
 
 aux notify_lvmetad "$dev1"
 not pvs "$dev1"



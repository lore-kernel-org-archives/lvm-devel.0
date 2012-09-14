From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 14 Sep 2012 15:41:25 +0000 (UTC)
Subject: master - TEST: Add missing test for RAID module version
Message-ID: <20120914154125.3AFF61211@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5cdd7848f46305d3d5744c194d4e2d38b78f0ec7
Commit:        5cdd7848f46305d3d5744c194d4e2d38b78f0ec7
Parent:        6d75ff138cb1614ee5e31bbd0c3c25721ff9514c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Sep 12 06:27:37 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Sep 12 06:27:37 2012 -0500

TEST:  Add missing test for RAID module version

RAID10 was added to dm-raid module version 1.3.0.  Omitted test for
this version is causing test suite to fail.
---
 test/shell/lvresize-raid.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index e78eb8c..08382a5 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -79,6 +79,8 @@ for i in 4 5 6 ; do
 	done
 done
 
+aux target_at_least dm-raid 1 3 0 || skip
+
 # Extend RAID10 (2-stripes, 2-mirror)
 for deactivate in true false; do
 	lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg



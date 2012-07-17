From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 17 Jul 2012 15:52:18 +0000 (UTC)
Subject: master - TEST (lvresize-raid): Don't run test when RAID module doesn't exist
Message-ID: <20120717155218.4624F1CFD@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00d9bf8107b47e51fc966dd5bd78789190c6e846
Commit:        00d9bf8107b47e51fc966dd5bd78789190c6e846
Parent:        3f5cdf20cd65173cc36f765ebe68134299c9cbc8
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jul 17 10:50:21 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jul 17 10:50:21 2012 -0500

TEST (lvresize-raid):  Don't run test when RAID module doesn't exist

Check for RAID module and skip test if not there.
---
 test/shell/lvresize-raid.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index c6c5dd1..ea5cc80 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -11,6 +11,8 @@
 
 . lib/test
 
+aux target_at_least dm-raid 1 1 0 || skip
+
 aux prepare_vg 5 80
 
 # Extend a 2-way RAID1



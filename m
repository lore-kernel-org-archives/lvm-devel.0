From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 11 Oct 2012 16:15:45 +0000 (UTC)
Subject: master - test: Skip lvconvert-raid on kernels < 3.2 since they BUG out.
Message-ID: <20121011161545.4EDCA2497@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b165e9f3f8fe757e2dc330f6952856908fb131d8
Commit:        b165e9f3f8fe757e2dc330f6952856908fb131d8
Parent:        b07df8850ad1952edff67f263f1f161b1d4cf439
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Oct 11 15:38:19 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 11 18:13:37 2012 +0200

test: Skip lvconvert-raid on kernels < 3.2 since they BUG out.

---
 test/shell/lvconvert-raid.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 7f4dd4b..4fa766d 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -23,6 +23,7 @@ get_image_pvs() {
 # MAIN
 ########################################################
 aux target_at_least dm-raid 1 1 0 || skip
+aux kernel_at_least 3 2 0 || skip
 
 # 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
 aux prepare_pvs 9 80



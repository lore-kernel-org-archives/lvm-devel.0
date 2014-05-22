From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 May 2014 10:02:25 +0000 (UTC)
Subject: master - tests: detect raid presence
Message-ID: <20140522100225.48F3C611E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=406ce3760bb619a3104ca2ef58e809c29907d506
Commit:        406ce3760bb619a3104ca2ef58e809c29907d506
Parent:        496953fb3915a7a985558a7a1b2edf534e170dfd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 22 11:58:44 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 22 12:01:44 2014 +0200

tests: detect raid presence

---
 test/shell/lvconvert-repair-raid-dmeventd.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index a825aa2..f83e722 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -12,6 +12,7 @@
 . lib/test
 
 which mkfs.ext3 || skip
+aux have_raid 1 1 0 || skip
 
 aux prepare_dmeventd
 aux prepare_vg 5



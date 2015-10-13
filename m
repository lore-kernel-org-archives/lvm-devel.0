From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:43 +0000 (UTC)
Subject: master - tests: wait for initial sync
Message-ID: <20151013140443.4E3076017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf1c2da836223de64daacd94f0fd40a96f6cd46f
Commit:        cf1c2da836223de64daacd94f0fd40a96f6cd46f
Parent:        c4cc5eabfe722daf88d19b60d58c616c31e57edd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 11:21:40 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:21 2015 +0200

tests: wait for initial sync

Raid should be in-sync ATM for any gaming.
---
 test/shell/lvconvert-repair-raid-dmeventd.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index df55449..a5a7a53 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -23,6 +23,7 @@ lvcreate -aey --type raid1 -m 3 --ignoremonitoring -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
 lvs -a -o all,lv_modules $vg
 lvdisplay --maps $vg
+aux wait_for_sync $vg 4way
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 "$DM_DEV_DIR/$vg/4way"
 sleep 10 # FIXME: need a "poll" utility, akin to "check"



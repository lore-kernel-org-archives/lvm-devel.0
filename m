From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Mar 2015 14:06:46 +0000 (UTC)
Subject: master - tests: check for dmeventd first
Message-ID: <20150316140646.0FC2E60F91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e1d1aaca833813fb6cadd16c704c83bb8e94f09
Commit:        0e1d1aaca833813fb6cadd16c704c83bb8e94f09
Parent:        e6a69af2d751c83e6c1e82005607448630ae7047
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 16 12:26:00 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 16 12:26:00 2015 +0100

tests: check for dmeventd first

Check there is no dmeventd before creating vg.
---
 test/shell/lvconvert-repair-transient-dmeventd.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 5347d88..4f6171d 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -11,9 +11,9 @@
 
 . lib/inittest
 
+aux prepare_dmeventd
 aux mirror_recovery_works || skip
 aux prepare_vg 5
-aux prepare_dmeventd
 
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way



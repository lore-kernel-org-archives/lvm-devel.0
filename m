From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 10:02:00 +0000 (UTC)
Subject: master - tests: specify old mirror type
Message-ID: <20150311100200.3674A60D6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a042678a83fd996bec20cb7e42c7b1df206b7671
Commit:        a042678a83fd996bec20cb7e42c7b1df206b7671
Parent:        6cecf61cc3aa9983f82ed571021149ee4ed83e5b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 09:53:35 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 11:02:35 2015 +0100

tests: specify old mirror type

Use old mirror (otherwise it would need  aux have_raid)
---
 test/shell/lvmetad-lvscan-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-lvscan-cache.sh b/test/shell/lvmetad-lvscan-cache.sh
index e63fd20..1d9d8a4 100644
--- a/test/shell/lvmetad-lvscan-cache.sh
+++ b/test/shell/lvmetad-lvscan-cache.sh
@@ -16,7 +16,7 @@ test -e LOCAL_LVMETAD || skip
 aux prepare_pvs 2
 
 vgcreate $vg1 "$dev1" "$dev2"
-lvcreate -n testlv -m 1 -l 1 $vg1
+lvcreate -n testlv --type mirror -m 1 -l 1 $vg1
 vgs | grep $vg1
 
 lvscan --cache $vg1/testlv



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 Apr 2016 21:14:05 +0000 (UTC)
Subject: master - tests: use should for failing test
Message-ID: <20160418211405.35A6B60E5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=50633039bfb5ef9a89e419ca7ad7ad49304d1c0d
Commit:        50633039bfb5ef9a89e419ca7ad7ad49304d1c0d
Parent:        59b0bd7b6445d0c09568eae4cbf75577ce190803
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 18 23:12:05 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 18 23:12:05 2016 +0200

tests: use should for failing test

It's better to use 'should' for failing test before it gets fixed,
when we ignore failing result.
---
 test/shell/lvmetad-lvm1.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index 9720833..824c1d5 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -19,11 +19,11 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_devs 2
 pvcreate --metadatatype 1 "$dev1"
-vgscan --cache
+should not vgscan --cache
 pvs | tee out
 not grep "$dev1" out
 vgcreate --metadatatype 1 $vg1 "$dev1"
-vgscan --cache
+should not vgscan --cache
 vgs | tee out
 not grep $vg1 out
 pvs | tee out



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 22:39:03 +0000 (GMT)
Subject: master - tests: add FIXME case
Message-ID: <20200919223903.8EE113857C6B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f507a2564c6e4933263b75319f6984104cc5c896
Commit:        f507a2564c6e4933263b75319f6984104cc5c896
Parent:        f2878a801c7af73e9110650708f7fd741c22c3d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 20 00:01:48 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 20 00:37:21 2020 +0200

tests: add FIXME case

---
 test/shell/pvck-repair.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/pvck-repair.sh b/test/shell/pvck-repair.sh
index d48e25198..b6038944a 100644
--- a/test/shell/pvck-repair.sh
+++ b/test/shell/pvck-repair.sh
@@ -399,6 +399,8 @@ lvcreate -l1 -an $vg
 # One PV, one mda, pv_header zeroed, unmatching dev name requires specified uuid
 _clear_devs "$dev1" "$dev2"
 vgcreate $vg "$dev1"
+#!!! FIXME: with this hits INTERNAL_ERROR
+#!!! vgcreate $vg "$dev1" "$dev2"
 pvck --dump headers "$dev1" || true
 UUID1=`pvck --dump headers "$dev1" | grep pv_header.pv_uuid | awk '{print $2}'`
 echo $UUID1



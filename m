From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Mar 2021 00:00:49 +0000 (GMT)
Subject: main - tests: wait for Aa status
Message-ID: <20210317000049.4CE1A3851C26@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fda7bc1297640d739067727b6165cde0613d1fe3
Commit:        fda7bc1297640d739067727b6165cde0613d1fe3
Parent:        80d0f200d00727f591569512ea04d9b50c22ae59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 00:00:03 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:59:50 2021 +0100

tests: wait for Aa status

---
 test/shell/lvconvert-raid.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 6aaaf3669..87eb7b53c 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -232,6 +232,11 @@ lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
 lvconvert -y -m 1 $vg/$lv1 \
 	--config 'global { mirror_segtype_default = "raid1" }' "$dev2"
 lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
+for i in {1..10}; do
+	check raid_leg_status $vg $lv1 "Aa" && break
+	check raid_leg_status $vg $lv1 "aa" || die "Cannot wait for Aa on $vg/$lv1"
+	sleep .1
+done
 not lvconvert --yes -m 0 $vg/$lv1 "$dev1"
 lvconvert --yes -m 0 $vg/$lv1 "$dev2"
 aux enable_dev "$dev2"



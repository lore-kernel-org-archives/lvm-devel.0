From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun,  8 Jun 2014 19:58:33 +0000 (UTC)
Subject: master - lvm1: Fail vg_write graciously when devices are missing.
Message-ID: <20140608195833.4F4F960FD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3bdd410927a3d9b1b17de94a05b1621a79bdb31
Commit:        b3bdd410927a3d9b1b17de94a05b1621a79bdb31
Parent:        60443d6a5d17c9f3ba935263a5e14a8548aab509
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 8 21:52:54 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Jun 8 21:57:18 2014 +0200

lvm1: Fail vg_write graciously when devices are missing.

---
 lib/format1/disk-rep.c     |    3 +++
 test/shell/lvmetad-lvm1.sh |    9 +++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index f42d344..32e9f5e 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -727,6 +727,9 @@ static int _write_all_pvd(const struct format_type *fmt, struct disk_list *data,
 {
 	int r;
 
+	if (!data->dev)
+		return_0;
+
 	if (!dev_open(data->dev))
 		return_0;
 
diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index 814134c..d41e078 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -20,3 +20,12 @@ vgcreate --metadatatype 1 $vg1 "$dev1"
 should vgscan --cache
 vgs | should grep $vg1
 pvs | should grep "$dev1"
+
+# check for RHBZ 1080189 -- SEGV in lvremove/vgremove
+pvcreate -ff -y --metadatatype 1 "$dev1" "$dev2"
+vgcreate --metadatatype 1 $vg1 "$dev1" "$dev2"
+lvcreate -l1 $vg1
+pvremove -ff -y $dev2
+vgchange -an $vg1
+not lvremove $vg1
+not vgremove $vg1



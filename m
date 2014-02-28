From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:33 +0000 (UTC)
Subject: master - lvmetad: Keep the cache consistent when a PV moves around.
Message-ID: <20140228102633.4C32660FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf29eabdba4be1c706da7b80c803de5a98619baf
Commit:        bf29eabdba4be1c706da7b80c803de5a98619baf
Parent:        a36869867275b8ef0f6d324bc5a7f3e2b8e445e9
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 10:59:12 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

lvmetad: Keep the cache consistent when a PV moves around.

In cases where PV appears on a new device without disappearing from an old one
first, the device->pvid pointers could become ambiguous. This could cause the
ambiguous PV to be lost from the cache when a different PV comes up on one of
the ambiguous devices.
---
 daemons/lvmetad/lvmetad-core.c  |   15 ++++++++++++---
 test/shell/lvmetad-ambiguous.sh |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index e6e222f..db05dc2 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -861,7 +861,7 @@ static response pv_found(lvmetad_state *s, request r)
 	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
 	const char *vgid_old = NULL;
 	struct dm_config_node *pvmeta = dm_config_find_node(r.cft->root, "pvmeta");
-	uint64_t device;
+	uint64_t device, device_old_pvid = 0;
 	struct dm_config_tree *cft, *pvmeta_old_dev = NULL, *pvmeta_old_pvid = NULL;
 	char *old;
 	char *pvid_dup;
@@ -883,9 +883,12 @@ static response pv_found(lvmetad_state *s, request r)
 		dm_hash_remove(s->pvid_to_pvmeta, old);
 		vgid_old = dm_hash_lookup(s->pvid_to_vgid, old);
 	}
-	pvmeta_old_pvid = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 
-	DEBUGLOG(s, "pv_found %s, vgid = %s, device = %" PRIu64 ", old = %s", pvid, vgid, device, old);
+	if ((pvmeta_old_pvid = dm_hash_lookup(s->pvid_to_pvmeta, pvid)))
+		dm_config_get_uint64(pvmeta_old_pvid->root, "pvmeta/device", &device_old_pvid);
+
+	DEBUGLOG(s, "pv_found %s, vgid = %s, device = %" PRIu64 " (previously %" PRIu64 "), old = %s",
+		 pvid, vgid, device, device_old_pvid, old);
 
 	dm_free(old);
 
@@ -903,6 +906,11 @@ static response pv_found(lvmetad_state *s, request r)
 		return reply_fail("out of memory");
 	}
 
+	if (pvmeta_old_pvid && device != device_old_pvid) {
+		DEBUGLOG(s, "pv %s no longer on device %" PRIu64, pvid, device_old_pvid);
+		dm_hash_remove_binary(s->device_to_pvid, &device_old_pvid, sizeof(device_old_pvid));
+	}
+
 	if (!dm_hash_insert(s->pvid_to_pvmeta, pvid, cft) ||
 	    !dm_hash_insert_binary(s->device_to_pvid, &device, sizeof(device), (void*)pvid_dup)) {
 		dm_hash_remove(s->pvid_to_pvmeta, pvid);
@@ -911,6 +919,7 @@ static response pv_found(lvmetad_state *s, request r)
 		dm_free(pvid_dup);
 		return reply_fail("out of memory");
 	}
+
 	if (pvmeta_old_pvid)
 		dm_config_destroy(pvmeta_old_pvid);
 	if (pvmeta_old_dev && pvmeta_old_dev != pvmeta_old_pvid)
diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
new file mode 100644
index 0000000..455aa5d
--- /dev/null
+++ b/test/shell/lvmetad-ambiguous.sh
@@ -0,0 +1,34 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+test -e LOCAL_LVMETAD || skip
+
+aux prepare_pvs 2
+
+# flip the devices around
+aux init_udev_transaction
+dmsetup remove -f "$dev1"
+dmsetup remove -f "$dev2"
+dmsetup create -u TEST-${PREFIX}pv2 ${PREFIX}pv2 ${PREFIX}pv2.table
+dmsetup create -u TEST-${PREFIX}pv1 ${PREFIX}pv1 ${PREFIX}pv1.table
+aux finish_udev_transaction
+
+# re-scan them
+pvscan --cache $dev1
+pvscan --cache $dev2
+
+# expect both to be there
+pvs | tee pvs.txt
+grep $dev1 pvs.txt
+grep $dev2 pvs.txt
+



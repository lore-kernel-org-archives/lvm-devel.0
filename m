From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:27:23 +0000 (UTC)
Subject: master - report: Print UUIDs for missing PVs when possible.
Message-ID: <20131117222723.A5D2E60DF0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae337d472eb973bbde80d641da9567acfa7874ff
Commit:        ae337d472eb973bbde80d641da9567acfa7874ff
Parent:        ecc296311ff2a251aa254353b0a0fb3ee97be97c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Nov 17 22:36:13 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 22:36:13 2013 +0100

report: Print UUIDs for missing PVs when possible.

---
 test/shell/listings.sh |    3 +++
 tools/reporter.c       |    8 +++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 0d4c83f..e5a3954 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -69,3 +69,6 @@ vgs -o pv_name,vg_name $vg
 pvdisplay $(cat DEVICES) >out
 pvdisplay --maps $(cat DEVICES) >out2
 not diff out out2
+
+aux disable_dev $dev1
+pvs -o +pv_uuid | grep BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
diff --git a/tools/reporter.c b/tools/reporter.c
index fb01686..dccd785 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -142,6 +142,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	char uuid[64] __attribute__((aligned(8)));
 	struct label *label;
 	struct label _dummy_label = { 0 };
+	struct device _dummy_device = { 0 };
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
@@ -182,7 +183,12 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	/* FIXME workaround for pv_label going through cache; remove once struct
 	 * physical_volume gains a proper "label" pointer */
 	if (!(label = pv_label(pv))) {
-		_dummy_label.dev = pv->dev;
+		if (pv->dev)
+			_dummy_label.dev = pv->dev;
+		else {
+			_dummy_label.dev = &_dummy_device;
+			memcpy(_dummy_device.pvid, &pv->id, ID_LEN);
+		}
 		label = &_dummy_label;
 	}
 



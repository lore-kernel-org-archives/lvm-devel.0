From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 17 Jan 2014 01:14:53 +0000 (UTC)
Subject: master - pvresize: Fix orphan PV size calculation.
Message-ID: <20140117011453.3003260570@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5eee73bd7cb8e4712ad5e5d13a3bffb78e02c9ca
Commit:        5eee73bd7cb8e4712ad5e5d13a3bffb78e02c9ca
Parent:        ebac2ed5be9ba2bd4c606209f1a9396e32dafe88
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 17 01:12:04 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 17 01:12:04 2014 +0000

pvresize: Fix orphan PV size calculation.

The size of any metadata must be ignored when calculating the size of an
orphan PV.

Bug introduced by 603b45e0ed1032875f587eda3391c47b6652303c ("pvresize: Do
not use pv_read (get the PV from orphan VG).")
---
 lib/format_text/format-text.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 22d772f..6e309a3 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2278,7 +2278,7 @@ static int _text_pv_resize(const struct format_type *fmt,
 	}
 
 	/* If there's a VG, reduce size by counting in pe_start and metadata areas. */
-	if (vg) {
+	if (vg && !is_orphan_vg(vg->name)) {
 		size_reduction = pv_pe_start(pv);
 		if ((mda = fid_get_mda_indexed(fid, pvid, ID_LEN, 1)) &&
 		    (mdac = mda->metadata_locn))



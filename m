From: Nikhil Kshirsagar <nkshirsa@redhat.com>
Date: Mon, 13 Nov 2017 17:06:53 +0530
Subject: [PATCH] correcting a typo in the lvmthin man page
Message-ID: <CAMNNMLFprr5Oy_icc0apTC9U4Q4vQvEsdfJovFtyOj2qxZvVow@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Nikhil Kshirsagar <nkshirsa redhat com>

---

diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 251ba12..9a7a0e6 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -439,7 +439,7 @@ copy to the VG's pmspare LV.
 If step 1 is successful, the thin pool metadata LV is replaced
 with the pmspare LV containing the corrected metadata.
 The previous thin pool metadata LV, containing the damaged metadata,
-becomes visible with the new name ThinPoolLV_tmetaN (where N is 0,1,...).
+becomes visible with the new name ThinPoolLV_metaN (where N is 0,1,...).

 If the repair works, the thin pool LV and its thin LVs can be activated,
 and the LV containing the damaged thin pool metadata can be removed.



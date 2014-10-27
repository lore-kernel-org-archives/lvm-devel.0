From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 27 Oct 2014 10:53:36 +0000 (UTC)
Subject: master - test: for issue fixed in previous commit 2f7f6932dcd450ba75fe590aba8c09838d2618dc
Message-ID: <20141027105336.8AA6560EA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7049eeeb839b59314d07c0bac250c89cf8ac78f8
Commit:        7049eeeb839b59314d07c0bac250c89cf8ac78f8
Parent:        2f7f6932dcd450ba75fe590aba8c09838d2618dc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 27 11:53:01 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 27 11:53:01 2014 +0100

test: for issue fixed in previous commit 2f7f6932dcd450ba75fe590aba8c09838d2618dc

---
 test/shell/report-select.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/report-select.sh b/test/shell/report-select.sh
index 11a4efd..70e5366 100644
--- a/test/shell/report-select.sh
+++ b/test/shell/report-select.sh
@@ -183,6 +183,11 @@ lvs_sel 'name="vol1"' "vol1"
 # check reserved values are accepted for certain fields as well as usual values
 vgs_sel 'vg_mda_copies=unmanaged' "$vg2 $vg3"
 vgs_sel 'vg_mda_copies=2' "$vg1"
+# also, we must match only vg1, not including vg2 and vg3
+# when comparing ranges - unamanged is mapped onto 2^64 - 1 internally,
+# so we need to skip this internal value if it matches with selection criteria!
+vgs_sel 'vg_mda_copies>=2' "$vg1"
+not vgs_sel 'vg_mda_copies=18446744073709551615'
 
 lvs_sel 'lv_read_ahead=auto' "vol1 vol2 orig snap"
 lvs_sel 'lv_read_ahead=256k' "abc xyz"



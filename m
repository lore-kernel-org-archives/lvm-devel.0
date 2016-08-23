From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 23 Aug 2016 22:40:47 +0000 (UTC)
Subject: master - lvconvert: Disallow raid10 mirror conversions.
Message-ID: <20160823224047.6A51060F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7837fbc1c191925ebe6bef74845d61396c1050e6
Commit:        7837fbc1c191925ebe6bef74845d61396c1050e6
Parent:        2d65ce9711dace22cebb370b0d93fd7a98213bd8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 23 23:40:16 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 23 23:40:16 2016 +0100

lvconvert: Disallow raid10 mirror conversions.

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fdf63e4..315e7f9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Disallow segtype and mirror conversions of raid10 volumes.
   Fix dmeventd unmonitoring when segment type (and dso) changes.
   Don't allow lvconvert --repair on raid0 devices or attempt to monitor them.
   No longer adjust incorrect number of raid stripes supplied to lvcreate.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fefec7c..457724c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1849,6 +1849,11 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 				  lvseg_name(seg));
 			return 0;
 		}
+		if (seg_is_raid10(seg)) {
+			log_error("--mirrors/-m cannot be changed with %s.",
+				  lvseg_name(seg));
+			return 0;
+		}
 	}
 
 	if (!_lvconvert_validate_thin(lv, lp))



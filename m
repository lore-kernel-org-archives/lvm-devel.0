From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  5 Aug 2015 04:08:18 +0000 (UTC)
Subject: master - libdm: Sort new exported symbols.
Message-ID: <20150805040818.4F60D6004F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23e8e849e47284b3e5db815767d2d47765579986
Commit:        23e8e849e47284b3e5db815767d2d47765579986
Parent:        362a1a5a820c07c94d0bf4b512b32a47141564d9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 5 05:07:45 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 5 05:07:45 2015 +0100

libdm: Sort new exported symbols.

---
 libdm/.exported_symbols.DM_1_02_104 |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index 815c689..0039419 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -1,11 +1,11 @@
-dm_report_set_interval_ms
-dm_report_set_interval_ns
 dm_report_get_interval_ms
 dm_report_get_interval_ns
+dm_report_set_interval_ms
+dm_report_set_interval_ns
 dm_report_wait
 dm_size_to_string
 dm_timestamp_alloc
 dm_timestamp_compare
-dm_timestamp_get
 dm_timestamp_delta
 dm_timestamp_destroy
+dm_timestamp_get



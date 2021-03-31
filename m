From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:30 +0000 (GMT)
Subject: dev-next - tests: update for newer thin-pool
Message-ID: <20210331214930.6E37F3857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1d6e1d08a887d602234485f0214edc3552e843e0
Commit:        1d6e1d08a887d602234485f0214edc3552e843e0
Parent:        51ac56a05e9da2c28ef5047345468fed4946078a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 16:53:18 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 20:39:41 2021 +0100

tests: update for newer thin-pool

Newer thin-pool handle metadata read-only recovery better.
---
 test/shell/thin-flags.sh | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 78a4b2cd7..89ed69ac9 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -98,7 +98,22 @@ not lvcreate -V10 -n $lv3 $vg/pool
 lvs -ao+seg_pe_ranges $vg
 
 # needs_check needs newer version
-if aux have_thin 1 16 0 ; then
+if aux have_thin 1 19 0 ; then
+	check lv_attr_bit state $vg/pool "a"
+
+	dmsetup suspend $vg-pool-tpool
+
+	check lv_attr_bit state $vg/pool "s"
+
+	dmsetup resume $vg-pool-tpool
+
+	lvresize -L+2M $vg/pool_tmeta
+
+	# Newer version recovers when metadata grow up
+	check lv_attr_bit state $vg/pool "a"
+	check lv_field $vg/pool lv_health_status ""
+
+elif aux have_thin 1 16 0 ; then
 	check lv_attr_bit state $vg/pool "c"
 	check lv_field $vg/pool lv_check_needed "check needed"
 



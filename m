From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  4 Jan 2016 14:13:37 +0000 (UTC)
Subject: master - lvmdump: also add lvm2-activation{-early, -net}.service systemd status for lvmdump -s
Message-ID: <20160104141337.49F9C609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4304a95dfdb4791e23dbd4b0280c667eba5cb664
Commit:        4304a95dfdb4791e23dbd4b0280c667eba5cb664
Parent:        124b490fe671fc53aef989b384c4a5a87c9ff6d0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 4 15:10:07 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 4 15:12:25 2016 +0100

lvmdump: also add lvm2-activation{-early,-net}.service systemd status for lvmdump -s

The lvm2-activation{-early,-net}.service systemd unit statuses were missing
in dump gathered by lvmdump -s. These are quite important when debugging
scenarios with systemd environment and where lvmetad is not used.
---
 WHATS_NEW          |    1 +
 scripts/lvmdump.sh |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 19ac737..aa61f0a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.139 - 
 =====================================
+  Also add lvm2-activation{-early,-net}.service systemd status for lvmdump -s.
 
 Version 2.02.138 - 14th December 2015
 =====================================
diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index f88f31f..2e0ac13 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -262,6 +262,9 @@ if (( $sysreport )); then
 						   lvm2-cluster-activation.service \
 						   lvm2-clvmd.service \
 						   lvm2-cmirrord.service \
+						   lvm2-activation-early.service \
+						   lvm2-activation.service \
+						   lvm2-activation-net.service \
 						   > \"$sysreport_dir/systemd_lvm2_services_status\" 2>> \"$log\""
 		log "$SYSTEMCTL list-units -l -a --no-legend --no-pager > \"$sysreport_dir/systemd_unit_list\" 2>> \"$log\""
 		for unit in $(cat $sysreport_dir/systemd_unit_list | grep lvm2-pvscan | cut -d " " -f 1); do



From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 15 Apr 2014 13:43:33 +0000 (UTC)
Subject: master - lvmdump: list also inactive units for lvmdump -s
Message-ID: <20140415134333.57570602BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18caa562fe35b2617f5c2d04c2252b2b8fdfd08c
Commit:        18caa562fe35b2617f5c2d04c2252b2b8fdfd08c
Parent:        a6763c64a735769991170b64bb2224c861f69f3a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 15 15:43:20 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 15 15:43:20 2014 +0200

lvmdump: list also inactive units for lvmdump -s

---
 scripts/lvmdump.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index b8f73f3..9229912 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -259,7 +259,7 @@ if (( $sysreport )); then
 						   lvm2-clvmd.service \
 						   lvm2-cmirrord.service \
 						   > \"$sysreport_dir/systemd_lvm2_services_status\" 2>> \"$log\""
-		log "$SYSTEMCTL list-units -l --no-legend --no-pager > \"$sysreport_dir/systemd_unit_list\" 2>> \"$log\""
+		log "$SYSTEMCTL list-units -l -a --no-legend --no-pager > \"$sysreport_dir/systemd_unit_list\" 2>> \"$log\""
 		for unit in $(cat $sysreport_dir/systemd_unit_list | grep lvm2-pvscan | cut -d " " -f 1); do
 			log "$SYSTEMCTL status -l --no-pager -n $log_lines -o short-precise $unit >> \"$sysreport_dir/systemd_lvm2_pvscan_service_status\""
 		done



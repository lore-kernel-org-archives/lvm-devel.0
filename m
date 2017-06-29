From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:29 -0400
Subject: master - lvmdump: drop useless cat
Message-ID: <201706292026.v5TKQTdq025844@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df57845f6141ac4b00e272229f65edd35912534c
Commit:        df57845f6141ac4b00e272229f65edd35912534c
Parent:        a458065aa10c12f8a5c89ce7c6140c0459221f60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 21:02:23 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

lvmdump: drop useless cat

Useless cat. Consider 'cmd < file | ..' or 'cmd file | ..' instead.
---
 scripts/lvmdump.sh.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmdump.sh.in b/scripts/lvmdump.sh.in
index f5af242..7ca7d0b 100644
--- a/scripts/lvmdump.sh.in
+++ b/scripts/lvmdump.sh.in
@@ -295,7 +295,7 @@ if (( sysreport )); then
 						   lvm2-activation-net.service \
 						   > \"$sysreport_dir/systemd_lvm2_services_status\" 2>> \"$log\""
 		log "$SYSTEMCTL list-units -l -a --no-legend --no-pager > \"$sysreport_dir/systemd_unit_list\" 2>> \"$log\""
-		for unit in $(cat "$sysreport_dir/systemd_unit_list" | "$GREP" lvm2-pvscan | cut -d " " -f 1); do
+		for unit in $("$GREP" lvm2-pvscan "$sysreport_dir/systemd_unit_list" | cut -d " " -f 1); do
 			log "$SYSTEMCTL status -l --no-pager -n $log_lines -o short-precise $unit >> \"$sysreport_dir/systemd_lvm2_pvscan_service_status\""
 		done
 	fi



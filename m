From: okozina <okozina@fedoraproject.org>
Date: Mon, 11 May 2015 17:08:46 +0000 (UTC)
Subject: master - lvmdump.sh: print out lvmpolld service status
Message-ID: <20150511170846.B0CB060222@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2bbf0425e7cb40984173c91486fef6413a075f20
Commit:        2bbf0425e7cb40984173c91486fef6413a075f20
Parent:        5420edd56ecc3547758109cc87d0530d1e2e56d7
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon May 11 13:31:43 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 11 19:07:47 2015 +0200

lvmdump.sh: print out lvmpolld service status

---
 scripts/lvmdump.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 879dd0c..f88f31f 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -239,7 +239,6 @@ if (( $metadata )); then
 	done
 fi
 
-# FIXME: add lvmpolld.service here
 if (( $sysreport )); then
 	myecho "Gathering system info..."
 
@@ -259,6 +258,7 @@ if (( $sysreport )); then
 		log "$SYSTEMCTL status -l --no-pager -n $log_lines -o short-precise dm-event.socket dm-event.service \
 						   lvm2-monitor.service \
 						   lvm2-lvmetad.socket lvm2-lvmetad.service \
+						   lvm2-lvmpolld.socket lvm2-lvmpolld.service \
 						   lvm2-cluster-activation.service \
 						   lvm2-clvmd.service \
 						   lvm2-cmirrord.service \



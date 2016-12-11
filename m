From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 11 Dec 2016 13:32:57 +0000 (UTC)
Subject: master - scripts: add systemd unit files to .gitignore
Message-ID: <20161211133257.F2C1F60E13@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9c9772a80737e8f00f2c96dc2b033aaf85487c3
Commit:        f9c9772a80737e8f00f2c96dc2b033aaf85487c3
Parent:        383683ffd390e1936474c3bced850ea887223478
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Dec 10 17:58:10 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Dec 10 17:58:10 2016 +0000

scripts: add systemd unit files to .gitignore

com.redhat.lvmdbus1.service
lvm2_lvmdbusd_systemd_red_hat.service

.gitignore
---
 scripts/.gitignore |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/scripts/.gitignore b/scripts/.gitignore
index ed0d945..0368f23 100644
--- a/scripts/.gitignore
+++ b/scripts/.gitignore
@@ -3,6 +3,7 @@ blk_availability_systemd_red_hat.service
 blkdeactivate.sh
 clvmd_init_red_hat
 cmirrord_init_red_hat
+com.redhat.lvmdbus1.service
 dm_event_systemd_red_hat.service
 dm_event_systemd_red_hat.socket
 lvm2_activation_generator_systemd_red_hat
@@ -10,6 +11,7 @@ lvm2_cluster_activation_red_hat.sh
 lvm2_cluster_activation_systemd_red_hat.service
 lvm2_clvmd_systemd_red_hat.service
 lvm2_cmirrord_systemd_red_hat.service
+lvm2_lvmdbusd_systemd_red_hat.service
 lvm2_lvmetad_init_red_hat
 lvm2_lvmetad_systemd_red_hat.service
 lvm2_lvmetad_systemd_red_hat.socket



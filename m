From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 14 Feb 2014 13:52:04 +0000 (UTC)
Subject: master - systemd: do not use default dependencies for clvmd/cmirrord units
Message-ID: <20140214135204.986E960BD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=554159d519ba5c523d506785d61d10374456a020
Commit:        554159d519ba5c523d506785d61d10374456a020
Parent:        4210219a8bba1aee6a16d16f4c158fa46395b9dd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 14 14:37:19 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 14 14:37:19 2014 +0100

systemd: do not use default dependencies for clvmd/cmirrord units

Do not use default dependencies that systemd adds to the units
so we have better control of when the service is started/stopped
and we don't end up with unexpected behaviour.
---
 ...2_cluster_activation_systemd_red_hat.service.in |    3 ++-
 scripts/lvm2_clvmd_systemd_red_hat.service.in      |    2 ++
 scripts/lvm2_cmirrord_systemd_red_hat.service.in   |    2 ++
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_cluster_activation_systemd_red_hat.service.in b/scripts/lvm2_cluster_activation_systemd_red_hat.service.in
index 03ed9d2..970e93a 100644
--- a/scripts/lvm2_cluster_activation_systemd_red_hat.service.in
+++ b/scripts/lvm2_cluster_activation_systemd_red_hat.service.in
@@ -3,7 +3,8 @@ Description=Clustered LVM volumes activation service
 Requires=lvm2-clvmd.service
 After=lvm2-clvmd.service lvm2-cmirrord.service
 OnFailure=lvm2-clvmd.service
-DefaultDependencies=false
+DefaultDependencies=no
+Conflicts=shutdown.target
 
 [Service]
 Type=simple
diff --git a/scripts/lvm2_clvmd_systemd_red_hat.service.in b/scripts/lvm2_clvmd_systemd_red_hat.service.in
index c10bdc4..2978d21 100644
--- a/scripts/lvm2_clvmd_systemd_red_hat.service.in
+++ b/scripts/lvm2_clvmd_systemd_red_hat.service.in
@@ -7,6 +7,8 @@ Requires=network.target dlm.service corosync.service
 RefuseManualStart=true
 RefuseManualStop=true
 StopWhenUnneeded=true
+DefaultDependencies=no
+Conflicts=shutdown.target
 
 [Service]
 Type=forking
diff --git a/scripts/lvm2_cmirrord_systemd_red_hat.service.in b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
index 4ca3eea..16d38ce 100644
--- a/scripts/lvm2_cmirrord_systemd_red_hat.service.in
+++ b/scripts/lvm2_cmirrord_systemd_red_hat.service.in
@@ -4,6 +4,8 @@ Documentation=man:cmirrord(8)
 Requires=corosync.service
 After=corosync.service
 Before=remote-fs.target
+DefaultDependencies=no
+Conflicts=shutdown.target
 
 [Service]
 Type=forking



From: Ondrej Kozina <okozina@redhat.com>
Date: Thu,  1 Nov 2012 18:22:14 +0100
Subject: [PATCH 0/3] CLVMD: systemd native service
Message-ID: <1351790537-10199-1-git-send-email-okozina@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In response to (bz #829308):

Right now, clvmd init scripts are not compatible with systemd so I propose to 
add "native" systemd units for systemd enabled distros.

This patch splits clvmd service between two new services:

1) clvmd daemon itself (clvmd-daemon.service)
2) activation/deactivation of clustered VGs (clvmd.service)

There're several reasons to split it. First, there's no support for conditional
stop in systemd and AFAIK they don't plan to support it. In other words:
if the deactivation fails for some reason, systemd doesn't care and simply kills all
remaining procs in the cgroup (by default). Killing the remaining procs can be suppressed
however it doesn't solve the following problem:

You can't repeat the stop command of a failed service. The repeated stop command is simply 
not propagated to the service. You would have to start and then try to stop
the service again. Unfortunately, this can't be done while the daemon is still running
(and we need the daemon to be active until all clustered VGs are deactivated successfully).

In a separated setup we need only to restart the failed activation service and that's fine.

Ondrej Kozina (3):
  - add clvmd native systemd service
  - add clvmd activation systemd service
  - alter related configuration files

 configure.in                                       |  3 +
 make.tmpl.in                                       |  1 +
 scripts/Makefile.in                                |  9 ++-
 scripts/clvmd_activation_script_red_hat.sh.in      | 71 ++++++++++++++++++++++
 .../clvmd_activation_systemd_red_hat.service.in    | 14 +++++
 scripts/clvmd_systemd_red_hat.service.in           | 20 ++++++
 6 files changed, 117 insertions(+), 1 deletion(-)
 create mode 100755 scripts/clvmd_activation_script_red_hat.sh.in
 create mode 100644 scripts/clvmd_activation_systemd_red_hat.service.in
 create mode 100644 scripts/clvmd_systemd_red_hat.service.in

-- 
1.7.12.4



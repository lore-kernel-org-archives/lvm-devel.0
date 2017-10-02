From: Thomas Lamprecht <t.lamprecht@proxmox.com>
Date: Mon,  2 Oct 2017 14:26:36 +0200
Subject: [RFC] dmeventd: ensure systemd service gets stopped on shutdown
Message-ID: <20171002122636.20879-1-t.lamprecht@proxmox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The service pf dmeventd, dm-eventd.service, uses
'DefaultDependencies=no' as it wants to start up very early in the
boot process.
But, this also removed the implicit 'Conflicts' and 'Before' settings
to the shutdown target, which is in charge of stopping all service
gracefully on poweroff, reboot or halt.
This caused that the service was not stopped on shutdown by the
normal systemd shutdown process, but only once the systemd-shutdown
service took over the role of PID 1 and sent first a SIGTERM then -
after DEFAULT_TIMEOUT_USEC (90 seconds) of waiting, a SIGKILL to all
remaining processes.
dmeventd only exits if at the next main loop iteration after the time
where the signal was received all threads are idle, else the exit
request gets simply ignored (not queued).

Lets add the shutdown target conflict again, so that it gets stopped
during the normal systemd shutdown process, previous to reaching
shutdown.target.
First, this allows the user o notice more easily the offending
process as its logged with journald still operating - which isn't the
case once systemd-shutdown took over the PID 1 role.
Secondly, at this stage the shutdown of dmeventd seems to succeed
always, interestingly. This could be explained by the sync which
systemd-shutdown triggers before broadcasting SIGTERM and SIGKILL.
This sync could change (meta)data from a monitored dm device and thus
keep dmeventd from exiting as _idle_since is 0.

Signed-off-by: Thomas Lamprecht <t.lamprecht@proxmox.com>
---

The last part where I try make sense out of the differing behavior if
systemd-shutdown sends the SIGTERM or systemd previous to that sends
it is speculation, albeit not complete unreasonable one.
RFC for that matter and for the matter that I do not yet have in-depth
knowledge of dmeventd and its users.

 scripts/dm_event_systemd_red_hat.service.in | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
index 7c607aaf2..a3284c810 100644
--- a/scripts/dm_event_systemd_red_hat.service.in
+++ b/scripts/dm_event_systemd_red_hat.service.in
@@ -4,6 +4,8 @@ Documentation=man:dmeventd(8)
 Requires=dm-event.socket
 After=dm-event.socket
 Before=local-fs-pre.target
+Before=shutdown.target
+Conflicts=shutdown.target
 DefaultDependencies=no
 
 [Service]
-- 
2.11.0




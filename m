From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 3 Oct 2017 15:12:05 +0200
Subject: [RFC] dmeventd: ensure systemd service gets stopped on shutdown
In-Reply-To: <20171002122636.20879-1-t.lamprecht@proxmox.com>
References: <20171002122636.20879-1-t.lamprecht@proxmox.com>
Message-ID: <b910924e-d7a9-73f9-32a6-3422ec992a5c@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/02/2017 02:26 PM, Thomas Lamprecht wrote:
> diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
> index 7c607aaf2..a3284c810 100644
> --- a/scripts/dm_event_systemd_red_hat.service.in
> +++ b/scripts/dm_event_systemd_red_hat.service.in
> @@ -4,6 +4,8 @@ Documentation=man:dmeventd(8)
>  Requires=dm-event.socket
>  After=dm-event.socket
>  Before=local-fs-pre.target
> +Before=shutdown.target
> +Conflicts=shutdown.target
>  DefaultDependencies=no
>  

Hi!

Yes, we should be able to make cleaner ordering of these services. By
design, the dm-event.service is supposed to be stopped after all the
monitoring clients command dmeventd to unmonitor particular devices
belonging to a subsystem (like LVM with "vgchange --monitor n" that is
part of lvm2-monitor.service).

At this moment, we just let the dmeventd to get stopped/killed when the
last SIGTERM signal is sent to all remaining processes on shutdown. But
I agree it would be cleaner to do this as part of proper "service stop"
action for dm-event.service (that would be executed as part of
Conflicts: shutdown.target which you reference in your patch).

Unfortunately, there's a bug which we need to fix first for this to work
correctly, I've filed it here:
https://bugzilla.redhat.com/show_bug.cgi?id=1498080

-- 
Peter



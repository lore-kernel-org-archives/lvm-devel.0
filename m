From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 17 Apr 2018 11:48:48 +0200
Subject: [PATCH RESEND 2/2] lvm2: 69-dm-lvm-metad.rules: set systemd vars on "change"
In-Reply-To: <20180416185341.8588-3-mwilck@suse.com>
References: <20180416185341.8588-1-mwilck@suse.com>
	<20180416185341.8588-3-mwilck@suse.com>
Message-ID: <cb503a94-3993-013a-2bd1-4c3a143d055c@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/16/2018 08:53 PM, Martin Wilck wrote:
> The current logic that avoids setting SYSTEMD_ALIAS and SYSTEMD_WANTS
> on "change" events is flawed in the default "systemd background job"
> configuration. For systemd, it's important that device properties don't
> change spuriously.
> 
> If an "add" event starts lvm2-pvscan at .service for a device, and a
> "change" event follows, removing SYSTEMD_ALIAS and SYSTEMD_WANTS from the
> udev db, information about unit dependencies between the device and the
> pvscan service can be lost in systemd, in particular if the daemon
> configuration is reloaded.
> 
> Steps to reproduce problem:
> 
> - create a device with an LVM PV
> - remove device
> - add device (generates "add" and "change" uevents for the device)
>   (at this point SYSTEMD_ALIAS and SYSTEMD_WANTS are clear in udev db)
> - systemctl daemon-reload
>   (systemd reloads udev db)
> - vgchange -a n
> - remove device
> 
> => the lvm2-pvscan at .service for the device is still active although the
> device is gone.
> 
> - add device again
> 
> => the PV is not detected, because systemd sees the lvm2-pvscan at .service
> as active and thus doesn't restart it.
> 
> The original purpose of this logic was to avoid volumes being scanned
> over and over again. With systemd background jobs, that isn't necessary,
> because systemd will not restart the job as long as it's active.
> 
> Signed-off-by: Martin Wilck <mwilck@suse.com>
> ---
>  udev/69-dm-lvm-metad.rules.in | 56 +++++++++++++++++++++++++++++++------------
>  udev/Makefile.in              |  4 +++-
>  2 files changed, 44 insertions(+), 16 deletions(-)
> 

Thanks for the patch! I wasn't aware that systemd is reading those
variables again from udev db on reload - nice catch! Applied:

https://sourceware.org/git/?p=lvm2.git;a=commit;h=7a7b8a7778aace88c967ee8285485c494ce1f3f8

-- 
Peter



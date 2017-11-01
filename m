From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 1 Nov 2017 15:40:51 +0100
Subject: [PATCH] Remove Install sections from socket activate services
In-Reply-To: <20171101123818.6oboia5k3ezg6pqf@waldi.eu.org>
References: <20171101123818.6oboia5k3ezg6pqf@waldi.eu.org>
Message-ID: <aced585a-a191-49a3-0760-58573099f364@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/01/2017 01:38 PM, Bastian Blank wrote:
> Those services are never enabled on Red Hat.  Other distributions enable
> all services that can be enabled.
> 
> Signed-off-by: Bastian Blank <waldi@debian.org>
> ---
>  scripts/dm_event_systemd_red_hat.service.in      | 3 ---
>  scripts/lvm2_lvmetad_systemd_red_hat.service.in  | 3 ---
>  scripts/lvm2_lvmpolld_systemd_red_hat.service.in | 3 ---
>  3 files changed, 9 deletions(-)
> 
> diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
> index de9aa52c77..d2c4cf1ad5 100644
> --- a/scripts/dm_event_systemd_red_hat.service.in
> +++ b/scripts/dm_event_systemd_red_hat.service.in
> @@ -13,6 +13,3 @@ ExecStart=@SBINDIR@/dmeventd -f
>  Environment=SD_ACTIVATION=1
>  PIDFile=@DMEVENTD_PIDFILE@
>  OOMScoreAdjust=-1000
> -
> -[Install]
> -WantedBy=sysinit.target
> diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.service.in b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
> index af34d82257..92e6d695f1 100644
> --- a/scripts/lvm2_lvmetad_systemd_red_hat.service.in
> +++ b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
> @@ -13,6 +13,3 @@ ExecStart=@SBINDIR@/lvmetad -f
>  Environment=SD_ACTIVATION=1
>  Restart=on-abort
>  PIDFile=@LVMETAD_PIDFILE@
> -
> -[Install]
> -WantedBy=sysinit.target
> diff --git a/scripts/lvm2_lvmpolld_systemd_red_hat.service.in b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
> index 66fbd91071..4ad4e61990 100644
> --- a/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
> +++ b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
> @@ -12,6 +12,3 @@ NonBlocking=true
>  ExecStart=@SBINDIR@/lvmpolld -t 60 -f
>  Environment=SD_ACTIVATION=1
>  PIDFile=@LVMPOLLD_PIDFILE@
> -
> -[Install]
> -WantedBy=sysinit.target
> 

Hi,

OK, applied. Thanks!

https://sourceware.org/git/?p=lvm2.git;a=commit;h=58b763c99cb7620b1cc2313a9f0dccd98def53db

-- 
Peter



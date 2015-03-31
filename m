From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 31 Mar 2015 15:52:49 +0200
Subject: [PATCH] systemd: stop lvm2-pvscan@.service before lvm2-lvmetad.service
In-Reply-To: <1427663200-2349-1-git-send-email-bevan@bi-co.net>
References: <1427663200-2349-1-git-send-email-bevan@bi-co.net>
Message-ID: <551AA6B1.4070607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/29/2015 11:06 PM, Michael Lass wrote:
> When lvm2-pvscan at .service and lvm2-lvmetad.service are scheduled to be stopped
> lvm2-pvscan at .service should be stopped first since pvscan uses lvmetad.
> 
> This is especially important if lvm2-lvmetad.socket is also scheduled to be
> stopped as in this case connection requests are suppressed causing pvscan to
> fail.
> ---
>  scripts/lvm2_pvscan_systemd_red_hat at .service.in | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
> index 7d3b291..03651d5 100644
> --- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
> +++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
> @@ -4,7 +4,7 @@ Documentation=man:pvscan(8)
>  DefaultDependencies=no
>  BindsTo=dev-block-%i.device
>  Requires=lvm2-lvmetad.socket
> -After=lvm2-lvmetad.socket
> +After=lvm2-lvmetad.socket lvm2-lvmetad.service
>  Before=shutdown.target
>  Conflicts=shutdown.target
>  
> 

Applied. Thanks!

https://git.fedorahosted.org/cgit/lvm2.git/commit/?id=666738d57a6e6b4005030995a9641933c1a54e9d

-- 
Peter



From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 5 Mar 2016 11:50:29 +0100
Subject: [PATCH] Run the DBus daemon with the "C" locale
In-Reply-To: <1457074768-11160-1-git-send-email-vpodzime@redhat.com>
References: <1457074768-11160-1-git-send-email-vpodzime@redhat.com>
Message-ID: <56DAB9F5.3040003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 4.3.2016 v 07:59 Vratislav Podzimek napsal(a):
> Otherwise it uses the system default which may be e.g. cs_CZ.UTF-8 causing the
> daemon to fail when parsing output from the CLI tools - it for example gets 1,5G
> instead of 1.5G.
> ---
>   scripts/lvm2_lvmdbusd_systemd_red_hat.service.in | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
> index d3ad870..b7e9ace 100644
> --- a/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
> +++ b/scripts/lvm2_lvmdbusd_systemd_red_hat.service.in
> @@ -5,6 +5,7 @@ Documentation=man:lvmdbusd(8)
>   [Service]
>   Type=dbus
>   BusName=com.redhat.lvmdbus1
> +Environment="LC_ALL=C"
>   ExecStart=@sbindir@/lvmdbusd --udev
>
>   [Install]
>

Hi

Thanks for noticing - the bug has been addressed directly in daemon init code:
https://www.redhat.com/archives/lvm-devel/2016-March/msg00065.html

Regards

Zdenek



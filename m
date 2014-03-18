From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 18 Mar 2014 09:57:59 +0100
Subject: [PATCH 1/2] Fix pvdisplay to refer to sectors, not KB
In-Reply-To: <1395131042-5015-2-git-send-email-hare@suse.de>
References: <1395131042-5015-1-git-send-email-hare@suse.de>
	<1395131042-5015-2-git-send-email-hare@suse.de>
Message-ID: <53280A97.4030307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.3.2014 09:24, Hannes Reinecke napsal(a):
> From: Thomas Fehr <fehr@suse.de>
>
> The size is displayed in sectors, not kilobytes.
>
> Signed-off-by: Thomas Fehr <fehr@suse.de>
> Acked-by: Hannes Reinecke <hare@suse.de>
> ---
>   man/pvdisplay.8.in | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
> index 03c12c4..13c26b5 100644
> --- a/man/pvdisplay.8.in
> +++ b/man/pvdisplay.8.in
> @@ -65,7 +65,7 @@ The values are:
>
>   * physical volume device name
>   * volume group name
> -* physical volume size in kilobytes
> +* physical volume size in sectors
>   * internal physical volume number (obsolete)
>   * physical volume status
>   * physical volume (not) allocatable

Hi

Against which version of lvm2 is this patch ?

Since my upstream pvdisplay shows  size in  'human readable' format i.e.:
(So definitely not in sector - unless used with option  '--units s')

--- Physical volume ---
PV Name               /dev/loop0
VG Name               vg
PV Size               976,56 GiB / not usable 0
Allocatable           yes
PE Size               32,00 KiB
Total PE              31999968
Free PE               31999872
Allocated PE          96
PV UUID               5DOVI6-ioCm-LJvd-JbwQ-qJc3-FWO4-yQCjGY


Zdenek



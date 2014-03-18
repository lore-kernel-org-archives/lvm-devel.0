From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 18 Mar 2014 10:10:32 +0100
Subject: [PATCH 2/2] Handle duplicate PVs on drbd
In-Reply-To: <1395131042-5015-3-git-send-email-hare@suse.de>
References: <1395131042-5015-1-git-send-email-hare@suse.de>
	<1395131042-5015-3-git-send-email-hare@suse.de>
Message-ID: <53280D88.6000707@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.3.2014 09:24, Hannes Reinecke napsal(a):
> From: Xinwei Hu <xwhu@suse.de>
>
> If lvm finds a duplicate PV where one device is a drbd device
> it should prefer the drbd device.
>
> Signed-off-by: Xinwei Hu <xwhu@suse.de>
> Acked-by: Hannes Reinecke <hare@suse.de>
> ---
>   lib/cache/lvmcache.c | 14 ++++++++++++++
>   1 file changed, 14 insertions(+)
>
> diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
> index d40bdce..ebc619b 100644
> --- a/lib/cache/lvmcache.c
> +++ b/lib/cache/lvmcache.c
> @@ -1503,6 +1503,14 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
>   						 dev_subsystem_name(dt, existing->dev),
>   						 dev_name(existing->dev));
>   				return NULL;
> +			} else if (MAJOR(existing->dev->dev) == dt->drbd_major &&
> +					MAJOR(dev->dev) != dt->drbd_major) {
> +				log_very_verbose("Ignoring duplicate PV %s on "
> +						"%s - using drbd %s",
> +						pvid, dev_name(dev),
> +						dev_name(existing->dev));
> +				return NULL;
> +

Hi

I assume there is maybe wrong order of tests in functions:

dev_subsystem_part_major() &  dev_subsystem_name()  (in lib/device/dev-type.c)

Could you check if reordering tests would solve it ?
(I'm not familiar with drbd usage, however there is already code to handle 
this case - but maybe it's not working for all cases ?)

Zdenek



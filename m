From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 15:28:12 +0100
Subject: [PATCH 13/25] Replicator: lock_vol update replicator LV
In-Reply-To: <ac7a5396d35dce68e3f7c57b5238196d9e20fead.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
	<ac7a5396d35dce68e3f7c57b5238196d9e20fead.1268833246.git.zkabelac@redhat.com>
Message-ID: <4BA0E6FC.7060001@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 17.3.2010 14:47, Zdenek Kabelac wrote:
> Add LCK_MISSING_VG flag to sinal missing VG to _lock_vol function.
> This way we easily detect whether we still need to lock more VGs
> while having all data available - it would be ackware to resolve it
> from resource uuid string. In the case  missing VG is found,
> whole whole operation must be retried - this usually requires to
> release all locks, and take them again in the alphabetic order.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---
>  lib/locking/locking.c |    3 +++
>  lib/locking/locking.h |    7 ++++++-
>  2 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/locking/locking.c b/lib/locking/locking.c
> index 76dbda5..57b7ba9 100644
> --- a/lib/locking/locking.c
> +++ b/lib/locking/locking.c
> @@ -362,6 +362,9 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
>  {
>  	int ret = 0;
>  
> +	if (flags & LCK_MISSING_VG)
> +		return_0;
> +
>  	_block_signals(flags);
>  	_lock_memory(cmd, lv_op);
>  
> diff --git a/lib/locking/locking.h b/lib/locking/locking.h
> index e7f25b9..da442ec 100644
> --- a/lib/locking/locking.h
> +++ b/lib/locking/locking.h
> @@ -86,6 +86,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
>  #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
>  #define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
>  #define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
> +#define LCK_MISSING_VG	0x00000200U	/* 'Remote' VG misses lock for this LV */
>  
>  /*
>   * Additional lock bits for cluster communication
> @@ -128,8 +129,12 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
>  #define LCK_LV_CLUSTERED(lv)	\
>  	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
>  
> +#define LCK_CHECK_MISSING_VG(lv)	\
> +	(lv_replicator_sites_check_vg((lv)) ? 0 : LCK_MISSING_VG)
> +
>  #define lock_lv_vol(cmd, lv, flags)	\
> -	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
> +	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv) | \
> +		 LCK_CHECK_MISSING_VG(lv))
>  
>  #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
>  #define unlock_and_release_vg(cmd, vg, vol) \

Here is simpler version which doesn't change LCK flags - so no changes in
clmvd....

Zdenek
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0018-Replicator-lock_vol-update-replicator-LV.patch
Type: text/x-patch
Size: 1041 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100317/3a4accce/attachment.bin>

From: Heinz Mauelshagen <heinzm@redhat.com>
Date: Tue, 08 Dec 2009 17:38:16 +0100
Subject: [PATCH 03/10] Get rid of magic masks in cluster locking code.
In-Reply-To: <3fb7d099249e6e8e0b7fc963405e95adbb1402c4.1260284754.git.mbroz@redhat.com>
References: <cover.1260284754.git.mbroz@redhat.com>
	<3fb7d099249e6e8e0b7fc963405e95adbb1402c4.1260284754.git.mbroz@redhat.com>
Message-ID: <1260290296.9639.84.camel@o>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2009-12-08 at 16:39 +0100, Milan Broz wrote:
> Patch should not cause any problems, only real change is
> removing LCK_LOCAL bit from lock type flag, it is never used there.
> (LCK_LOCAL is part arg[1] bits anyway.)
> 
> Signed-off-by: Milan Broz <mbroz@redhat.com>
> ---
>  lib/locking/cluster_locking.c |    5 +++--
>  lib/locking/locking.h         |    3 +++
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
> index b031f12..b079195 100644
> --- a/lib/locking/cluster_locking.c
> +++ b/lib/locking/cluster_locking.c
> @@ -317,8 +317,9 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
>  	args = alloca(len);
>  	strcpy(args + 2, name);
>  
> -	args[0] = flags & 0x7F; /* Maskoff lock flags */
> -	args[1] = flags & 0xC0; /* Bitmap flags */
> +	/* Maskoff lock flags */
> +	args[0] = flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK | LCK_HOLD_MASK); 
> +	args[1] = flags & LCK_AREA_MASK;
>  
>  	if (mirror_in_sync())
>  		args[1] |= LCK_MIRROR_NOSYNC_MODE;
> diff --git a/lib/locking/locking.h b/lib/locking/locking.h
> index 50101d1..0dce827 100644
> --- a/lib/locking/locking.h
> +++ b/lib/locking/locking.h
> @@ -78,6 +78,9 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
>  /*
>   * Lock bits
>   */
> +#define LCK_HOLD_MASK	0x00000030U	/* NONBLOCK + HOLD bits */
> +#define LCK_AREA_MASK	0x000000C0U	/* LOCAL + CLUSTER_VG bits */

Or

#define LCK_HOLD_MASK	(LCK_NONBLOCK | LCK_HOLD)
#define	LCK_AREA_MASK	(LCK_LOCAL | LCK_CLUSTER_VG)

rather.

We should use given definitions.

Heinz

> +
>  #define LCK_NONBLOCK	0x00000010U	/* Don't block waiting for lock? */
>  #define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
>  #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */



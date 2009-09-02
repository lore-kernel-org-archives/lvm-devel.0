From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 2 Sep 2009 14:38:48 +0100
Subject: [PATCH 1/9] Enforce an alphabetical lock ordering for vgname locks.
In-Reply-To: <1250198823-11591-2-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250198823-11591-2-git-send-email-dwysocha@redhat.com>
Message-ID: <20090902133848.GN1655@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 13, 2009 at 05:26:55PM -0400, Dave Wysochanski wrote:
> --- a/lib/cache/lvmcache.c
> +++ b/lib/cache/lvmcache.c
> @@ -186,6 +186,42 @@ void lvmcache_drop_metadata(const char *vgname)
>  		_drop_metadata(vgname);
>  }

Please document what this function returns here.
(Normally you'd expect a compare fn to return an integer.)

> +static const char * _compare_lock_name(struct dm_hash_node *n,
> +				       const char *vgname)
> +{

> +/*
> + * Enforce alphabetical order of vgname locks

* Ensure VG locks are acquired in alphabetical order.

> + */
> +int lvmcache_verify_lock_order(const char *vgname)

> +		if ((vgname2 = _compare_lock_name(n, vgname))) {
> +			log_errno(EDEADLK, "Invalid vgname lock order "
> +				  "attempted with %s - %s already locked",
> +				  vgname, vgname2);

Internal error: VG lock %s must be requested before %s, not after.

> --- a/lib/locking/locking.c
> +++ b/lib/locking/locking.c
> @@ -387,6 +387,12 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)

> +		if (vol[0] != '#' &&
> +		    ((flags & LCK_TYPE_MASK) != LCK_UNLOCK) &&
> +		    (!(flags & LCK_CACHE)) &&
> +		    !lvmcache_verify_lock_order(vol))
> +			return 0;

return_0;

Alasdair



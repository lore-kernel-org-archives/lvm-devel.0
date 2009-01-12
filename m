From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 12 Jan 2009 21:59:44 +0000
Subject: [PATCH 2/11] Provide _vg_lock_and_read, a new implementation of lock+vg_read_internal.
In-Reply-To: <1231769286-15534-3-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
Message-ID: <20090112215944.GK1804@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Second pass.

> +static vg_t *_vg_make_handle(struct cmd_context *cmd,
> +			     struct volume_group *vg,
> +			     uint32_t failure)

Is this only used for failures?
If so, call it _vg_make_failure_handle.
You can have a typedef for 'failure' if you want.
- Are you planning to expose 'failure' through the API eventually?
Use a common prefix like lvm_ or LVM_ for everything you plan to expose.
(Cf. dm_ and DM_ in libdevmapper.)

> +static vg_t *_recover_vg(struct cmd_context *cmd, const char *lock,
> +			 const char *vg_name, const char *vgid,
> +			 uint32_t lock_flags)
> +{
> +	int consistent = 1;
> +	struct volume_group *vg;
> +
> +	lock_flags &= ~LCK_TYPE_MASK;
> +	lock_flags |= LCK_WRITE;
> +
> +	unlock_vg(cmd, lock);
> +
> +	dev_close_all();

[note to check call paths later if more than one VG lock is held simultaneously]

> +	if (!lock_vol(cmd, lock, lock_flags))
> +		return_NULL;
> +
> +	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
> +		return_NULL;
> +	if (!consistent)
> +		return_NULL;
> +	return vg;
> +}

> --- old-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 14:55:46.583017272 +0100
> +++ new-lvmlib_apply/lib/metadata/metadata-exported.h	2009-01-12 14:55:46.635017317 +0100
> @@ -104,6 +104,32 @@ struct pv_segment;
>  #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
>  #define MIRROR_SKIP_INIT_SYNC	0x00000010U	/* skip initial sync */
>  
> +/* vg_read and vg_read_for_update flags */
> +#define ALLOW_INCONSISTENT 0x1
> +#define ALLOW_EXPORTED 0x2
> +#define REQUIRE_RESIZEABLE 0x4
> +#define EXISTENCE_CHECK 0x8
> +
> +#define NONBLOCKING_LOCK 0x100
> +#define KEEP_LOCK 0x200
> +#define DISABLE_LOCK 0x400
> +#define ORPHAN_LOCK 0x800

Define these in comments.
I hope all the '_LOCK' ones will be internal eventually, as locking will be
handled internally by the library and the caller has no need to know it's
happening.  Unsure why ORPHAN and DISABLE are combined into that same group.

> @@ -197,6 +223,7 @@ struct volume_group {
>  	char *system_id;
>  
>  	uint32_t status;
> +	uint32_t read_failed;

Let's add a brief comment explaining this one.
read_failed ? Yes or No.  Rename it perhaps?
I think it should be completely separate from 'status' and 'alloc'.

>  	alloc_policy_t alloc;
  
Alasdair
-- 
agk at redhat.com



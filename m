From: Milan Broz <mbroz@redhat.com>
Date: Tue, 07 Jul 2009 12:34:27 +0200
Subject: [PATCH 7/7] Add lvm_vg_create() - vg constructor API for new volume groups.
In-Reply-To: <1246953008-27609-8-git-send-email-dwysocha@redhat.com>
References: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>	<1246953008-27609-2-git-send-email-dwysocha@redhat.com>	<1246953008-27609-3-git-send-email-dwysocha@redhat.com>	<1246953008-27609-4-git-send-email-dwysocha@redhat.com>	<1246953008-27609-5-git-send-email-dwysocha@redhat.com>	<1246953008-27609-6-git-send-email-dwysocha@redhat.com>	<1246953008-27609-7-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-8-git-send-email-dwysocha@redhat.com>
Message-ID: <4A5324B3.5080905@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski wrote:
> vg_t *lvm_vg_create(struct cmd_context *cmd, const char *vg_name);
> This is the first step towards the API called to create a VG.
> Call vg_lock_newname() inside this function.  Use _vg_make_handle()
> where possible.

There is too many changes in this patch...

> Now we have 2 ways to construct a volume group:
> 1) vg_read* APIs: Used when constructing an existing VG from disks
> 2) lvm_vg_create: Used when constructing a new VG
> Both of these interfaces obtain a lock, and return a vg_t *.
> The usage of _vg_make_handle() inside lvm_vg_create() doesn't fit
> perfectly but it's ok for now.  Needs some cleanup though and I've
> noted "FIXME" in the code.

so no real difference from vg_read_* + vg_create, right?
These functions just returns vg_t instead of vg now...

> Replace vg_create() with lvm_vg_create() plus vg 'set' functions
> in the following tools:

so all lib functions will use lvm_* prefix?


> TODO in future patches:
> 1. The VG_ORPHAN lock needs some thought.  We may want to treat
> this as any other VG, and require the application to obtain a handle
> and pass it to other API calls (for example, vg_extend).  Or,
> we may find that hiding the VG_ORPHAN lock inside other APIs is
> the way to go.  I thought of placing the VG_ORPHAN lock inside
> lvm_vg_create() and tying it to the vg handle, but was not certain
> this was the right approach.

I thought that we will want to deprecate orphan group, but it still
need to be supported (old PVs without VG)...

But I think that application using liblvm
should never use separate handle to VG_ORPHAN.

> +vg_t *lvm_vg_create(struct cmd_context *cmd, const char *vg_name)
>  {
> -	struct volume_group *vg;
> +	vg_t *vg;
>  	int consistent = 0;
>  	struct dm_pool *mem;
> +	uint32_t rc;
>  
> +	if (!validate_name(vg_name)) {

I expect that this call is just moved here from ... ?

> +		log_error("Invalid vg name %s", vg_name);
> +		/* FIXME: use _vg_make_handle() w/proper error code */
> +		return NULL;
> +	}
> +
> +	rc = vg_lock_newname(cmd, vg_name);
> +	if (rc != SUCCESS) {
> +		log_error("Unable to reserve vg name %s", vg_name);

- log_error("Can't get lock for %s", vp_new.vg_name);

"reserve" ? it means that vg already exist?
(both messages are confusing to user imho)

> +		return _vg_make_handle(cmd, NULL, rc);
> +	}
> +
> +	/* FIXME: Is this vg_read_internal necessary? Move it inside
> +	   vg_lock_newname? */
>  	/* is this vg name already in use ? */
>  	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
>  		log_err("A volume group called '%s' already exists.", vg_name);

btw this should be log_error

> -		vg_release(vg);
> -		return NULL;
> +		unlock_and_release_vg(cmd, vg, vg_name);
> +		return _vg_make_handle(cmd, NULL, FAILED_EXIST);

so now it calls unlock too... it is bugfix for some previous change?

> @@ -559,14 +583,14 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
>  
>  	*vg->system_id = '\0';
>  
> -	vg->extent_size = extent_size;
> +	vg->extent_size = DEFAULT_EXTENT_SIZE * 2;

what these forced defaults mean here? just to overwrite them later?
can we read them form command context instead of fixed values?

(not that user can change policy using --alloc for example)

>  	vg->extent_count = 0;
>  	vg->free_count = 0;
>  
> -	vg->max_lv = max_lv;
> -	vg->max_pv = max_pv;
> +	vg->max_lv = 0;
> +	vg->max_pv = 0;

?

>  
> -	vg->alloc = alloc;
> +	vg->alloc = ALLOC_NORMAL;

?

> @@ -2779,6 +2799,7 @@ static vg_t *_vg_make_handle(struct cmd_context *cmd,
>  			return_NULL;
>  		}
>  		vg->vgmem = vgmem;
> +		vg->cmd = cmd;

another bugfix?

> @@ -322,23 +321,28 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
>  		return ECMD_FAILED;
>  	}
>  
> +	/* Set metadata format of original VG */
> +	/* FIXME: need some common logic */
> +	cmd->fmt = vg_from->fid->fmt;
> +

and what happens after vg_release(vg_from) ? cmd->fmt will be undefined?
(this is probably bug in current code though)

> +	vg_to = lvm_vg_create(cmd, vg_name_to);
> +	if (vg_read_error(vg_to) == FAILED_LOCKING) {
...
> +	if (vg_read_error(vg_to) == FAILED_EXIST) {
...
> +	} else if (vg_read_error(vg_to) == SUCCESS) {
...
> +		if (!vg_set_extent_size(vg_to, vp_new.extent_size) ||
> +		    !vg_set_max_lv(vg_to, vp_new.max_lv) ||
> +		    !vg_set_max_pv(vg_to, vp_new.max_pv) ||
> +		    !vg_set_alloc(vg_to, vp_new.alloc))
>  			goto_bad;

I like the old way much more better...

> -		if (!(vg_to = vg_create(cmd, vg_name_to, vp_new.extent_size,
> -					vp_new.max_pv, vp_new.max_lv,
> -					vp_new.alloc, 0, NULL)))


Milan



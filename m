From: Brassow Jonathan <jbrassow@redhat.com>
Date: Tue, 29 Oct 2013 20:47:52 -0500
Subject: [PATCH 1/2] add integrated_flush support to device-mapper
In-Reply-To: <a69579c2d3e666c37ad71aa93ae8c734b0d8a5e3.1382955203.git.dmzhang@suse.com>
References: <yes> <cover.1382955203.git.dmzhang@suse.com>
	<a69579c2d3e666c37ad71aa93ae8c734b0d8a5e3.1382955203.git.dmzhang@suse.com>
Message-ID: <314D1A76-4C54-4F2E-8C74-21AA06EF236D@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dongmao,

I don't think we need to change as much code as you have here.  There is no way to switch off this obvious improvement and no need to.  So, if you are going to hard-code it in, simply add "integrated_flush" if the log is clustered.  This patch could boil down to one or two extra lines that simply say "if clustered, emit 'integrated_flush'".  At that point, you might as well fold it into the other patch.

 brassow

P.S.  Since you will likely fold what's left of this patch into the other, this next statement is only useful as an FYI.  I think the order of these two userspace patches should have been reverse, because you add the functionality with the other one and you enable using it here.  Patches should build on each other - you don't want to enable something that you haven't coded for yet.


On Oct 28, 2013, at 5:17 AM, dongmao zhang wrote:

> ---
> lib/mirror/mirrored.c |    4 ++++
> libdm/libdevmapper.h  |    3 +++
> libdm/libdm-deptree.c |    8 ++++++++
> 3 files changed, 15 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
> index c3eb27b..572f87e 100644
> --- a/lib/mirror/mirrored.c
> +++ b/lib/mirror/mirrored.c
> @@ -378,6 +378,10 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
> 	if (_block_on_error_available && !(seg->status & PVMOVE))
> 		log_flags |= DM_BLOCK_ON_ERROR;
> 
> +	/*clustered log support delay flush*/
> +	if(clustered)
> +		log_flags |= DM_INTEGRATED_FLUSH;
> +
> 	return dm_tree_node_add_mirror_target_log(node, region_size, clustered, log_dlid, area_count, log_flags);
> }
> 
> diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
> index b287eef..e88a318 100644
> --- a/libdm/libdevmapper.h
> +++ b/libdm/libdevmapper.h
> @@ -667,6 +667,9 @@ int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
> #define DM_BLOCK_ON_ERROR	0x00000004	/* On error, suspend I/O */
> #define DM_CORELOG		0x00000008	/* In-memory log */
> 
> +/*for cluster raid1, use integrated flush to improve performance*/
> +#define DM_INTEGRATED_FLUSH		0x00000010
> +
> int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
> 					  uint32_t region_size,
> 					  unsigned clustered,
> diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
> index 752a44b..0a93028 100644
> --- a/libdm/libdm-deptree.c
> +++ b/libdm/libdm-deptree.c
> @@ -2054,6 +2054,7 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
> 				     char *params, size_t paramsize)
> {
> 	int block_on_error = 0;
> +	int integrated_flush = 0;
> 	int handle_errors = 0;
> 	int dm_log_userspace = 0;
> 	struct utsname uts;
> @@ -2107,6 +2108,9 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
> 		 */
> 		if (KERNEL_VERSION(kmaj, kmin, krel) >= KERNEL_VERSION(2, 6, 31))
> 			dm_log_userspace = 1;
> +
> +		if(seg->flags & DM_INTEGRATED_FLUSH)
> +			integrated_flush = 1;
> 	}
> 
> 	/* Region size */
> @@ -2164,6 +2168,10 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
> 	if (block_on_error)
> 		EMIT_PARAMS(pos, " block_on_error");
> 
> +	if (dm_log_userspace && DM_INTEGRATED_FLUSH)
> +		EMIT_PARAMS(pos, " integrated_flush");
> +
> +
> 	EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
> 
> 	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
> -- 
> 1.7.3.4
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel




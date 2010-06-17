From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 17 Jun 2010 17:15:06 -0500
Subject: [PATCH] Introduce immediate_dev_node flag for dm tree items to support immediate node creation on demand
In-Reply-To: <4C0E371F.5020507@redhat.com>
References: <4C0E371F.5020507@redhat.com>
Message-ID: <2AE2D34D-7A52-4A09-A703-AFD88591DE0A@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Seems like a reasonable solution to the problem we are having.

ACK

  brassow

On Jun 8, 2010, at 7:27 AM, Peter Rajnoha wrote:

> Sometimes we need the nodes to be visible in /dev/mapper even during  
> processing a tree,
> just like we need in case of processing mirrors in clustered  
> environment by cmirror daemon
> (rhbz #568137). Normally, we synchronize with udev and create nodes  
> (as a fallback, if
> udev has not done so yet) at the end of processing the whole tree  
> only.
>
> So let's use a flag (or "load_property") called "immediate_dev_node"  
> for such a dm tree
> node which triggers immediate synchronisation with udev and node  
> creation when needed.
>
> (Unfortunately, this still does not solve the problem with searching  
> the right node
> by comparing the whole /dev/mapper content since we do not have a  
> name provided in
> dm log request sent from kernel which cmirror daemon tries to  
> process.)
>
> Peter
> ---
>
> libdm/libdm-deptree.c |   27 +++++++++++++++++++++++++++
> 1 files changed, 27 insertions(+), 0 deletions(-)
>
> diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
> index e1813b4..38565e5 100644
> --- a/libdm/libdm-deptree.c
> +++ b/libdm/libdm-deptree.c
> @@ -143,6 +143,13 @@ struct load_properties {
> 	struct dm_list segs;
>
> 	const char *new_name;
> +
> +	/* If immediate_dev_node is set to 1, try to create the dev node
> +	 * as soon as possible (e.g. in preload stage even during traversal
> +	 * and processing of dm tree). This will also flush all stacked dev
> +	 * node operations, synchronizing with udev.
> +	 */
> +	int immediate_dev_node;
> };
>
> /* Two of these used to join two nodes with uses and used_by. */
> @@ -1843,6 +1850,7 @@ int dm_tree_preload_children(struct  
> dm_tree_node *dnode,
> 	void *handle = NULL;
> 	struct dm_tree_node *child;
> 	struct dm_info newinfo;
> +	int update_devs_flag = 0;
>
> 	/* Preload children first */
> 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
> @@ -1897,10 +1905,26 @@ int dm_tree_preload_children(struct  
> dm_tree_node *dnode,
>
> 		/* Update cached info */
> 		child->info = newinfo;
> +
> +		/*
> +		 * Prepare for immediate synchronization with udev and flush all  
> stacked
> +		 * dev node operations if requested by immediate_dev_node  
> property. But
> +		 * finish processing current level in the tree first.
> +		 */
> +		if (child->props.immediate_dev_node)
> +			update_devs_flag = 1;
> +
> 	}
>
> 	handle = NULL;
>
> +	if (update_devs_flag) {
> +		if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
> +			stack;
> +		dm_tree_set_cookie(dnode, 0);
> +		dm_task_update_nodes();
> +	}
> +
> 	return r;
> }
>
> @@ -2157,6 +2181,9 @@ int dm_tree_node_add_mirror_target_log(struct  
> dm_tree_node *node,
> 				return 0;
> 			}
>
> +			if (clustered)
> +				log_node->props.immediate_dev_node = 1;
> +
> 			if (!_link_tree_nodes(node, log_node))
> 				return_0;
> 		}
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel



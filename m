From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 20 Nov 2009 23:51:48 +0100
Subject: [PATCH 1/5] libdm-deptree-return-failure-activate-and-preload-children
In-Reply-To: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
References: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
Message-ID: <4B071D84.5060500@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.11.2009 22:29, Mike Snitzer napsal(a):
> Return error immediately to dm_tree_preload_children() and
> dm_tree_activate_children() callers.
> 
> Otherwise resume_lv and its variants can fail silently.
> 
> Catching these failures is especially important now that dm targets like
> crypt and snapshot-merge can fail in .preresume
> 

Similar case applies for replicator - and I'm using similar code in my own
patch set.

So it's definitely needed.

Ack


> Signed-off-by: Mike Snitzer <snitzer@redhat.com>
> ---
>  libdm/libdm-deptree.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
> index 1465fd3..bb10fe5 100644
> --- a/libdm/libdm-deptree.c
> +++ b/libdm/libdm-deptree.c
> @@ -1158,7 +1158,8 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
>  			continue;
>  
>  		if (dm_tree_node_num_children(child, 0))
> -			dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len);
> +			if (!dm_tree_activate_children(child, uuid_prefix, uuid_prefix_len))
> +				return_0;
>  	}
>  
>  	handle = NULL;
> @@ -1204,7 +1205,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
>  				log_error("Unable to resume %s (%" PRIu32
>  					  ":%" PRIu32 ")", child->name, child->info.major,



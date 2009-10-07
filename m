From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 7 Oct 2009 15:39:59 +0100
Subject: [PATCH 02/13] Replicator: add libdm support
In-Reply-To: <1254751240-17431-2-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
Message-ID: <20091007143959.GB3054@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Oct 05, 2009 at 04:00:29PM +0200, Zdenek Kabelac wrote:
>  int dm_tree_suspend_children(struct dm_tree_node *dnode,
> -				   const char *uuid_prefix,
> -				   size_t uuid_prefix_len);
> +			     const char *uuid_prefix,
> +			     size_t uuid_prefix_len,
> +			     int priority);
  
We can't change the published interface like that.

If there really is no alternative to this parameter then you need to introduce
a new function instead.

Alasdair



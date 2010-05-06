From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 6 May 2010 02:55:28 +0100
Subject: [PATCH 05/23] Replicator: suspend/deactivate replicator
In-Reply-To: <b1c4250364861bf2ed2d7bf6a9b157302b8abf56.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
	<b1c4250364861bf2ed2d7bf6a9b157302b8abf56.1272457502.git.zkabelac@redhat.com>
Message-ID: <20100506015528.GN27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 28, 2010 at 02:27:24PM +0200, Zdenek Kabelac wrote:
> Introducing dm_tree_set_suspend_priority() for suspending replicator
> control target before deactivation of replicator-dev target.
 
Not keen on this one - need a bit more information as to why we need this, and
then why the existing function dm_tree_suspend_children() - perhaps extended with an
'inverted' parameter - is insufficient.

> +static int _suspend_parent(struct dm_tree_node *dnode, const char *uuid_prefix,

> +		if (!dlink->node->suspend_priority)
> +			continue;

Why is this hard-coded only to cope with one value of suspend_priority?

Alasdair



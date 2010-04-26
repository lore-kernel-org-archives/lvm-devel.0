From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 14:50:18 +0100
Subject: [PATCH 04/22] Replicator: suspend/deactivate replicator
In-Reply-To: <8cdf29a77f10fb00c32a51fb4cefbb60657a65b7.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<8cdf29a77f10fb00c32a51fb4cefbb60657a65b7.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426135018.GN23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 12, 2010 at 05:21:32PM +0200, Zdenek Kabelac wrote:
> Introducing dm_tree_set_suspend_priority() for suspending replicator
> control target before deactivation of replicator-dev target.
 
Existing code paths are affected by this.

Again, please provide a more-detailed explanation of the new logic and
why it will not break any existing code.

Alasdair



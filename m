From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 2 Feb 2011 19:50:48 +0000
Subject: [PATCHv3 2 of 2]LVM: allow exclusive snapshots in cluster
In-Reply-To: <1296670066.27798.18.camel@hydrogen.msp.redhat.com>
References: <1296670066.27798.18.camel@hydrogen.msp.redhat.com>
Message-ID: <20110202195048.GA14956@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 02, 2011 at 12:07:46PM -0600, Jon Brassow wrote:
> A) the exclusive flag on an LV is lost after the following operations:
> 	1) lvchange -aey vg/lv
> 	2) lvcreate -s -n snap vg/lv
> 	3) lvremove vg/snap
> 	4) lvcreate -s -n snap vg/lv - fails because lv is !EX
> I don't think this is a result of the changes I've made, but an oddity
> that has not been discovered yet.
 
Bug.  Check from the logs at what point the exclusive lock is dropped.
(We fixed bug similar to this before.)

> B) 'vgchange -ay' returns success on only one node (as mbroz
> highlighted) when there are snapshots in a cluster because only one node
> can activate all the LVs.  The other LVs on the remaining nodes still
> activate properly.
 
Bug.
You may have to query the status afterwards to work out the
right return code to use or combine the responses from all the nodes 
intelligently to see that exactly one has it active.
(The node running the command doesn't know what activation filters
might be set on other nodes, so must send the command to every node
but expect exactly one to end up with it active.)

Alasdair



From: David Teigland <teigland@redhat.com>
Date: Wed, 28 Sep 2022 17:00:53 -0500
Subject: [RFC PATCH]lvmlockd: try to adopt the lock resources left in previous lockspace
In-Reply-To: <65215053-904b-356e-fb9a-1b7687aca500@suse.com>
References: <65215053-904b-356e-fb9a-1b7687aca500@suse.com>
Message-ID: <20220928220053.GA27856@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Sep 28, 2022 at 04:58:46PM +0800, Lidong Zhong wrote:
> Hi David,
> 
> Could you share your opinion about this patch please? It's related to the
> patch I sent for resource-agents.
> 
> https://github.com/ClusterLabs/resource-agents/pull/1808
> 
> -----------------------------
> 
> If lvmlockd in cluster is killed accidently or any other reason, the
> lock resources will become orphaned in the VG lockspace. When the
> cluster manager tries to restart this daemon, the LVs will probably
> become inactive because of resource schedule policy and thus the lock
> resouce will be omited during the adoption process. This patch will
> check if the lock is left in previous lockspace and if it matches one
> entry in the adopt file, lvmlockd will also try to adopt it to prevent
> further resource failure.

Hi, I think you're heading in the right direction.  Before looking at the
code changes, could you correct anything I'm missing in this description
of the problem?

1. lvmlock is running
   LVs are active in a shared VG
   the lock manager holds locks for those LV
   the adopt file lists those LVs

2. lvmlockd is killed
   the LV locks are orphaned in the lock manager

3. the LVs are deactivated
   How does this happen?  Does someone run lvchange|vgchange -an?

4. lvmlockd is restarted with the adopt option
   Your patch makes lvmlockd adopt orphan locks in the lock manager
   that have no corresponding active LV.  But, you seem to continue
   holding these adopted LV locks (maybe I'm missing where they are
   released.)  I expect you would want to release these adopted locks
   that have no active LV.

Next, regarding the patch.  You are using debugfs to read all the locks
from the kernel, which works, but it would be nice to avoid this if there
was another method that works as well (since it's meant for debugging.)
Here are a couple options that you might compare with what you've done:

A general statement of the issue you are seeing is mentioned by:
/* FIXME: purge any remaining orphan locks in each rejoined ls? */
Replace that fixme with a call to dlm_ls_purge() which is meant to release
orphan locks.  You'll need the pid of the previous lvmlockd daemon (it's
in the adopt file.)  The purge happens after adopting the orphan locks
that you want to keep locked (those for active LVs.)

Another approach might be to skip remove_inactive_lvs() and attempt to
adopt all locks listed in the adopt file.  You would expect some of the
lock adopt requests to fail (adjust the -ENOENT error handling in
adopt_locks to expect some failures.)  Then unlock the adopted LV locks
that have no active LV.

Dave

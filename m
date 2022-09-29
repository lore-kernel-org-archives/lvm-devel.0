From: Lidong Zhong <lidong.zhong@suse.com>
Date: Thu, 29 Sep 2022 08:59:26 +0800
Subject: [RFC PATCH]lvmlockd: try to adopt the lock resources left in previous lockspace
In-Reply-To: <20220928220053.GA27856@redhat.com>
References: <65215053-904b-356e-fb9a-1b7687aca500@suse.com>
 <20220928220053.GA27856@redhat.com>
Message-ID: <3831aad5-2d8b-63ab-96bb-075297bb0d4c@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi David,

Thanks for your review.

On 9/29/22 06:00, David Teigland wrote:
> On Wed, Sep 28, 2022 at 04:58:46PM +0800, Lidong Zhong wrote:
>> Hi David,
>>
>> Could you share your opinion about this patch please? It's related to the
>> patch I sent for resource-agents.
>>
>> https://github.com/ClusterLabs/resource-agents/pull/1808
>>
>> -----------------------------
>>
>> If lvmlockd in cluster is killed accidently or any other reason, the
>> lock resources will become orphaned in the VG lockspace. When the
>> cluster manager tries to restart this daemon, the LVs will probably
>> become inactive because of resource schedule policy and thus the lock
>> resouce will be omited during the adoption process. This patch will
>> check if the lock is left in previous lockspace and if it matches one
>> entry in the adopt file, lvmlockd will also try to adopt it to prevent
>> further resource failure.
> Hi, I think you're heading in the right direction.  Before looking at the
> code changes, could you correct anything I'm missing in this description
> of the problem?
>
> 1. lvmlock is running
>     LVs are active in a shared VG
>     the lock manager holds locks for those LV
>     the adopt file lists those LVs
>
> 2. lvmlockd is killed
>     the LV locks are orphaned in the lock manager
>
> 3. the LVs are deactivated
>     How does this happen?  Does someone run lvchange|vgchange -an?

In our case, it's cluster resource manager(pacemaker) once notices the 
lvmlockd daemon is down, it

will try to stop all the resources above lvmlockd first, then restart 
lvmlockd and the resources depends

on it.

>
> 4. lvmlockd is restarted with the adopt option
>     Your patch makes lvmlockd adopt orphan locks in the lock manager
>     that have no corresponding active LV.  But, you seem to continue
>     holding these adopted LV locks (maybe I'm missing where they are
>     released.)  I expect you would want to release these adopted locks
>     that have no active LV.

Normally just holding these adopted LV locks should work. One exception 
is after the daemon is dead, LV

will be activated in a different way later. It'll also cause activation 
failure. So releasing these locks makes

sense to me.


>
> Next, regarding the patch.  You are using debugfs to read all the locks
> from the kernel, which works, but it would be nice to avoid this if there
> was another method that works as well (since it's meant for debugging.)
> Here are a couple options that you might compare with what you've done:
>
> A general statement of the issue you are seeing is mentioned by:
> /* FIXME: purge any remaining orphan locks in each rejoined ls? */
> Replace that fixme with a call to dlm_ls_purge() which is meant to release
> orphan locks.  You'll need the pid of the previous lvmlockd daemon (it's
> in the adopt file.)  The purge happens after adopting the orphan locks
> that you want to keep locked (those for active LVs.)
>
> Another approach might be to skip remove_inactive_lvs() and attempt to
> adopt all locks listed in the adopt file.  You would expect some of the
> lock adopt requests to fail (adjust the -ENOENT error handling in
> adopt_locks to expect some failures.)  Then unlock the adopted LV locks
> that have no active LV.

Thanks for the suggestions. I'll rewrite the patch.


Thanks,

Lidong


>
> Dave
>


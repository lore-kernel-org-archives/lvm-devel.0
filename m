From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Wed, 21 Jul 2010 20:58:33 -0400
Subject: [RFC][PATCH] lvm2: limit accesses to broken devices (v2)
In-Reply-To: <20100702133241.GK23989@agk-dp.fab.redhat.com>
References: <5C30BE7ED8B03E448B2E104602D4848A59228864BC@USINDEVS02.corp.hds.com>,
	<20100702133241.GK23989@agk-dp.fab.redhat.com>
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A5922886534@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> On Tue, Jun 29, 2010 at 03:26:15AM -0400, Takahiro Yasui wrote:
> As I mentioned on IRC when you first posted this, my main concern is whether
> this introduces new metadata corruption modes (or makes existing ones more
> likely to cause problems in given circumstances) if the decision about whether
> or not to use a device is per-process and not global (machine and cluster-wide).
>
> Currently the code tries to maintain the list of PVs as a global list which all
> instances of LVM tools share.
> 
> What is proposed here is to start caching the failure information within a
> single process.  But for how long can we safely cache it before revalidating
> it? Can there be races between processes?

To make discussion point simple, let's consider failure information is cached
in the period VG lock is held.

There are two types of VG lock, WRITE and READ. WRITE lock is exclusive
to others and processes work sequentially. This patch won't introduce
races and corrupt metadata, so this patch is safe both for machine and
cluster-wide. 

As to a period of READ VG lock, several processes may run simultaneously
with a different device status. It is possible for the oritinal lvm command
in case that transient error occurs. For example, two processes, p1 and
p2 are running simultaneously and transient errors occured only for
read#1 and #2 issued by p1 but not for read#3 and #4 by p2. p1 thinks
a device is invalid, but p2 thinks the device is valid. If lvm command can't
handle this case, it is a bug of lvm and we need to fix it.

       <--------- READ VG LOCK --------->
p1       <-->                 <-->
           read#1           read#2

             <--------- READ VG LOCK --------->
p2                   <-->                  <-->
                      read#3             read#4

I can say that my patch just extends a period of transient error to a range
of VG lock and I believe that the patch doesn't introduce any new condition.

> For example, how do we cope when bad sectors (or transient I/O failures) cause
> one LVM process to consider a device as missing while another process (using
> different sectors) still thinks it's perfectly OK?
> Shouldn't there be global decisions about this?

As for bad sectors, they cause a permanent error rather than a transient
error and every reads to the sectors will fail. (They could succeed if the
sectors recovered, but we can think the case as a transient error.) Even if
a process might conder a device as missing and another process using
different sectors might think the device is void, both processes should
work properly. The patch doesn't instoruce a new condition, either.

> Perhaps decisions to start ignoring devices should be protected by the existing
> locks: after dropping whichever lock protects the device, the state is reset and
> next time the device is needed it will get retried again.  (In other words the
> scope of the 'stop using this device because there were errors' flag is limited
> to a single transaction - and of course within that transaction the tool could have
> set the MISSING_PV flag to inform other processes to stop using the device.)

It is difficult to use the MISSING_PV flag and haven't found a good solution
yet. The main reason of accessing failed devices a lot of times is scans by
lvmcache_label_scan(). lvm command calls lvmcache_label_scan() a lot of
times and it doesn't use lvm structures such as lv, vg and pv. So I believe
that the MISSING_PV flag is useful to achieve the goal.

I haven't found a bad case with the v2 yet, but limiting the period to cache
failure information to the period of VG lock makes things simple and safer.
I believe that it could be a solution.

I appreciate your comments and other perspectives we should consider.

Thanks,
Taka



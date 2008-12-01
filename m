From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 1 Dec 2008 15:02:15 +0000
Subject: [PATCH] Update vgcreate and vgextend to allow uninitialized devices as input.
In-Reply-To: <1228141197.3256.4.camel@localhost.localdomain>
References: <1228055977.3315.21.camel@localhost.localdomain>
	<1228072273-8119-1-git-send-email-dwysocha@redhat.com>
	<20081130194037.GK13235@agk.fab.redhat.com>
	<1228141197.3256.4.camel@localhost.localdomain>
Message-ID: <20081201150215.GC26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Dec 01, 2008 at 09:19:57AM -0500, Dave Wysochanski wrote:
> vgextend() obtains VG_ORPHAN, then the lock on the vg before calling
> vg_extend().  

Makes sense.

> So if I put pvcreate_devices() logic in there, that calls
> down into pvcreate_single(), which also tries to obtain / release
> VG_ORPHAN.  

So you have two options:
1. an extra parameter on the function to say whether or not the lock
is already held
2. require the lock always to be held before calling that function.

Think of VG_ORPHAN as if it was a real volume group - pvcreate is the
same as vgextend on that volume group and should be calling into
the same code and should already hold the VG lock.

But then you see this:
                unlock_vg(cmd, VG_ORPHANS);

                persistent_filter_wipe(cmd->filter);
                lvmcache_destroy(cmd, 1);

                init_md_filtering(0);
                if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {

and need to worry about *why* the code drops the lock there.

It's probably just for accounting reasons - the cache knows something about
held locks.  IOW (I think) no locks can be held when lvmcache_destroy is
called.  Check that (look at other instances where it's called) then look for
some workaround - a less-drastic destroy function that preserves the state,
perhaps, or splitting the function.

Also note that VG_ORPHANS is set to disappear, replaced by ORPHAN_VG_NAME(fmt).

Alasdair
-- 
agk at redhat.com



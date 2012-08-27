From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Mon, 27 Aug 2012 23:53:37 +0530
Subject: lvm2-api usage in GlusterFS
In-Reply-To: <87boi0vjnz.fsf@in.ibm.com>
References: <87txxnqvok.fsf@in.ibm.com>
	<20120704205749.GN22022@agk-dp.fab.redhat.com>
	<87boi0vjnz.fsf@in.ibm.com>
Message-ID: <87pq6ctcra.fsf@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 24 Aug 2012 12:52:24 +0530, "M. Mohan Kumar" <mohan@in.ibm.com> wrote:
> On Wed, 4 Jul 2012 21:57:49 +0100, Alasdair G Kergon <agk@redhat.com> wrote:
> > On Wed, Jul 04, 2012 at 11:02:11PM +0530, M.Mohan Kumar wrote:
> > > Also other issues with the patch is resizing and creating a snapshot
> > > of LV. There is no API to resize a LV and as of now I am using the
> > 
> > int lvm_lv_resize(const lv_t lv, uint64_t new_size);
> > 
> > "NOTE: This function is currently not implemented."
> > 
> > > Is there any plan to add support to resize a LV and create snapshot of
> > > LV?
> > 
> > Well we're about to start a review of the state of this interface, so if
> > you have any more suggestions, please send them too.
> > 
> 
> It will be great if lvm library supports following interfaces
> 
> 1) lvresize
> 
> 2) lv snapshot creation
> 
> 3) lvrename
> 
> 4) Possible to set some properties per LV, something like gluster may
> set a attribute (for ex: attribute:owner, value:gluster) in each LV
> created by it so that gluster (or who ever created an LV) can filter
> LVs that are not created by gluster (I am just listing one of the use cases)
> 
> 5) Ability to do the full copy of LVs, for example: lv_copy (lv_t dest,
> lv_t source). If its possible to implement in the kernel itself, we can
> avoid user space copying incurred in read/write.
> 
> 6) Ability to provide list of logical blocks and the physical disk for a
> given LV so that these blocks can be given to libStorageManagement tool
> to offload storage operations (such as full cloning a LV)
> 
> 7) Ability to create other targets for example lv library giving
> interface to create a dm-thinpool, dm-thintarget etc.
> 
Hi Alasdair,

Whats your opinion on this request?



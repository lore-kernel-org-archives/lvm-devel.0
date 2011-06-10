From: Joe Thornber <thornber@redhat.com>
Date: Fri, 10 Jun 2011 11:11:43 +0100
Subject: LVM vs. Ext4 snapshots (was: [PATCH v1 00/30] Ext4 snapshots)
In-Reply-To: <alpine.LFD.2.00.1106101101020.4502@dhcp-27-109.brq.redhat.com>
References: <BANLkTimyBGfg4+ovGsiGqpCz345qVmU_7A@mail.gmail.com>
	<BANLkTik20iYN4c9faKD9dzerehazWTwTFw@mail.gmail.com>
	<BANLkTikKRuPu_NX49vr0w-XeN0ZnWo+9vg@mail.gmail.com>
	<alpine.LFD.2.00.1106101101020.4502@dhcp-27-109.brq.redhat.com>
Message-ID: <20110610101142.GA10144@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jun 10, 2011 at 11:01:41AM +0200, Lukas Czerner wrote:
> On Fri, 10 Jun 2011, Amir G. wrote:
> 
> > CC'ing lvm-devel and fsdevel
> > 
> > 
> > On Wed, Jun 8, 2011 at 9:26 PM, Amir G. <amir73il@users.sourceforge.net> wrote:
> > For the sake of letting everyone understand the differences and trade
> > offs between
> > LVM and ext4 snapshots, so ext4 snapshots can get a fair trial, I need
> > to ask you
> > some questions about the implementation, which I could not figure out by myself
> > from reading the documents.

First up let me say that I'm not intending to support writeable
_external_ origins with multisnap.  This will come as a suprise to
many people, but I don't think we can resolve the dual requirements to
efficiently update many, many snapshots when a write occurs _and_ make
those snapshots quick to delete (when you're encouraging people to
take lots of snapshots performance of delete becomes a real issue).

One benefit of this decision is that there is no copying from an
external origin into the multisnap data store.

For internal snapshots (a snapshot of a thin provisioned volume, or
recursive snapshot), copy-on-write does occur.  If you keep the
snapshot block size small, however, you find that this copying can
often be elided since the new data completely overwrites the old.

This avoidance of copying, and the use of FUA/FLUSH to schedule
commits means that performance is much better than the old snaps.  It
wont be as fast as ext4 snapshots, it can't be, we don't know what the
bios contain, unlike ext4.  But I think the performance will be good
enough that many people will be happy with this more general solution
rather than committing to a particular file system.  There will be use
cases where snapshotting at the fs level is the only option.

> > 1. Crash resistance
> > How is multisnap handling system crashes?
> > Ext4 snapshots are journaled along with data, so they are fully
> > resistant to crashes.
> > Do you need to keep origin target writes pending in batches and issue FUA/flush
> > request for the metadata and data store devices?

FUA/flush allows us to treat multisnap devices as if they are devices
with a write cache.  When a FUA/FLUSH bio comes in we ensure we commit
metadata before allowing the bio to continue.  A crash will lose data
that is in the write cache, same as any real block device with a write
cache.

> > 2. Performance
> > In the presentation from LinuxTag, there are 2 "meaningless benchmarks".
> > I suppose they are meaningless because the metadata is linear mapping
> > and therefor all disk writes and read are sequential.
> > Do you have any "real world" benchmarks?

Not that I'm happy with.  For me 'real world' means a realistic use of
snapshots.  We've not had this ability to create lots of snapshots
before in Linux, so I'm not sure how people are going to use it.  I'll
get round to writing some benchmarks for certain scenarios eventually
(eg. incremental backups), but atm there are more pressing issues.

I mainly called those benchmarks meaningless because they didn't
address how fragmented the volumes become over time.  This
fragmentation is a function of io pattern, and the shape of the
snapshot tree.  In the same way I think filesystem benchmarks that
write lots of files to a freshly formatted volume are also pretty
meaningless.  What most people are interested in is how the system
will be performing after they've used it for six months, not the first
five minutes.

> > I am guessing that without the filesystem level knowledge in the thin
> > provisioned target,
> > files and filesystem metadata are not really laid out on the hard
> > drive as the filesystem
> > designer intended.
> > Wouldn't that be causing a large seek overhead on spinning media?

You're absolutely right.

> > 3. ENOSPC
> > Ext4 snapshots will get into readonly mode on unexpected ENOSPC situation.
> > That is not perfect and the best practice is to avoid getting to
> > ENOSPC situation.
> > But most application do know how to deal with ENOSPC and EROFS gracefully.
> > Do you have any "real life" experience of how applications deal with
> > blocking the
> > write request in ENOSPC situation?

If you run out of space userland needs to extend the data volume.  the
multisnap-pool target notifies userland (ie. dmeventd) before it
actually runs out.  If userland hasn't resized the volume before it
runs out of space then the ios will be paused.  This pausing is really
no different from suspending a dm device, something LVM has been doing
for 10 years.  So yes, we have experience of pausing io under
applications, and the 'notify userland' mechanism is already proven.

> > Or what is the outcome if someone presses the reset button because of an
> > unexplained (to him) system halt?

See my answer above on crash resistance.

> > 4. Cache size
> > At the time, I examined using ZFS on an embedded system with 512MB RAM.
> > I wasn't able to find any official requirements, but there were
> > several reports around
> > the net saying that running ZFS with less that 1GB RAM is a performance killer.
> > Do you have any information about recommended cache sizes to prevent
> > the metadata store from being a performance bottleneck?

The ideal cache size depends on your io patterns.  It also depends on
the data block size you've chosen.  The cache is divided into 4k
blocks, and each block holds ~256 mapping entries.

Unlike ZFS our metadata is very simple.

Those little micro benchmarks (dd and bonnie++) running on a little 4G
data volume perform nicely with only a 64k cache.  So in the worst
case I was envisaging a few meg for the cache, rather than a few
hundred meg.

- Joe




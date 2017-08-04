From: Eric Wheeler <lvm-devel@lists.ewheeler.net>
Date: Fri, 4 Aug 2017 00:38:22 +0000 (UTC)
Subject: Batch/queue LVM operations
In-Reply-To: <4c0a5ae7-2da4-7610-5d06-90d990bd41de@redhat.com>
References: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
	<32ff399c-7a79-5beb-abd5-d5dbad1486db@redhat.com>
	<alpine.LRH.2.11.1708011720490.9683@mail.ewheeler.net>
	<4c0a5ae7-2da4-7610-5d06-90d990bd41de@redhat.com>
Message-ID: <alpine.LRH.2.11.1708040036410.9683@mail.ewheeler.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 1 Aug 2017, Zdenek Kabelac wrote:

> Dne 1.8.2017 v 19:24 Eric Wheeler napsal(a):
> > On Fri, 28 Jul 2017, Zdenek Kabelac wrote:
> > 
> > > Dne 28.7.2017 v 21:22 Eric Wheeler napsal(a):
> > > > Hello,
> > > >
> > > > Is there an option to batch LVM operations?
> > > >
> > > > For example, I would like to delete 100 thin snapshots without updating
> > > > the vgmeta 100 times.
> > >
> > > You could possibly use --select feature to handle all removals with
> > > just one lvremove command.
> > 
> > I tried --select, but there is a long pause between removals so it is
> > clearly doing a metadata operation for each removal.
> > 
> > Is it possible to do something like this:
> > 
> > 1. Hold a lock (how?)
> > 2. vgcfgbackup -f /my-backup/file --ignorelocking-failure
> > 3. Modify /my-backup/file (remove LVs)
> > 4. dmsetup message pool 0 delete ID (each ID)
> > 5. vgcfgrestore --ignorelocking-failure
> > 6. Release lock
> > 
> > --
> > Eric Wheeler
> > 
> 
> Hi
> 
> Unfortunately this optimization is currently not possible.

Well, perhaps not by LVM at the moment, but is the procedure sound if I 
were to do this myself and accept any errors while deleting thin volumes?

Can vgcfgrestore be done hot with existing active volumes?

Similarly, could I do this for mass renames with the backup/restore?

--
Eric Wheeler

> 
> lvm2 is strictly working on 1-by-1 logic - since resolving more complex
> recovery path is beyond capabilities of this tool.
> 
> We do plan to 'group' 'lvremove' operation in future -
> so i.e. if you pass multiple  LVs on cmdline -
> sort them by  VG and do a single VG commit to remove them all.
> 
> But with thinLV this is different level as we would need to also
> join all delete thin-pool transactions together - and we do not have good
> interface for this to resolve 'what have been delete and what's been left in
> case of error' so there is some space for improvements ATM - but I could see
> some possibilities, but it's still in queue behind bigger fishes for
> hunting...
> 
> What we would could possibly improve more easily is to remove ALL thin LVs
> from a pool - such 'pool' reset could be implemented in more simple way.
> 
> So far the remove or creation of large numbers of LVs was not seen
> as time-critical operation - so we are rather focused on simpler code here.
> 
> 
> Regards
> 
> Zdenek
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 
> 



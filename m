From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 17 Mar 2023 16:02:03 +0100
Subject: Reg lvm vg private spare vol
In-Reply-To: <CAFe+wq11k_6CPd0KasygX5HVLouL51v=0oDAK_=V8RwYzDsPmg@mail.gmail.com>
References: <CAFe+wq11k_6CPd0KasygX5HVLouL51v=0oDAK_=V8RwYzDsPmg@mail.gmail.com>
Message-ID: <514f7674-443c-748a-309c-bfe7857a1446@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 16. 03. 23 v 3:45 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> A very good day to you.
>
> I understand when either thinpool?(or cachepool) gets used on a vg, there is 
> an internal meta volume and an additional spare volume that gets created on 
> the vg.
> Under some?circumstances, based on metadata utilization, we may end up 
> resizing the metavolume?(lvextend --poolmetadatasize).
> In my environment, I see that it only resizes the internal meta volume, but 
> not the spare volume.
>
> After looking up the prior tickets, I understand this is a known bug that 
> got fixed in later lvm releases. I also see that if lvmconvert --repair gets 
> run, then the spare volume gets resized to the same size as internal 
> metadata volume.
>
> I am trying to understand the impact of this bug in releases that have this 
> issue.
> My follow up question is, if the spare volume is not of the same size as the 
> metadata volume, what sort of issues would one observe? What will fail or 
> may not work as expected?
>
> And also whats the workaround, given repair option needs to deactivate all 
> lvols and vg need to have free space.
>
> Your inputs to clarify on the above are much appreciated.

Hi

lvm2 creates and used? a 'pmspare' volume for recovery purpose - it's been 
added later when we've noticed users are simply forgetting to read thin-pool 
usage documentation and tend to use all the available space for their 
thin-pool - and when they run out of space there was no more free space 
available in the VG to create a new thin-pool metadata volume - as the 
thin_repair utility is not repairing metadata 'in-place' and always require a 
new LV.

So we tend to maintain at least 1 spare volume per VG? which should be having 
the size of the biggest metadata volume in the VG - over the time there were 
couple bug fixed where the pmspare missed to be also increased in the size, 
when i.e. thin-pool metadata size was grow.

Since recent version of lvm2 always tend to maintain the size of thin-pool 
metadata to be always 'big-enough' to handle its data size - users should 
normally not need to repair metadata into 'bigger' sized volume as you should 
not 'reach' the out-of-metadata state condition - unless you are already on 
~16G max size.

If there is _pmspare in the VG - lvm2 can use this 'volume' for repairing - if 
there is not - user might be in 'bigger' troubles as user has to manage to 
repair metadata in way more complicated way.

So it's always GOOD idea to use the most recent version of lvm2 so it more 
proactively tries to shield users for various problems we've noticed over the 
time.

Not sure what do you mean by workaround - but in general users of thin-pool 
should make sure? they are adding more physical space (PVs) to VG when their 
thin-pool is growing to the size of VG itself - as users are 'provisioning' 
space -? thin-pool was not designed to be regularly used as 'overfilled' 
thin-pool state like if you have 'full filesystem'.? So for usable 'repair'? 
just be sure VG has some free space for creation of LV for repair of metadata.

Regards

Zdenek


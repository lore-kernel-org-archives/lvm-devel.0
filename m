From: Brassow Jonathan <jbrassow@redhat.com>
Date: Mon, 17 Mar 2014 10:56:17 -0500
Subject: cache support
In-Reply-To: <0b4501cf3d85$44b76c90$ce2645b0$@acm.org>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>	<52F205CA.1090807@redhat.com>	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>	<52F2AD44.8030006@redhat.com>	<0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>	<A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>	<0fff01cf276c$d059c8d0$710d5a70$@acm.org>
	<0C83CD55-18B6-4407-9A42-72F9D6C5683D@redhat.com>
	<0b4501cf3d85$44b76c90$ce2645b0$@acm.org>
Message-ID: <7A62EBEE-E031-469E-902B-FA507CADD9DA@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mar 11, 2014, at 6:54 PM, Paul B. Henson wrote:

>> From: Brassow Jonathan
>> Sent: Wednesday, February 12, 2014 9:40 AM
>> 
>> I'll let others weigh-in on the overhead of introducing thin-provisioning.
>> However, my experience is that the overhead is very small and the benefit
> is
>> very large.
> 
> So I think I'd like to try out your recommendation of using thin
> provisioning to allow dm-cache to cache all of my lv's, and was wondering if
> you guys had any rough idea on when you might release a version of  lvm2
> with support for cache devices? The box in question is pseudo-production,
> and while I think I'm willing to risk a freshly released new feature, I
> don't think I want to go quite so far as to run git head on it ;).
> 
> The intention is to allow insertion of a cache device live with no
> disruption in service, right? So theoretically I could get the thin
> provisioned pool all set up now and start using it, and then when the
> version with cache support is released, transparently slip in the cache
> device?
> 
> Is there a recommended kernel version for thin provisioning? Right now I'm
> running 3.12, but I thought I saw a bug recently fly by involving thinpool
> metadata corruption that's going to be fixed in 3.14, would it be better to
> wait for a stable release of 3.14?
> 
>> From reading mailing list archives, if your metadata volume runs out of
> space, your entire thin pool is corrupted? And historically you were unable
> to resize or extend your metadata volume? I see a number of mentions of that
> ability coming soon, but didn't see anything actually announcing it was
> available. At this point, is the size of the metadata volume still fixed as
> of initial creation? 
> 
> The intended size of my thinpool is going to be about 3.64TB:
> 
> /dev/md3   vg_vz lvm2 a--    3.64t  3.61t
> 
> Based on the recommendation below of 1/1000 of that for metadata, that would
> be about 3.75GB. This pool is going to have *lots* of snapshots, there are
> going to be a set of filesystems for a template vm, each of which will be
> snapshot'd/cloned when a new vm is created, and then all of those will have
> snapshots for backups. Given that, would 3.75GB for the metadata volume be
> sufficient, or would it be better to crank it up a little?
> 
> Given /dev/md3 is my "slow" device (raid10 of 4 x 2TB), and /dev/md2 is my
> "fast" device (raid1 of 2 x 256G SSD), plugging into your example gives me:
> 
> # vgcreate vg_vz /dev/md3 /dev/md2
> # lvcreate -l 953800 -n thinpool vg_vz /dev/md3
> # lvcreate -L 3.75G -n thinpool_metadata /dev/md2
> # lvconvert --thinpool vg_vz/thinpool --poolmetadata thinpool_metadata
> 
> At this point, I would have a thinpool ready to use, and can work with it
> until a version of lvm2 is released with cache support, at which point I
> could run:
> 
> # lvcreate --type cache_pool -l 100%PVS  -n cachepool vg /dev/md2
> # lvconvert --type cache --cachepool vg/cachepool vg/thinpool
> 
> To transparently add the cache device to my existing thinpool?

Yes, that is basically the idea.  However, converting the thinpool is a little more tricky.  You already are using the fast device for the thinpool metadata device (which seems awfully large from your example).  When you cache the thinpool, I think you just want to cache the data section.
# lvconvert --type cache --cachepool vg/cachepool vg/thinpool_tdata

 brassow





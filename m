From: Leo Yan <leo.yan@linaro.org>
Date: Fri, 26 Jun 2020 18:23:36 +0800
Subject: Question: LVM2 testing with sanlock lock manager
In-Reply-To: <20200625191100.GA27855@redhat.com>
References: <20200625093411.GB19777@leoy-ThinkPad-X240s>
	<20200625145523.GA23434@redhat.com>
	<20200625191100.GA27855@redhat.com>
Message-ID: <20200626102336.GA28664@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi David,

Thank you for kindly replying.

On Thu, Jun 25, 2020 at 02:11:00PM -0500, David Teigland wrote:
> On Thu, Jun 25, 2020 at 09:55:23AM -0500, David Teigland wrote:
> > with sanlock.  I will try component-cache.sh to see if that's the issue,
> > or something else.
> 
> I suspect that test is hitting an issue where a stray lock is being left
> behind and blocking the test cleanup.  The test is using some unusual
> commands, activating internal LVs that are usually disallowed.
> 
> I couldn't get the GL_DEV/GL_FILE stuff to work, with or without your
> patches.  I removed all that and specified a literal sd device.  I'd
> suggest we do that instead of the complicated attempt to automate it; i.e.
> require a path to an unused device that the test will use for glvg.

I followed your suggestion and tried to use a dedicated /dev/sdX device
for global lock with sanlock, after run several test cases, it looks
to me is much stable than before for global lock.

For component-cache.sh, I still can see it's stuck at the last line of
the test case:

[ 1:01] lvs -a $vg
[ 1:01] #component-cache.sh:89+ lvs -a @PREFIX at vg
[ 1:01]   LV                  VG             Attr       LSize   Pool    Origin              Data%  Meta%  Move Log Cpy%Sync Convert
[ 1:01]   [cpool]             @PREFIX at vg Cwi---C---   2.00m
[ 1:01]   [cpool_cdata]       @PREFIX at vg Cwi-------   2.00m
[ 1:01]   [cpool_cmeta]       @PREFIX at vg eRi-a-----   4.50m
[ 1:01]   [lvmlock]           @PREFIX at vg -wi-ao---- 256.00m
[ 1:01]   [lvol0_pmspare]     @PREFIX at vg ewi-------   4.50m
[ 1:01]   tpool               @PREFIX at vg twi---tz--   4.00m
[ 1:01]   [tpool_tdata]       @PREFIX at vg Cwi---C---   4.00m [cpool] [tpool_tdata_corig]
[ 1:01]   [tpool_tdata_corig] @PREFIX at vg owi---C---   4.00m
[ 1:01]   [tpool_tmeta]       @PREFIX at vg ewi-------   2.00m
[ 1:01]
[ 1:01] # And final removal works                                        
[ 1:01] vgremove -f $vg                                                  
[ 1:01] #component-cache.sh:92+ vgremove -f @PREFIX at vg                   
[ 1:01]   WARNING: This metadata update is NOT backed up.                
[ 1:01]   Logical volume "tpool" successfully removed                    

So the LV "tpool" has been removed but seems it stuck on other LV's
deleting?  Should I note other component, e.g dmeventd for this?

Thanks,
Leo



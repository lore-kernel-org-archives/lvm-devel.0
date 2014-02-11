From: Brassow Jonathan <jbrassow@redhat.com>
Date: Tue, 11 Feb 2014 11:24:25 -0600
Subject: cache support
In-Reply-To: <0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>	<52F205CA.1090807@redhat.com>	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>
	<52F2AD44.8030006@redhat.com>
	<0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>
Message-ID: <A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Feb 5, 2014, at 7:36 PM, Paul B. Henson wrote:

>> 
>> We may consider the option to use a single cache pool for multiple single
>> linear LVs - since in this case we might be able to resolve tricky virtual
>> mapping.
> 
> It would probably work out for my use case if the PV itself wasn't cached
> but the entire SSD cache device could be shared amongst all of the LV's. I
> really don't want to split the cache into separate pieces per LV though,
> that's just not going to scale.
> 
> Thanks.

What do you think about caching a thin pool?  Then you would get the benefit of caching for all of your LVs and you would get all the benefits of thin and thin snapshots.

We are still working on getting all the cache pieces in place in LVM.  Thanks for watching.
 brassow



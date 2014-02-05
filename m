From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 05 Feb 2014 22:29:40 +0100
Subject: cache support
In-Reply-To: <0a3901cf22af$ae01d2d0$0a057870$@acm.org>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>	<52F205CA.1090807@redhat.com>
	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>
Message-ID: <52F2AD44.8030006@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 5.2.2014 21:20, Paul B. Henson napsal(a):
>> From: Zdenek Kabelac
>> Sent: Wednesday, February 05, 2014 1:35 AM
> I've read somewhat about the integration of mdraid and lvm, but not enough
> to fully understand it or be comfortable about switching from classic mdraid
> to lvm integrated mdraid.

Well if you miss feature from  mdadm you may request some enhacements.
It should be giving you more options - since the LV doens't need to be across 
whole PV - i.e. you could have 4 disks in VG -  and you could build some LV in 
raid0/stripe,  other in raid1, and also some LV could be in raid5.


>> Current version of dm-cache supports  only  1:1 mapping - so one large
> cache
>> shared by multiple LVs is not supported. You will need to prepare smaller
>> individual cache pools for each of your LV.
>
> I'm not sure what you mean here; I confirmed on the device mapper mailing
> list that using dm-cache directly would support my desired stacking of
> placing a PV on top of a dm-cache device that is sitting on top of a raw SSD
> raid1 md cache device and a raw HD raid10 origin device, effectively using
> the single cache device to cache all of the LV's created on the PV. I don't
> really want to split up the cache device into bits and pieces for each
> individual LV, that doesn't seem very efficient; I'd rather have the entire
> cache device available for which ever LV's happen to be hot at a given time.
>
> So it's really just a question of whether or not lvm is going to support a
> user-friendly layer on top of dm-cache for this type of stacking, or if
> somebody will be stuck using dm-cache directly if they want to implement
> something like this.


lvm2 is not supporting caching of PVs - that's the layer below the lvm2. Your 
proposed idea would be hard to efficiently implement.

lvm2 would have to create some 'virtual' huge device combined from all PVs in 
VG  (and with special handling for segments like mirrors/raids) - this would 
be then always used as a cache for any LV activated from this virtual layer - 
with lost of troubles during activation.

With per LV granularity you get the option to chose different policy for each LV.

Note - it should be possible to create  cached  thin pool data LV - and then 
you get all thin volumes  cached through data device.

We may consider the option to use a single cache pool for multiple single 
linear LVs - since in this case we might be able to resolve tricky virtual 
mapping.

Zdenek



From: Paul B. Henson <henson@acm.org>
Date: Wed, 5 Feb 2014 12:20:11 -0800
Subject: cache support
In-Reply-To: <52F205CA.1090807@redhat.com>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>
	<52F205CA.1090807@redhat.com>
Message-ID: <0a3901cf22af$ae01d2d0$0a057870$@acm.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> From: Zdenek Kabelac
> Sent: Wednesday, February 05, 2014 1:35 AM
>
> Well - there is work in progress in upstream git - but it's highly
> 'experimental' and its user-space API can change any minute - so it's only
> useful for playing - but not for any real use yet.

Agreed :). I'm just looking to try and make sure that as it stabilizes my
desired use case fits in the picture ;).

> Side note - lvm2 now supports it's own metadata format for md raid1 - this
> should allow better handling of device stack (it's using same kernel
driver as
> mdraid) - use just a single command to active everything in proper order.

I've read somewhat about the integration of mdraid and lvm, but not enough
to fully understand it or be comfortable about switching from classic mdraid
to lvm integrated mdraid.

> Current version of dm-cache supports  only  1:1 mapping - so one large
cache
> shared by multiple LVs is not supported. You will need to prepare smaller
> individual cache pools for each of your LV.

I'm not sure what you mean here; I confirmed on the device mapper mailing
list that using dm-cache directly would support my desired stacking of
placing a PV on top of a dm-cache device that is sitting on top of a raw SSD
raid1 md cache device and a raw HD raid10 origin device, effectively using
the single cache device to cache all of the LV's created on the PV. I don't
really want to split up the cache device into bits and pieces for each
individual LV, that doesn't seem very efficient; I'd rather have the entire
cache device available for which ever LV's happen to be hot at a given time.

So it's really just a question of whether or not lvm is going to support a
user-friendly layer on top of dm-cache for this type of stacking, or if
somebody will be stuck using dm-cache directly if they want to implement
something like this.

Thanks.




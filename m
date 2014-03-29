From: Paul B. Henson <henson@acm.org>
Date: Fri, 28 Mar 2014 18:38:41 -0700
Subject: cache support
In-Reply-To: <7A62EBEE-E031-469E-902B-FA507CADD9DA@redhat.com>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>
	<52F205CA.1090807@redhat.com>
	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>
	<52F2AD44.8030006@redhat.com>
	<0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>
	<A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>
	<0fff01cf276c$d059c8d0$710d5a70$@acm.org>
	<0C83CD55-18B6-4407-9A42-72F9D6C5683D@redhat.com>
	<0b4501cf3d85$44b76c90$ce2645b0$@acm.org>
	<7A62EBEE-E031-469E-902B-FA507CADD9DA@redhat.com>
Message-ID: <20140329013841.GL5509@bender.unx.csupomona.edu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Mar 17, 2014 at 10:56:17AM -0500, Brassow Jonathan wrote:

> > Given /dev/md3 is my "slow" device (raid10 of 4 x 2TB), and /dev/md2 is my
> > "fast" device (raid1 of 2 x 256G SSD), plugging into your example gives me:
> > 
> > # vgcreate vg_vz /dev/md3 /dev/md2
> > # lvcreate -l 953800 -n thinpool vg_vz /dev/md3
> > # lvcreate -L 3.75G -n thinpool_metadata /dev/md2
> > # lvconvert --thinpool vg_vz/thinpool --poolmetadata thinpool_metadata

So I updated to the latest 3.13.7 kernel and decided to try and spin up my
thin pool. The first couple steps went well:

# lvcreate -l 945908 -n thinpool vg_vz /dev/md3
  Logical volume "thinpool" created

# lvcreate -L 2.5G -n thinpool_metadata vg_vz /dev/md2
  Logical volume "thinpool_metadata" created

But lvconvert seems to have gone sideways:

# lvconvert --thinpool vg_vz/thinpool --poolmetadata thinpool_metadata
  device-mapper: remove ioctl on  failed: Device or resource busy
  Logical volume "lvol0" created
  device-mapper: reload ioctl on  failed: Invalid argument
  Failed to activate pool logical volume vg_vz/thinpool.

The thinpool seems to sort of be there, but it's not active, and lvs gives
an error I assume is related to it:

# lvs vg_vz
  dm_report_object: report function failed for field data_percent
  LV              VG    Attr       LSize   Pool Origin Data%  Move Log Cpy%Sync Convert
  thinpool        vg_vz twi---tz--   3.61t

I can't seem to activate it:

# vgchange -a y vg_vz
  device-mapper: reload ioctl on  failed: Invalid argument
  16 logical volume(s) in volume group "vg_vz" now active

I finally ended up trying to delete it:

# lvremove vg_vz/thinpool
Do you really want to remove and DISCARD logical volume thinpool? [y/n]: y
  Logical volume "thinpool" successfully removed

And that seems to have cleaned everything up.

The ioctl complaints seem like they might be related to:

	https://bugzilla.redhat.com/show_bug.cgi?id=927437#c10

But I didn't see anything about failing to activate the pool?

I tried it again, this time it said:

# lvconvert  --thinpool vg_vz/thinpool --poolmetadata thinpool_metadata
  device-mapper: remove ioctl on  failed: Device or resource busy
  Logical volume "lvol0" created
  device-mapper: create ioctl on vg_vz-thinpool_tmeta failed: Device or resource busy
  Failed to activate pool logical volume vg_vz/thinpool.

lvs doesn't give an error now, but any attempt to make a thin volume fails
with the same error lvconvert gave:

# lvcreate -T vg_vz/thinpool -V 10G -n testlv
  device-mapper: create ioctl on vg_vz-thinpool_tmeta failed: Device or resource busy

Am I doing something wrong here?

Also, what's the lvol0_pmspare volume that seems to show up? It's the exact
same size as my metadata lv?

# lvs --all vg_vz
  LV               VG    Attr       LSize   Pool Origin Data%  Move Log Cpy%Sync Convert
  [lvol0_pmspare]  vg_vz ewi-------   2.50g
  thinpool         vg_vz twi---tz--   3.61t
  [thinpool_tdata] vg_vz Twi-------   3.61t
  [thinpool_tmeta] vg_vz ewi-------   2.50g

Thanks...



From: Brassow Jonathan <jbrassow@redhat.com>
Date: Wed, 2 Apr 2014 15:34:46 -0500
Subject: cache support
In-Reply-To: <20140329014302.GM5509@bender.unx.csupomona.edu>
References: <52F205CA.1090807@redhat.com>
	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>
	<52F2AD44.8030006@redhat.com>
	<0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>
	<A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>
	<0fff01cf276c$d059c8d0$710d5a70$@acm.org>
	<0C83CD55-18B6-4407-9A42-72F9D6C5683D@redhat.com>
	<0b4501cf3d85$44b76c90$ce2645b0$@acm.org>
	<7A62EBEE-E031-469E-902B-FA507CADD9DA@redhat.com>
	<20140329013841.GL5509@bender.unx.csupomona.edu>
	<20140329014302.GM5509@bender.unx.csupomona.edu>
Message-ID: <DCB87093-0877-4CE2-A738-4D5E6B2D194B@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mar 28, 2014, at 8:43 PM, Paul B. Henson wrote:

> On Fri, Mar 28, 2014 at 06:38:41PM -0700, Paul B. Henson wrote:
> 
>> So I updated to the latest 3.13.7 kernel and decided to try and spin up my
>> thin pool. The first couple steps went well:
>> 
>> # lvcreate -l 945908 -n thinpool vg_vz /dev/md3
>>  Logical volume "thinpool" created
>> 
>> # lvcreate -L 2.5G -n thinpool_metadata vg_vz /dev/md2
>>  Logical volume "thinpool_metadata" created
>> 
>> But lvconvert seems to have gone sideways:
>> 
>> # lvconvert --thinpool vg_vz/thinpool --poolmetadata thinpool_metadata
>>  device-mapper: remove ioctl on  failed: Device or resource busy
>>  Logical volume "lvol0" created
>>  device-mapper: reload ioctl on  failed: Invalid argument
>>  Failed to activate pool logical volume vg_vz/thinpool.
> 
> I also just noticed the kernel logged some complaints too when I tried to run
> the lvconvert:
> 
> Mar 28 17:59:03 virtz kernel: [82813.713227] device-mapper: table: 253:26: thin-pool: Invalid block size
> Mar 28 17:59:03 virtz kernel: [82813.713232] device-mapper: ioctl: error adding target to table
> 
> 
> Mar 28 18:11:38 virtz kernel: [83568.730506] device-mapper: table: 253:26: thin-pool: Invalid block size
> Mar 28 18:11:38 virtz kernel: [83568.730510] device-mapper: ioctl: error adding target to table

What version of LVM are you using?

 brassow




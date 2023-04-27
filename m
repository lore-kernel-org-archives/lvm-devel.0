From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 27 Apr 2023 11:29:17 +0200
Subject: Data recovery -- thin provisioned LVM metadata (?) problem after hardware failure
In-Reply-To: <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
References: <54726276-8f4e-7538-f0b5-e825920a0357@web.de>
 <b987f331-b2c8-ed18-14eb-e039830ed436@gmail.com>
 <7de7fbb2-7c52-4564-e63e-e4c1523962f7@web.de>
Message-ID: <5b8439e8-f7a0-c9c3-cdc8-257ee68db41c@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26. 04. 23 v 15:12 haaber napsal(a):
> Thank you, Ming-Hun and Zdenek for your quick replies. I answer below!
> 
> On 4/26/23 13:10, Zdenek Kabelac wrote:
>> Dear all,
>>>
>>> I had a lethally bad hardware failure and to replace the machine.
>>> Now I try to get some data back that is not contained in half-year
>>> backups ... (I know! but it's too late to be sorry). OK,? the old SSD
>>> is attached? via usb adapter to a brand new machine. I started
>>>
>>> sudo pvscan
>>> sudo vgscan --mknodes
>>> sudo vgchange -ay
>>>
>>> Here is the? unexpected output:
>>>
>>> ??PV /dev/mapper/OLDSSD ? VG?? vg0 ????? lvm2 [238.27 GiB / <15.79
>>> GiB free]
>>> ?? Total: 1 [238.27 GiB] / in use: 1 [238.27 GiB] / in no VG: 0 [0?? ]
>>> ?? Found volume group "vg0" using metadata type lvm2
>>> ?? Check of pool vg0/pool00 failed (status:1). Manual repair required!
>>> ?? 1 logical volume(s) in volume group "vg0" now active
>>>
>>> then I consulted dr. google for diagnosis, but found only little
>>> help. This one
>>>
>>> https://mellowhost.com/billing/index.php?rp=/knowledgebase/65/How-to-Repair-a-lvm-thin-pool.html
>>>
>>>
>>> suggested to deactivate all sub-volumes so that a repair can work
>>> correctly. It happened that only swap was
>>> active, so I deactivated it. But repair does still not work:
>>>
>>> lvconvert --repair vg0/pool00
>>> terminate called after throwing an instance of 'std::runtime_error'
>>> ?? what():? transaction_manager::new_block() couldn't allocate new block
>>> ?? Child 21255 exited abnormally
>>> ?? Repair of thin metadata volume of thin pool vg0/pool00 failed
>>> (status:-1). Manual repair required!
>>>
>>>
>>> I would like to find a good soul out there that can give more hints.
>>> In particular,
>>> could it be a metadata overflow? How to check? I seek not for repair,
>>> but a "once only"
>>> read access to the pool data ....
>>>
>>
>> Hi
>>
>> Check? 'man lvmthin'? "Metadata check and repair" section.
>> If the 'repair' does not work make sure you have 'latest' thin_repair
>> tool (>= v0.9) - as older distros come with ancient less capable
>> version of this tool.
>>
>> Since you likely already tried to repair metadata - you may need to do
>> the manual repair with the use? of? _meta0? LV? (see man lvmthin).
>>
>> If you cannot get? 'workable' metadata with? 0.9 of thin_repair tool -
>> you will likely need to create a BZ - upload compressed content of
>> your metadata device for futher analysis - whether it's somehow
>> possible to recover bTree.
> 
> I have thin_repair 0.9 installed. But I first have to dump metadata into
> a file, so I invoked (after pvscan and vgscan and vgchange -an)
> 
>  ??? root at machine:~#?? thin_dump /dev/mapper/OLDSSD -o thindump.xml -r
>  ??? The following field needs to be provided on the command line due to
> corruption in the superblock: transaction id
> 
> Oups. So the? superblock is damaged. What should / could I serve
> thin_repair as transaction id ?? Since we read only, I tried 0:
> 
>  ??? root at machine:~#? thin_dump /dev/mapper/OLDSSD -o thindump.xml -r
> --transaction-id 0
>  ??? The following field needs to be provided on the command line due to
> corruption in the superblock: data block size
> 
> Oups. I gave it a try and added --data-block-size 128 just to see. Now
> it asks for nr of data blocks ... aargh! I cannot guess that one.

Hi

Not sure I'm getting right your process here.

There are 2 types of 'metadata' and a different recovery work needed for them.

> Could I? " dd " the superblock for inspection into a file? Is there only
> one superblock? Most fs have several ones, for exactly that reason ...
> i.e: can I use a copy?
> 
> I? dd'ed the first 2M of the /dev/mapper/OLDSSD into a file, and gave it
> a try. After some binary data (less than 1k), follow roughly 1M of json
> type data like this
> 
> whatever {
> id = "bhQocj-EJ6Y-0jXC-oAmr-lxlF-cudL-5ohI1e"
> status = ["READ", "WRITE", "VISIBLE"]
> flags = []
> creation_time = 1677967121
> creation_host = "dom0"
> segment_count = 1
> 
> segment1 {
> start_extent = 0
> extent_count = 512
> 
> type = "thin"
> thin_pool = "pool00"
> transaction_id = 44995
> device_id = 19881
> }
> 
> and then many binary data again. Would this 1M (uncompressed), probably
> 100K bzipped data be of any help? I could post it somewhere. Again, I do
> not want to have the thin pool re-usable, but just take a last "clean
> copy" on a new disc ...

There are 'lvm2'  metadata - which are stored withing the PV disk header
(by default this is located in the 1st. 1 MiB of your device).

These metadata have absolutely nothing to do with thin-pool metadata!
lvm2 just keeps the layout of blocks for your LVs.

To get to your thin-pool metadata, you have to activate LV with them. 
(lvchange -ay  vgname/thinpoolmetadata).

Once you have your thinpool metadata 'active'  (present in DM table), then
you can fire 'thin_dump --repair'  / 'thin_repair' tool.

ATM it's not clear in which state of recovery you are.

So do you have you 'lvm2' completely & usable  and can you  active LV which 
holds  thin-pool metadata ?

Can you please provide   'lvs -a'  of your volume group ?

And if you use 'thin_dump/thin_repair' - your *exact* command line you've been 
using?

Regards

Zdenek








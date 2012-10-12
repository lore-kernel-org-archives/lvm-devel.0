From: Brassow Jonathan <jbrassow@redhat.com>
Date: Fri, 12 Oct 2012 11:11:08 -0500
Subject: [PATCH] RAID: Make RAID 4/5/6 display sync status under heading s/Copy%/Cpy%Sync
In-Reply-To: <5077BEC6.3050909@gmail.com>
References: <1349974727.25910.2.camel@f16> <5077BEC6.3050909@gmail.com>
Message-ID: <164C34CC-E44A-4367-9A69-9AD2AC90E370@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Oct 12, 2012, at 1:55 AM, Zdenek Kabelac wrote:

> Dne 11.10.2012 18:58, Jonathan Brassow napsal(a):
>> RAID: Make RAID 4/5/6 display sync status under heading s/Copy%/Cpy%Sync
>> 
>> The heading 'Copy%' is specific to PVMOVE volumes, but can be generalized
>> to apply to LVM mirrors also.  It is a bit awkward to use 'Copy%' for
>> RAID 4/5/6, however - 'Sync%' would be more appropriate.  This is why
>> RAID 4/5/6 have not displayed their sync status by any means available to
>> 'lvs' yet.
>> 
>> Example (old):
>> [root at hayes-02 lvm2]# lvs vg
>>   LV      VG   Attr      LSize  Pool Origin Data%  Move Log Cpy%Sy Convert
>>   lv    vg   -wi-a----  1.00g
>>   raid1 vg   rwi-a-r--  1.00g                             100.00
>>   raid4 vg   rwi-a-r--  1.01g
>>   raid5 vg   rwi-a-r--  1.01g
>>   raid6 vg   rwi-a-r--  1.01g
>> 
>> This patch changes the heading to 'Cpy%Sync' and allows RAID 4/5/6 to print
>> their sync percent in this field.
>> 
>> Example (new):
>> [root at hayes-02 lvm2]# lvs vg
>>   LV    VG   Attr      LSize Pool Origin Data%  Move Log Cpy%Sync Convert
>>   lv    vg   -wi-a---- 1.00g
>>   raid1 vg   rwi-a-r-- 1.00g                               100.00
>>   raid4 vg   rwi-a-r-- 1.01g                               100.00
>>   raid5 vg   rwi-a-r-- 1.01g                               100.00
>>   raid6 vg   rwi-a-r-- 1.01g                               100.00
>> 
>> Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
>> 
>> Index: lvm2/lib/report/columns.h
>> ===================================================================
>> --- lvm2.orig/lib/report/columns.h
>> +++ lvm2/lib/report/columns.h
>> @@ -78,7 +78,7 @@ FIELD(LVS, lv, NUM, "OSize", lvid, 5, or
>>  FIELD(LVS, lv, NUM, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
>>  FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
>>  FIELD(LVS, lv, NUM, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
>> -FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, copy_percent, "For mirrors and pvmove, current percentage in-sync.", 0)
>> +FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
> 
> 
> Just add new one if needed - and keep the old one available for users (staying backward compatible)
> 
> You may update default columns written by lvs command and change Copy% field to something else.
> 
> Though IMHO   Copy%  looks better then Cpy%Sync...

i had similar thoughts about whether or not to just create a new field.  I've been over this with agk and this is how I arrived at the patch above.

 brassow



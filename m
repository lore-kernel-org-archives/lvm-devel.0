From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 27 Apr 2012 14:59:56 +0200
Subject: LVM2 ./WHATS_NEW lib/metadata/vg.c
In-Reply-To: <4F9A9379.8050500@redhat.com>
References: <20120425133844.2502.qmail@sourceware.org>
	<4F9A9379.8050500@redhat.com>
Message-ID: <4F9A984C.7080305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/27/2012 02:39 PM, Zdenek Kabelac wrote:
> Dne 25.4.2012 15:38, jbrassow at sourceware.org napsal(a):
>> CVSROOT:	/cvs/lvm2
>> Module name:	LVM2
>> Changes by:	jbrassow at sourceware.org	2012-04-25 13:38:42
>>
>> Modified files:
>> 	.              : WHATS_NEW 
>> 	lib/metadata   : vg.c 
>>
>> Log message:
>> 	Disallow changing cluster attribute of VG while RAID LVs are active.
>> 	
>> 	Mirror and snapshot LVs are already checked for when switching the cluster
>> 	attribute of a VG.  This patch adds RAID.
>>
>> Patches:
>> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2392&r2=1.2393
>> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
>>
>> --- LVM2/WHATS_NEW	2012/04/25 09:32:36	1.2392
>> +++ LVM2/WHATS_NEW	2012/04/25 13:38:41	1.2393
>> @@ -1,5 +1,6 @@
>>  Version 2.02.96 - 
>>  ================================
>> +  Disallow changing cluster attribute of VG while RAID LVs are active.
>>    Fix lvconvert error message for non-mergeable volumes.
>>    Allow subset of failed devices to be replaced in RAID LVs.
>>    Prevent resume from creating error devices that already exist from suspend.
>> --- LVM2/lib/metadata/vg.c	2012/02/13 11:04:00	1.17
>> +++ LVM2/lib/metadata/vg.c	2012/04/25 13:38:42	1.18
>> @@ -517,9 +517,11 @@
>>  	 * on active mirrors or snapshots.
>>  	 */
>>  	dm_list_iterate_items(lvl, &vg->lvs) {
>> -		if (lv_is_mirrored(lvl->lv) && lv_is_active(lvl->lv)) {
>> -			log_error("Mirror logical volumes must be inactive "
>> -				  "when changing the cluster attribute.");
>> +		if (lv_is_active(lvl->lv) &&
>> +		    (lv_is_mirrored(lvl->lv) || lv_is_raid_type(lvl->lv))) {
>> +			log_error("%s logical volumes must be inactive "
>> +				  "when changing the cluster attribute.",
>> +				  lv_is_raid_type(lvl->lv) ? "RAID" : "Mirror");
>>  			return 0;
>>
> 
> Hmm - I'm quite confused here -
> 
> What is the point to check explicitly for 'raid' that  cluster bit cannot be
> changed for VG?
> 
> Currently AFAIK it's not supported for any active LV  - i.e. current there is
> no support for obtaining cluster locks during such conversion?
> 
> So shouldn't we rather prohibit conversions for now when any LV from VG is
> active ?

+1

True, for example this sequence will also end up with a leftover mapping in
the system that is a consequence of the same problem, linear mapping:

vgcreate -cn vg /dev/sda
lvcreate -l1 vg
vgchange -cy vg
lvremove -ff vg

Metadata updated but the mapping left! So it does not work with linear as well...

Peter



From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 26 Jun 2013 17:49:02 -0500
Subject: Internal error: Pool read_vg crc mismatch only when running in test environment
In-Reply-To: <51CA9D11.90007@redhat.com>
References: <51C38DB6.7070507@redhat.com> <51C45AD9.2040703@redhat.com>
	<51CA27AC.4040900@redhat.com> <51CA9D11.90007@redhat.com>
Message-ID: <51CB6FDE.8060700@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/26/2013 02:49 AM, Zdenek Kabelac wrote:
> Dne 26.6.2013 01:28, Tony Asleson napsal(a):
>> On 06/21/2013 08:53 AM, Zdenek Kabelac wrote:
>>> Dne 21.6.2013 01:18, Tony Asleson napsal(a):
>>>> Writing some new unit test cases for my latest liblvm patch set and at
>>>> the moment I am running into a case where I can run the unit test case
>>>> against real disk and it works, but if I run it in the test environment
>>>> with loop back devices I am getting an abort with:
>>>>
>>>> "Internal error: Pool read_vg crc mismatch."
>>>>
>>>> Any ideas why this error isn't occurring on both?
>>>>
>>>
>>> This happens - if you have requested 'read-only'  VG struct,
>>> and you have modifed something in this vgmem pool
>>> (either writing to struct, or just using vgmem pool for allocation)
>>
>> My original inquiry was for ideas why I see this on loop back devices
>> and not actual devices.  This response doesn't seem to match what I am
>> seeing.
> 
> It's hard to give advice if I do not see the actual code.

Patch set was posted a while back.  Specifically the issue I am running
into has to do with the functionality to list all PVs (including orphan)

Specific patch is:
https://www.redhat.com/archives/lvm-devel/2013-May/msg00036.html

>> The stack trace shows that we are getting this error during an
>> lvm_vg_open.  I can re-create the error regardless if I open the vg
>> struct as read-only or read-write.
>>
>>  From my initial debug it appears that if the vginfo->vg_use_count > 1
>> (in this case 3) we pass 1 as the second parameter to dm_pool_unlock
>> which is a crc check of the pool which it finds to be different.  At
>> this point it would seem I am exacerbating some type of caching bug or
>> that somewhere along the path I am inadvertently changing the contents
>> of the vg struct pointer with my latest patches.
> 
> There is internal debug support for this kind of problems which mprotects
> vg structure, so any write access to locked vg structure crashes the
> application and you may look at stack trace.
> 
> But it needs some hand modification of make.tmpl file (no configure option)
> Uncomment #DEFS += -DDEBUG_ENFORCE_POOL_LOCKING  and rebuild and retest
> with
> unlimited coredump size.

Thanks for the tip, this helped quite a bit!  I modified the code in the
above referenced patch to retain the vg pointer when retrieving the list
of PVs.  The liblvm library uses the vg->vgmem pool to allocate strings
to be returned to the user when getting information pertaining to a PV.
 The problem is that the vg gets cached with a crc.  We then allocate
memory from the vgmem pool and later when we go to clear out the cache
entry we fail the crc check.  When I enable the
DEBUG_ENFORCE_POOL_LOCKING we fail after we retrieve a vg from the cache
and then I try to allocate something from the vgmem pool.

Your comment about opening the vg "r" vs. "w" still seems incorrect to
me, but if it is indeed correct then we have a problem with the library
that precedes any of my changes.  We use the vg->vgmem for many things
and if this argument is indeed true then all those allocations will be
causing the vg struct to change, thus causing crc errors if the user is
allowed to open the vg struct as read-only.  In my code review and
testing it appears that we aren't hitting this because when we call into
vg_open we don't have a vgid, so we fail early in lvmcache_get_vg and
thus we never add them to the cache and thus we never call dm_pool_lock
on them.

If you could point out the bit of code that actually determines that we
mprotect memory based on the user doing an vg open read only vs. read
write that would be most helpful.  I'm not seeing it at the moment and I
would like to understand this better.

Currently I am thinking about just backing out the change to retrieve
the pv list and use the cmd->mem for allocations instead of the
vg->vgmem.  Previously I brought up just putting such things on the heap
and letting the users of the library free them, but that was dismissed
because existing library users would then have memory leaks.

Thanks,
Tony



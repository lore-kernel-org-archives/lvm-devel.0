From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 26 Jun 2013 09:49:37 +0200
Subject: Internal error: Pool read_vg crc mismatch only when running in test environment
In-Reply-To: <51CA27AC.4040900@redhat.com>
References: <51C38DB6.7070507@redhat.com> <51C45AD9.2040703@redhat.com>
	<51CA27AC.4040900@redhat.com>
Message-ID: <51CA9D11.90007@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26.6.2013 01:28, Tony Asleson napsal(a):
> On 06/21/2013 08:53 AM, Zdenek Kabelac wrote:
>> Dne 21.6.2013 01:18, Tony Asleson napsal(a):
>>> Writing some new unit test cases for my latest liblvm patch set and at
>>> the moment I am running into a case where I can run the unit test case
>>> against real disk and it works, but if I run it in the test environment
>>> with loop back devices I am getting an abort with:
>>>
>>> "Internal error: Pool read_vg crc mismatch."
>>>
>>> Any ideas why this error isn't occurring on both?
>>>
>>
>> This happens - if you have requested 'read-only'  VG struct,
>> and you have modifed something in this vgmem pool
>> (either writing to struct, or just using vgmem pool for allocation)
>
> My original inquiry was for ideas why I see this on loop back devices
> and not actual devices.  This response doesn't seem to match what I am
> seeing.

It's hard to give advice if I do not see the actual code.


>
> The stack trace shows that we are getting this error during an
> lvm_vg_open.  I can re-create the error regardless if I open the vg
> struct as read-only or read-write.
>
>  From my initial debug it appears that if the vginfo->vg_use_count > 1
> (in this case 3) we pass 1 as the second parameter to dm_pool_unlock
> which is a crc check of the pool which it finds to be different.  At
> this point it would seem I am exacerbating some type of caching bug or
> that somewhere along the path I am inadvertently changing the contents
> of the vg struct pointer with my latest patches.

There is internal debug support for this kind of problems which mprotects
vg structure, so any write access to locked vg structure crashes the 
application and you may look at stack trace.

But it needs some hand modification of make.tmpl file (no configure option)
Uncomment #DEFS += -DDEBUG_ENFORCE_POOL_LOCKING  and rebuild and retest with
unlimited coredump size.

Zdenek



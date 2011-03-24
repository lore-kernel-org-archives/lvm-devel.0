From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 24 Mar 2011 14:50:06 +0100
Subject: [PATCH 1/6] Pool locking code
In-Reply-To: <4D8B3CEE.7060505@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>	<d2353d5f9081b6eed91ed788af173ddf88dd4bba.1300828168.git.zkabelac@redhat.com>	<1300888988.14527.28.camel@ubuntu>	<4D8A098C.8060803@redhat.com>	<1300893225.14527.37.camel@ubuntu>	<4D8A1886.1090105@redhat.com>	<1300905681.25951.3.camel@ubuntu>	<4D8A437D.9080609@redhat.com>
	<1300969276.28356.12.camel@ubuntu> <4D8B3CEE.7060505@redhat.com>
Message-ID: <4D8B4C0E.6010903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 24.3.2011 13:45, Zdenek Kabelac napsal(a):
> Dne 24.3.2011 13:21, Joe Thornber napsal(a):
>> On Wed, 2011-03-23 at 20:01 +0100, Zdenek Kabelac wrote:
>>>
>>> Yes - the locking has rather 'debug' semantic to catch writes to vg
>>> mempool.
>>>
>>> But I'm not sure what do you mean here by 'set/restore api won't be
>>> needed' ? 
>>
>> I had a quick chat about this with Alasdair yesterday.  The plan is to
>> change the code that updates the VGs so they don't touch the VG data in
>> the pool, but instead hold those small changes off to one side.
>>
>> So the steps you seem to be following are:
>>
>> i) debug lock/unlock api for pool to identify mutating code.  (Useful in
>> perpetuity for regression tests.)
>> ii) set/restore api for pool (temporary).
>> iii) update the mutating code to use set.
>> iv) gradually get rid of the use of set/restore on a case by case basis.
>> v) remove the set/restore api
>>
>> There is an argument that set/restore shouldn't ever go into HEAD, but
>> is instead something solely useful to you while you do this work.  But
>> since this work is going to take some time I see no problem with this
>> going in on the understanding that it comes out again as soon as
>> possible.
> 
> 
> Yeah - I've been already thinking about this -
> I could probably make even API for dm_pool_set & restore purely internal -
> so only lvm would know about it - by copying internal structures.
> 
> So we would not need to expose this in public  libdm API for a while.
> 
> 
> And I've been also thinking about changing the places which are modifying
> 'read-only' VG structure members - but at this moment it's somewhat bigger patch.
> 
> My idea is - to use for this variable 'offset' inside volume_group structure,
> and to access it for read/write - one must deference it through array access
> over the exception store area (I'd stay with uint64_t data)
> 
> Depends on whether we accept this direction.
> 
> As for now it seems there is not so many accesses - so it looks like hopefully
> 'relatively' small amount of code needs to be changed.
> 
> If we would agree on the way we access them - it's probably easy to write
> before it hits upstream - to avoid hassles with internal structures.
> 


I should still mention here - that typical use-case of locked VG is to operate
on very limited set of LVs (for just linears - it's == 1)
- thus very short list of exceptions is usually restored (if some at all).

So the idea of restoring all fields of say 3 or more 8byte values of 7000LVs
would be surely more expensive (though it's obviously less then 8MB)

Also the code which would work on references instead of direct structure
members would look less fancy than it's now (As now only 'write operation'
requires 'wrapper').

So I think it's good to well specify what we really want to achieve - and what
are we going to sacrifice for what.
(I know the current API isn't the best - but as I said - it's been already
couple iteration on my own harddrive)

Zdenek



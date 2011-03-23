From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Mar 2011 15:43:04 +0100
Subject: [PATCH 1/6] Pool locking code
In-Reply-To: <1300888988.14527.28.camel@ubuntu>
References: <cover.1300828168.git.zkabelac@redhat.com>	
	<d2353d5f9081b6eed91ed788af173ddf88dd4bba.1300828168.git.zkabelac@redhat.com>
	<1300888988.14527.28.camel@ubuntu>
Message-ID: <4D8A06F8.3070807@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 23.3.2011 15:03, Joe Thornber napsal(a):
> On Tue, 2011-03-22 at 22:21 +0100, Zdenek Kabelac wrote:
>> Adding specific functions to lock and unlock pool, to modify
>> specific uint64_t*, and to revert all modified uint64_t back.
> 
>> +/* prevent modification of pool */
>> +int dm_pool_locked(struct dm_pool *p);
>> +int dm_pool_lock(struct dm_pool *p, unsigned count)
>> +	__attribute__((__warn_unused_result__));
>> +int dm_pool_unlock(struct dm_pool *p)
>> +	__attribute__((__warn_unused_result__));
>> +int dm_pool_set_uint64(struct dm_pool *p, uint64_t *addr, uint64_t new_value)
>> +	__attribute__((__warn_unused_result__));
>> +int dm_pool_restore(struct dm_pool *p, int check_crc)
>> +	__attribute__((__warn_unused_result__));
>> +
> 
> Hi Kabi,
> 
> I like what you're trying to do here.  But I don't really like the above
> interface, particularly the dm_pool_set_uint64() method which is going
> to be ugly to use.
> 
> Ideally I guess I'd prefer something like:
> 
>         struct dm_pool_snapshot;
>         
>         struct dm_pool_snapshot *dm_pool_take_snapshot(struct dm_pool *p);
>         void dm_pool_destroy_snapshot(struct dm_pool_snapshot *snap);
>         int dm_pool_compare(struct dm_pool *p, struct dm_pool_snapshot *snap);
>         int dm_pool_restore_snapshot(struct dm_pool *p, struct dm_pool_snapshot *snap, int release_subsequently_allocated_data);
>         
> You'd use the compare function within assertions to check nobody has
> changed a pool unexpectedly.  There's no concept of a locked pool, you
> don't have to change the existing pool code to check if you're locked.
> Also you don't need a special interface for changing data within a
> locked pool.
> 
> The simple way of implementing the above is to just make a copy of the
> pool data within the snapshot.  Which of course is a very slow op.  So
> could you give me an idea of the size of a typical pool when you are
> locking it?  How frequently do you lock?
> 

It's been my first idea - to copy all chunks to separate buffer - but the VG
mempool size for large VGs is actually quite big - thus doing always a
snapshot isn't performance optimal. I'm doing my tests with ~7000LV - and it
would be quite noticable to copy all the pool chunks with each use of it.

That's why I came with keeping only few separate values - which is way more
efficient in this case.

As you can see in patch 4,5,6 only very few modifications are being made to
the pool itself - so the restore is usually only for few uin64_t in exception
area.

I'm aware the API isn't the best - but it seems the most efficient I could
think of for now.

We may probably trade of the speed with mirroring whole mempool structure.
But I wanted to show - that only few stucture members are usually modified
during the lifetime of VG structure (thought yes - using the knowledge of the
_lv_postoder() where I intentionally disable the locking - as then I'd get
status of each LV modified - not very efficient with current exception store)

So basically -  lock is done when the VG is parsed for the first time.
(See Patch 3) - during the whole live of this shared VG (except for
_lv_postoder()) - it's kept locked. Thus with mprotect-ing enabled - it's
impossible to write to this pool without using  dm_pool_set() as you get
immediately segfault. It gets unlocked when it's being released to free vginfo
cache - or when it's droped because RW usage is needed.

It would be nice to have 'COW' in user space - but have no idea how to
implement this.

Zdenek



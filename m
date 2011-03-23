From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Mar 2011 15:54:04 +0100
Subject: [PATCH 1/6] Pool locking code
In-Reply-To: <1300888988.14527.28.camel@ubuntu>
References: <cover.1300828168.git.zkabelac@redhat.com>	<d2353d5f9081b6eed91ed788af173ddf88dd4bba.1300828168.git.zkabelac@redhat.com>
	<1300888988.14527.28.camel@ubuntu>
Message-ID: <4D8A098C.8060803@redhat.com>
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

Forget to answer the size question -  >8MB is allocated by the VG mempool when
set of simple linear 7200LVs on 1 PV are in use.

Also that's why I mention in my patchset that doing even quick crc hash
checksum is quite slow - I except full memcpy would be even slower - and I do
that only with finally pool unlock).

Zdenek



From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 25 Nov 2010 14:39:47 +0100
Subject: [PATCH 01/11] Add mda_slots field for PV info in the cache.
In-Reply-To: <4CEE6180.6000706@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>	<1290115945-27419-2-git-send-email-prajnoha@redhat.com>
	<4CEE6180.6000706@redhat.com>
Message-ID: <4CEE6723.4020301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/25/2010 02:15 PM +0100, Zdenek Kabelac wrote:
>> +struct metadata_area;

(ah, this line slipped from the older version of this patch, this line
is not needed anymore at this place, but that's a detail...)

> 
> I'm not really sure where we are heading with out  lvmcache.
> 
> I'd like to see rather complete removal of this part of code - once we will
> start work on thing like Petr's  lvmetad  - which would probably completely
> eliminate need of any cache.

Yes, that's a very good question - where are we heading with our cache? As I read
the lvmetad concept, it seemed to me that the daemon will just replace the actual
scanning phase and the code will ask the daemon to provide any info it has already
cached instead of firing the scan. Otherwise, everything would stay as we have
today (so the concept seems to be fine - to do as less surgery as possible). Which is
not a bad idea - since all this existing cache machinery is quite a complex. So we
need to do those changes in steps (iow, I don't think that removing the cache as it
is today completely and replacing it with totally different scheme is something
that we can do in a short time).

> 
> I think we should keep our lvmcache as simple as we can only to skip repeated
> open & read from device -  everything else should be kept in higher level.
> That could make future removal of this code much easier.
> 

What I've done here is that I used the cache to keep a few info that I need
(and since I haven't seen any rules as to how the cache should be used :)), I
sticked to that. Well, I just did the same what the older code did, but I moved
the update of the cache a little bit sooner in time... That's all.

Of course, I can avoid using the cache this way, but that would mean far more
changes to be done (for this interface to work). At least, it would mean consolidating
the use of "format instance" and change the structure and its use throughout the
code.

The logic of this patches would stay of course, what I need to decide (with respect
to this patchset, not the cache itself) is where to store this information, how to
'package' the info and how to handle it internally so I can access it easily.

So we would have structures for the cached information that would be only read, not
edited nor touched in any way. If there are any changes done, we throw away the cache
completely and read it again from the raw disk - we need to state the policy clearly
and follow it!

For now, I reused the cache structure. But sure, I can add something else so we can
avoid using the cache this way (it's just about replacing the carrier
of the information). We would have a "working copy" of the cache. Though that would
mean copying part of the information we already have in cache structures. This happens
already for the internal "format_instance". Unluckily, this structure is not suitable
for this patchset, so I would need to change it considerably, I think.

But yes, it could be done, but including far far more changes...

> I guess we already break this concept in few place - but we should rather fix
> those areas instead of add more hardwired functionality into cache level.

As I said above, let's state the policy and the rules for the cache use and
let's follow it ;)

Peter



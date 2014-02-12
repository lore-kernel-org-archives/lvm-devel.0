From: Brassow Jonathan <jbrassow@redhat.com>
Date: Wed, 12 Feb 2014 11:39:40 -0600
Subject: cache support
In-Reply-To: <0fff01cf276c$d059c8d0$710d5a70$@acm.org>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>	<52F205CA.1090807@redhat.com>	<0a3901cf22af$ae01d2d0$0a057870$@acm.org>	<52F2AD44.8030006@redhat.com>	<0a7b01cf22db$da3f56c0$8ebe0440$@acm.org>
	<A2CE00CC-6439-4A2E-A694-8E3B2656867B@redhat.com>
	<0fff01cf276c$d059c8d0$710d5a70$@acm.org>
Message-ID: <0C83CD55-18B6-4407-9A42-72F9D6C5683D@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Feb 11, 2014, at 3:04 PM, Paul B. Henson wrote:

>> From: Brassow Jonathan
>> Sent: Tuesday, February 11, 2014 9:24 AM
>> 
>> What do you think about caching a thin pool?  Then you would get the
>> benefit of caching for all of your LVs and you would get all the benefits
> of
>> thin and thin snapshots.
> 
> Hmm, I'm not that familiar with thin allocation in lvm. Basically, I would
> allocate the entire PV as a thin LV, attach my entire cache to that, and
> then create all of my production LV's with thin allocation out of the single
> thin LV? Interesting thought. I have sufficient storage for at least the
> midterm, my perhaps flawed understanding is that going with thin LV's
> introduces an extra layer of complexity and inefficiency versus regular
> allocation?

I'll let others weigh-in on the overhead of introducing thin-provisioning.  However, my experience is that the overhead is very small and the benefit is very large.

I imagine the steps being something like this:
# Create your VG with slow and fast block devices
1~> vgcreate vg /dev/slow_sd[abcdef]1 /dev/fast_sd[abcde]1

# Create data portion of your thin pool using all your slow devices
2~> lvcreate -l <all slow dev extents> -n thinpool vg /dev/slow_sd[abcdef]1

# Create the metadata portion of your thin pool
#  use fast devs to keep overhead down
#  use raid1 to provide redunancy
3~> lvcreate --type raid1 -l <1/1000th size of data LV> -n thinpool_metadata vg /dev/fast_sd[ab]1

# Create cache pool LV that will be used to cache the data portion of the thin pool
#  You can use 'writethrough' mode to speed up reads, but still have writes hit the slow dev
#  or you can create the data&metadata areas of the cachepool separate using raid and then
#  convert those into a cache pool... lots of options here to improve redundancy.  I'm working
#  on man page changes/additions to make this clear and simple.  For now, we'll just create
#  a cachepool simple LV.
4~> lvcreate --type cache_pool -L <desired cache size> -n cachepool vg /dev/fast_sd[abcdef]1

# Use the cache pool to create a cached LV of the thin pool data device
5~> lvconvert --type cache --cachepool vg/cachepool vg/thinpool

# The data portion of your 'thinpool' LV is now cached.
# Make the thinpool using the cached data LV 'thinpool' and the fast metadata LV 'thinpool_metadata'
6~> lvconvert --thinpool vg/thinpool --poolmetadata thinpool_metadata

You now have a very fast thin pool from which you will create thin volumes and snapshots.  Everything is cached with low overhead.

7~> lvcreate -T vg/thinpool -n my_lv1 -V 200G
8~> lvcreate -T vg/thinpool -n my_lv2 -V 200G
...

 brassow

N.B.  Note that you must specify '--with-cache=internal' when configuring LVM - cache is off by default until it is no longer considered experimental.  You should be using dm-cache kernel module version 1.3.0+.  Support for 'lvconvert --type cache[-pool]' was only just added this morning.




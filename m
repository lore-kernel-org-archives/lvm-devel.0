From: Mikulas Patocka <mpatocka@redhat.com>
Date: Sat, 29 May 2010 01:25:09 -0400 (EDT)
Subject: md_component_detection bug
Message-ID: <Pine.LNX.4.64.1005290111560.15553@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

I looked at that bug when lvm accesses devices with md metadata. I tracked 
it to lvm device cache.

The problem is this: I have /dev/md0 that is raid0 on two devices: 
/dev/sdc1 and /dev/sdd1 with 256KiB stripe. I have one pv and one vg on 
it. If I unload /dev/md0, lvm reads the metadata from /dev/sdc1 and starts 
thinking that /dev/sdc1 is the physical volume. Any manipulation with vg 
in this state may cause data corruption because the sector numbers on 
/dev/sdc1 don't match sector numbers on original /dev/md0.

Lvm has a filter that should suppress accessing devices with md 
superblocks, the filter is turned on with "md_component_detection = 1" and 
it is on by default.

However, the filter badly interacts with device cache 
/etc/lvm/cache/.cache, if the device is listed as valid in the cache, the 
md filter is not run on the device and lvm thinks that the device is 
valid. Thus, in my case, if I had "/dev/sdc1" in the cache, lvm skipped 
the check for md metadata and accessed the device as a valid pv.

I think Milan wrote the device cache, so I'm sending this to you, if not, 
forward it to the person who maintains the cache code.

Mikulas



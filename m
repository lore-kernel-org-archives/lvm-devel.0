From: Eric Ren <zren@suse.com>
Date: Fri, 19 May 2017 10:46:09 +0800
Subject: Wrong locking type on local VG when clvm is used?
Message-ID: <d24e1f13-4a0c-71f7-a4cb-bc3c7fda3bb7@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

With clvm used in HA cluster, I find a interesting problem - LVM protects *local* VG with 
cluster-locking (locking_type = 3).
This may bring locking error on local VG "testvg", which can be easily reproduced as follows:

clvmd is running...

# mkdir loopdevs
# cd loopdevs/
# dd if=/dev/zero of=disk1.raw count=1 bs=1G
# dd if=/dev/zero of=disk2.raw count=1 bs=1G
# losetup -f disk1.raw
# losetup -f disk2.raw
# mdadm --create --verbose /dev/md0 --level=1 -N md0 -n2 /dev/loop0 /dev/loop1
# vgcreate -cn testvg /dev/md0
# lvcreate -l100%FREE --name testlv testvg
       Logical volume "testlv" created.

so far so good...

# lvchange -an testvg/testlv
# mdadm --stop /dev/md0
# pvscan  or #clvmd -R to reload device cache
# mdadm --assemble --scan --name md0
# vgchange -ay testvg
       Error locking on node 1302cf30: Volume group for uuid not found:
lG7H2DJXIg6EYzYOYs03mFSXodWK91YZJp3QGiLLF66s4uHtwRPxDKe0LXstR54i

The problem is:
1) local VG takes cluster-locking in such scenario, as you can see in init_locking();
2) clvmd daemon keeps a device cache itself (lvmetad can not be used with clvmd),
so we need to refresh the device cache with 'clvmd -R' to reflect any device changes.

So, another workaround is to specify the locking_type on local VG in lvm command:
# vgchange -ay testvg --config 'global{locking_type=1}'
       1 logical volume(s) in volume group "testvg" now active

Looking a bit at the code, LVM decides the locking_type on command basis, i.e. wrapping
the command around with init_locking() and fin_locking(). So, I'm thinking if we can change
locking_type selection to VG basis. For example, "vgchange -ay local_vg cluster_vg", we can
decide the locking_type for each VG. Well, it's overkill if all the VGs are either local, or
cluster... Is this reasonable, or something worth to do?

I really want to hear your comment before I start to work on this:-)

Regards,
Eric




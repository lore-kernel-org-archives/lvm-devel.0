From: Ty! Boyack <ty@nrel.colostate.edu>
Date: Wed, 14 Jan 2009 22:23:53 -0700
Subject: iSCSI logout hangs LVM
Message-ID: <496EC869.2060803@nrel.colostate.edu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi folks,

I'm not sure if I'm seeing a bug in LVM, device mapper (dm-multipath), 
open-iscsi or udev, but this seems like the best place to start. 


I can cause pvscan to hang consistently with the following sequence of 
events:
1) run pvscan -- works OK
2) connect to iscsi disk -- works OK
3) run pvscan -- works OK, finds physical volume on iscsi disk
4) logout of iscsi disk -- works OK
5) run pvscan -- HANGS


If I run the (step 5) pvscan with 'strace -f /sbin/pvscan' the end of 
that trace is:

stat("/dev/dm-2", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
stat("/dev/dm-2", {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
open("/dev/dm-2", O_RDWR|O_DIRECT|O_NOATIME) = 4
fstat(4, {st_mode=S_IFBLK|0660, st_rdev=makedev(253, 2), ...}) = 0
ioctl(4, BLKBSZGET, 0x20043f0)          = 0
lseek(4, 12884836352, SEEK_SET)         = 12884836352
read(4,

and then the read hangs forever.

In my setup, the iscsi login/logout is to a single target with two 
portals, and dm-multipath us used to present one multi-path device.  
That device in this case is /dev/dm-2.  I can use that disk as a PV just 
fine -- it's in a VG and has a couple of LV's filled with test data.

I retried the sequence but only logged into one portal, so only one 
connection existed (hopefully bypassing dm-multipath) and had exactly 
the same problem.

I also tried waiting several minutes after logging out of the iSCSI disk 
before running pvscan, and that also hang.

It seems like the LVM database detects a new disk being inserted, but 
not removed.  I have not tried this on any other hot-swap disk system -- 
has anyone tried this with a USB or other removable disk?

Does anyone know if this is expected behavior?  Or is it a problem 
elsewhere, maybe with udev not doing something to indicate that the disk 
has been removed?  Or does LVM keep it's own internal database of where 
it's PV's are, and then later assume that they will still be there?

This is all being done on a Fedora 9 boxes with updated packages:
lvm2-2.02.33-11.fc9.x86_64
iscsi-initiator-utils-6.2.0.870-1.0.fc9.x86_64
device-mapper-1.02.24-11.fc9.x86_64
udev-124-2.fc9.x86_64
kernel-2.6.27.9-73.fc9.x86_64

I would appreciate any thoughts or suggestion on this!

-Ty!



-- 
-===========================-
  Ty! Boyack
  NREL Unix Network Manager
  ty at nrel.colostate.edu
  (970) 491-1186
-===========================-



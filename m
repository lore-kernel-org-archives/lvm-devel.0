From: Nir Soffer <nsoffer@redhat.com>
Date: Tue, 16 Oct 2018 23:59:45 +0300
Subject: Can't work normally after attaching disk volumes originally in a VG on another machine
In-Reply-To: <5AB52B8D020000F9000B14B9@prv-mh.provo.novell.com>
References: <5AB52B8D020000F9000B14B9@prv-mh.provo.novell.com>
Message-ID: <CAMRbyyuSO+LdfnESO_56GDKqGDAOXah0PXbfV0s3b3GOP0XJug@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Mar 23, 2018 at 11:30 AM Gang He <ghe@suse.com> wrote:

> Hello List,
>
> Since I am new to LVM area, but I got a problem about LVM can't work
> normally after attaching disk volumes originally in a VG on another machine.
> Then, I sent this problem to the list, to see if we can get a fix or there
> has been a fix.
> The problem is very easy to reproduce,
> 1) create two virtual machines(tb0307-nd1, tb0307-nd2), create two virtual
> disks.
>

Do you mean 2 logical volumes on the host?


> 2) attach two virtual disks to VM1(tb0307-nd1).
>

Are you attaching the logical volumes created on the host to the VM?


> tb0307-nd1:/# lsblk
> NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
> sr0     11:0    1  4.3G  0 rom
> vda    254:0    0   40G  0 disk
> ??vda1 254:1    0    4G  0 part [SWAP]
> ??vda2 254:2    0 23.6G  0 part /
> ??vda3 254:3    0 12.4G  0 part /home
> vdb    254:16   0   40G  0 disk
> vdc    254:32   0   20G  0 disk <<= disk1
> vdd    254:48   0   20G  0 disk <<= disk2
> 3) pvcreate two virtual disks, and add them to vg1.
> tb0307-nd1:/# pvcreate /dev/vdc
>   Physical volume "/dev/vdc" successfully created.
> tb0307-nd1:/# pvcreate /dev/vdd
>   Physical volume "/dev/vdd" successfully created.
> tb0307-nd1:/# pvs
>   PV         VG Fmt  Attr PSize  PFree
>   /dev/vdc      lvm2 ---  20.00g 20.00g
>   /dev/vdd      lvm2 ---  20.00g 20.00g
> tb0307-nd1:/# vgcreate vg1 /dev/vdc /dev/vdd
> 4) disconnect two virtual disks from VM1, and attach disk1 to
> VM2(tb0307-nd2).
>

If /dev/vdc and /dev/vdd are logical volumes on the host, lvm on the host
just scanned these lvs and discovered the metadata created within the VM.


> 5) delete vg1, create vg2, and add disk1 to vg2.
> tb0307-nd2:~ # pvs
>   WARNING: Device for PV t6gjHU-dtY4-th5O-A0mr-5OEC-R1ZK-TPQgIh not found
> or rejected by a filter.
>   PV         VG  Fmt  Attr PSize  PFree
>   /dev/vdc   vg1 lvm2 a--  20.00g 20.00g
>   [unknown]  vg1 lvm2 a-m  20.00g 20.00g
> tb0307-nd2:~ # pvremove /dev/vdc
>   WARNING: Device for PV t6gjHU-dtY4-th5O-A0mr-5OEC-R1ZK-TPQgIh not found
> or rejected by a filter.
>   PV /dev/vdc is used by VG vg1 so please use vgreduce first.
>   (If you are certain you need pvremove, then confirm by using --force
> twice.)
>   /dev/vdc: physical volume label not removed.
> tb0307-nd2:~ # vgreduce --removemissing vg1
>   WARNING: Device for PV t6gjHU-dtY4-th5O-A0mr-5OEC-R1ZK-TPQgIh not found
> or rejected by a filter.
>   Wrote out consistent volume group vg1.
> tb0307-nd2:~ # pvs
>   PV         VG  Fmt  Attr PSize  PFree
>   /dev/vdc   vg1 lvm2 a--  20.00g 20.00g
> tb0307-nd2:~ # vgremove vg1
>   Volume group "vg1" successfully removed
> tb0307-nd2:~ # vgcreate vg2 /dev/vdc
>   Volume group "vg2" successfully created
> tb0307-nd2:~ # vgs
>   VG  #PV #LV #SN Attr   VSize  VFree
>   vg2   1   0   0 wz--n- 20.00g 20.00g
> tb0307-nd2:~ # pvs
>   PV         VG  Fmt  Attr PSize  PFree
>   /dev/vdc   vg2 lvm2 a--  20.00g 20.00g
>
> 6) attach disk2 to VM2(tb0307-nd2), the vg on VM2 looks abnormal.
> tb0307-nd2:~ # pvs
>   WARNING: Device for PV JJOL4H-kc0j-jyTD-LDwl-71FZ-dHKM-YoFtNV not found
> or rejected by a filter.
>   PV         VG  Fmt  Attr PSize  PFree
>   /dev/vdc   vg2 lvm2 a--  20.00g 20.00g
>   /dev/vdd   vg1 lvm2 a--  20.00g 20.00g
>   [unknown]  vg1 lvm2 a-m  20.00g 20.00g
> tb0307-nd2:~ # vgs
>   WARNING: Device for PV JJOL4H-kc0j-jyTD-LDwl-71FZ-dHKM-YoFtNV not found
> or rejected by a filter.
>   VG  #PV #LV #SN Attr   VSize  VFree
>   vg1   2   0   0 wz-pn- 39.99g 39.99g
>   vg2   1   0   0 wz--n- 20.00g 20.00g
>
> 7) reboot VM2, the result looks worse (vdc disk belongs to two vg).
> tb0307-nd2:/mnt/shared # pvs
>   PV         VG  Fmt  Attr PSize  PFree
>   /dev/vdc   vg1 lvm2 a--  20.00g     0
>   /dev/vdc   vg2 lvm2 a--  20.00g 10.00g
>   /dev/vdd   vg1 lvm2 a--  20.00g  9.99g
>
>
> It looks like LVM2 meta consistency problem? please help to take a look.
>

If you want to attach logical volumes to VMs, you must make sure that these
volumes are not accessible to LVM on the host. A good way to achieve this is
to setup devices:filter in lvm.conf so LVM can access only the disks
required
by the host (e.g. /dev/sda2).

Check this for more info on this problem:
https://ovirt.org/blog/2017/12/lvm-configuration-the-easy-way/

Nir
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20181016/ff99af9a/attachment.htm>

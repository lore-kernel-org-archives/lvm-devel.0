From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Apr 2019 17:17:24 +0200
Subject: lvcreate hangs forever and udev work timeout
In-Reply-To: <CAKM4AewQpxTmRZ=GNqCaEb0yL=5ukVUNrhWJ-bFnXeaFoiJh4Q@mail.gmail.com>
References: <CAKM4AeyUFr1PQB8jSVR2iaa9tTozwij0cCOfFWdTaX+txru0mg@mail.gmail.com>
	<00ae05c4-5ad8-1137-076d-57a24f093fd3@redhat.com>
	<CAKM4Aexiy-iXuNs6Nn-JudytKQRizovjg_3TVL0_xn_7+e3wXg@mail.gmail.com>
	<CAKM4Aezz1N14MuLcQdJkzvrLFf4f2h-H+UjgL2jVRrBhxVOPow@mail.gmail.com>
	<CAKM4AewQpxTmRZ=GNqCaEb0yL=5ukVUNrhWJ-bFnXeaFoiJh4Q@mail.gmail.com>
Message-ID: <a719d149-c9af-98e3-8983-5418584b11b0@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12. 04. 19 v 17:03 Eric Ren napsal(a):
> Hi,
> 
>> Although the /dev/dm-26 is visible, but the device seems not ready in kernel.
> 
> Sorry, it's not:
> 
> [root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup info /dev/dm-26
> Device dm-26 not found
> Command failed.
> 
> [root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup info /dev/dm-25
> Name:              vg0-21
> State:             ACTIVE
> Read Ahead:        256
> Tables present:    LIVE
> Open count:        0
> Event number:      0
> Major, minor:      252, 25
> Number of targets: 1
> UUID: LVM-PIFRRbKrhSqE5j6Q8jfk1qJJ1TNFPUI2SzDoe3z1azKH6HAOPsleizy3LozEMJus
> 
> [root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup status | grep vg0-22
> vg0-22: 0 20971520 thin 274432 20971519
> 
> [root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup info vg0-22
> Name:              vg0-22
> State:             ACTIVE
> Read Ahead:        256
> Tables present:    LIVE
> Open count:        0
> Event number:      0
> Major, minor:      252, 26
> Number of targets: 1
> UUID: LVM-PIFRRbKrhSqE5j6Q8jfk1qJJ1TNFPUI2YMnwPdLNF3JggAzXGwaFujcPePyOAeqd
> 

Hi

Hmm would it be possible that associated thin pool would be in some erroneous 
condition - i.e. out-of-space - or processing some resize ?
This likely could result into some significant processing delay ?

Since you are using very ancient lvm2  (2.02.130) we have heavily improved 
logic for such pools over the time...


Zdenek



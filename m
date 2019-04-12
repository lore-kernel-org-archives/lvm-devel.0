From: Eric Ren <renzhengeek@gmail.com>
Date: Fri, 12 Apr 2019 23:03:46 +0800
Subject: lvcreate hangs forever and udev work timeout
In-Reply-To: <CAKM4Aezz1N14MuLcQdJkzvrLFf4f2h-H+UjgL2jVRrBhxVOPow@mail.gmail.com>
References: <CAKM4AeyUFr1PQB8jSVR2iaa9tTozwij0cCOfFWdTaX+txru0mg@mail.gmail.com>
	<00ae05c4-5ad8-1137-076d-57a24f093fd3@redhat.com>
	<CAKM4Aexiy-iXuNs6Nn-JudytKQRizovjg_3TVL0_xn_7+e3wXg@mail.gmail.com>
	<CAKM4Aezz1N14MuLcQdJkzvrLFf4f2h-H+UjgL2jVRrBhxVOPow@mail.gmail.com>
Message-ID: <CAKM4AewQpxTmRZ=GNqCaEb0yL=5ukVUNrhWJ-bFnXeaFoiJh4Q@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

> Although the /dev/dm-26 is visible, but the device seems not ready in kernel.

Sorry, it's not:

[root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup info /dev/dm-26
Device dm-26 not found
Command failed.

[root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup info /dev/dm-25
Name:              vg0-21
State:             ACTIVE
Read Ahead:        256
Tables present:    LIVE
Open count:        0
Event number:      0
Major, minor:      252, 25
Number of targets: 1
UUID: LVM-PIFRRbKrhSqE5j6Q8jfk1qJJ1TNFPUI2SzDoe3z1azKH6HAOPsleizy3LozEMJus

[root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup status | grep vg0-22
vg0-22: 0 20971520 thin 274432 20971519

[root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup info vg0-22
Name:              vg0-22
State:             ACTIVE
Read Ahead:        256
Tables present:    LIVE
Open count:        0
Event number:      0
Major, minor:      252, 26
Number of targets: 1
UUID: LVM-PIFRRbKrhSqE5j6Q8jfk1qJJ1TNFPUI2YMnwPdLNF3JggAzXGwaFujcPePyOAeqd

Regard.



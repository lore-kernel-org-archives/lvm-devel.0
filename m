From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Apr 2019 17:01:23 +0200
Subject: lvcreate hangs forever and udev work timeout
In-Reply-To: <CAKM4Aezz1N14MuLcQdJkzvrLFf4f2h-H+UjgL2jVRrBhxVOPow@mail.gmail.com>
References: <CAKM4AeyUFr1PQB8jSVR2iaa9tTozwij0cCOfFWdTaX+txru0mg@mail.gmail.com>
	<00ae05c4-5ad8-1137-076d-57a24f093fd3@redhat.com>
	<CAKM4Aexiy-iXuNs6Nn-JudytKQRizovjg_3TVL0_xn_7+e3wXg@mail.gmail.com>
	<CAKM4Aezz1N14MuLcQdJkzvrLFf4f2h-H+UjgL2jVRrBhxVOPow@mail.gmail.com>
Message-ID: <d80784b1-539f-911f-de84-32fcbd36e9e7@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12. 04. 19 v 16:56 Eric Ren napsal(a):
> Hi,
> 
>> Since the /dev/dm-x has been created, I don't understand what it waits
>> udev to do?
>> Just waits udev rules to create device symbol links?
> 
> Although the /dev/dm-26 is visible, but the device seems not ready in kernel.
> 
> [root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup udevcookies
> Cookie       Semid      Value      Last semop time           Last change time
> 0xd4d0b57    225214464  2          Fri Apr 12 17:33:14 2019  Fri Apr
> 12 17:33:14 2019
> 
> [root at iZuf6dbyd7ede51sykedamZ ~]# dmsetup info /dev/dm-26
> Device dm-26 not found
> Command failed.
> 
> [root at iZuf6dbyd7ede51sykedamZ ~]# ls -l /dev/dm-26
> brw-rw---- 1 root disk 252, 26 4?  12 17:33 /dev/dm-26
>


Is that happening on any modern distro ??

AFAIK  no udev rule should ever by executed on DM device with empty table...
udev rules are detecting this state and should avoid DM device until it has 
resumed table.

Or is this same race when udev rule is accessing some device while device is 
being changed ?

Zdenek



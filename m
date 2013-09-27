From: Gabriel de Perthuis <g2p.code@gmail.com>
Date: Fri, 27 Sep 2013 15:56:40 +0200
Subject: [PATCH] Install to LVM PVs
In-Reply-To: <52457EA1.10804@gmail.com>
References: <l1ulib$iun$1@ger.gmane.org>
	<5243F5FF.4000804@gmail.com>	<52456056.1030101@gmail.com>
	<52457EA1.10804@gmail.com>
Message-ID: <52458E98.9000306@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Le 27/09/2013 14:48, Vladimir '?-coder/phcoder' Serbinenko a ?crit :
> On 27.09.2013 12:39, Gabriel de Perthuis wrote:
>> Le 26/09/2013 10:53, Vladimir '?-coder/phcoder' Serbinenko a ?crit:
>>> On 25.09.2013 14:39, Gabriel de Perthuis wrote:
>>>> Hello,
>>>> This patch lets grub install to a reserved area in LVM physical volumes.
>>>> These bootloader areas can be created with LVM 2.02.99 and the
>>>> --bootloaderareasize argument to pvcreate and vgconvert.
>>>> I tested it in QEMU, installing to and booting a disk that contains a PV
>>>> and no partition table.
>>>>
>>> This is not how the use of this area was imagined. There are couple of
>>> subtleties which your patch didn't take in account.
>>> Currently there is joint developpement with LVM guys but it wasn't
>>> published yet.
>>
>> For anyone else who may be interested, apparently patches exist and are
>> waiting for Peter Rajnoha to finish them.  They haven't been posted or
>> discussed publicly and I've never seen them.
>>
>> According to Vladimir:
>>> the zone will be subdivided to cover more cases and the agreement was
>> to use "pvs" to get offsets rather than having own code for this
>>
>> As shipped in 2.02.99, pvs exposes exactly one ba_start/ba_size area.
>> Other areas will have to use extra extension fields and extra fields in
>> the pvs output, to be compatible with released versions of LVM.

> No, you didn't understand: this area will have another header, GRUB one
> which will subdivide it. LVM gives us area and we take care of subdivision.

Or you could split the task in two: embed Grub on PVs, like it does on
partition tables, ext2-ext4, Btrfs; then add advanced embedding that
does some mini-partitioning of embedding areas.

The first task is really easy and brings an immediate benefit in making
LVM-only disks bootable.

I don't feel qualified to discuss the second task, because I'm not
seeing the use case.  I don't think it's been brought up.



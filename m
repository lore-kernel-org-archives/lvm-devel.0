From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 2 Jun 2018 21:30:56 +0200
Subject: lvthin: Why does vg/pool sit on top of vg/pool-tpool?
In-Reply-To: <alpine.LRH.2.11.1806012358010.22315@mail.ewheeler.net>
References: <alpine.LRH.2.11.1806012358010.22315@mail.ewheeler.net>
Message-ID: <b7f87527-d6f3-a421-81fd-e23d11911817@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 2.6.2018 v 02:01 Eric Wheeler napsal(a):
> Hello all,
> 
> Today I noticed that data/pool0 is a linear DM target backed by
> data-pool0-tpool:
> 
> brw-rw----. 1 root disk 253,    8 May 23 10:40 /dev/mapper/data-pool0
> brw-rw----. 1 root disk 253,    6 May 30 15:45 /dev/mapper/data-pool0_tdata
> brw-rw----. 1 root disk 253,    5 May 30 15:45 /dev/mapper/data-pool0_tmeta
> brw-rw----. 1 root disk 253,    7 May 30 15:45 /dev/mapper/data-pool0-tpool
> 
> data-pool0-tpool: 0 188743680 thin-pool 253:5 253:6 128 0 0
> data-pool0_tdata: 0 188743680 linear 252:16 322560
> data-pool0_tmeta: 0 2097152 linear 252:16 189066240
> data-pool0: 0 188743680 linear 253:7 0
> 
> 
> I noticed that /sys/block/dm-8/holders/ is empty, so nothing is using it.
> 
> What is pool0 used for?
> 
> Does LVM somehow use the linear pool0 volume internally?
> 

Hi

It's more a technical support to match  'activate' state of thin-pool.

We can have 'stand-alone' active thin-pool (no thinLV active)
(lvchange -ay vg/pool)

or pool is actived 'hiddenly' as volume needed by thinLV.
(lvchange -ay vg/thinLV)

To keep difference persistent we use this 'artificial' linear
device which just holds thin-pool open and prevents it's automatic shutdown 
with last thinLV deactivation as this may be 'unwanted' in case of large 
thin-pool with huge metadata sets.

(I.e. you deactive last thinLV1 and activate another thinLV2 in your VG and 
there would be significant delay cause by unnecessary time to shut-down
thin-pool and its repeated activation, with all metadata parsing and checking....)

This way user can select which way is more preferable - and either activate
thin-pool separately or just activate thinLVs and thin-pool will go away 
automatically with last thinLV deactivation)

Linear device itself is marker 'private' in udevDB and no one is supposed to 
be using it.

There could be some other solutions that avoids this artificial
device - but those would complicate number of other things
(i.e. ATM lvm is not using ANY information from filesystem to work with device 
state)

Regards

Zdenek







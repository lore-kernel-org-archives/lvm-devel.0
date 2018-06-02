From: Eric Wheeler <lvm-devel@lists.ewheeler.net>
Date: Sat, 2 Jun 2018 00:01:46 +0000 (UTC)
Subject: lvthin: Why does vg/pool sit on top of vg/pool-tpool?
Message-ID: <alpine.LRH.2.11.1806012358010.22315@mail.ewheeler.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello all,

Today I noticed that data/pool0 is a linear DM target backed by 
data-pool0-tpool:

brw-rw----. 1 root disk 253,    8 May 23 10:40 /dev/mapper/data-pool0
brw-rw----. 1 root disk 253,    6 May 30 15:45 /dev/mapper/data-pool0_tdata
brw-rw----. 1 root disk 253,    5 May 30 15:45 /dev/mapper/data-pool0_tmeta
brw-rw----. 1 root disk 253,    7 May 30 15:45 /dev/mapper/data-pool0-tpool

data-pool0-tpool: 0 188743680 thin-pool 253:5 253:6 128 0 0 
data-pool0_tdata: 0 188743680 linear 252:16 322560
data-pool0_tmeta: 0 2097152 linear 252:16 189066240
data-pool0: 0 188743680 linear 253:7 0


I noticed that /sys/block/dm-8/holders/ is empty, so nothing is using it. 

What is pool0 used for?

Does LVM somehow use the linear pool0 volume internally?

--
Eric Wheeler



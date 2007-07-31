From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 31 Jul 2007 15:13:09 -0500
Subject: [PATCH 0 of 2] Mirror argument changes.
Message-ID: <1185912789.18824.10.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've made some changes to the mirror logging arguments for lvcreate and
lvconvert.  Rather than using '--corelog' to specify in-memory logging
and relying on the fact that it wasn't specified to infer disk logging,
I've added the '--log' argument.

Examples:
$> lvcreate -m1 --log core ...
$> lvcreate -m1 --log disk ...

$> lvconvert --log core ...
$> lvconvert --log disk ...

The old ways still work.  '--corelog' is interpreted as '--log core'.
The nice thing is that you no longer need to specify a '--mirrors'
argument to lvconvert if you are not changing the number of mirrors.
Additionally, it makes it more clear when converting from core logging
to disk logging while not changing the mirror count.

Old way (two-way core mirror to two-way disk mirror):
$> lvconvert -m1 vg/lv

New way:
$> lvconvert --log disk vg/lv

I've also tried to clean-up the mirror convert code a little.

 brassow



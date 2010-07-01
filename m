From: Petr Rockai <prockai@redhat.com>
Date: Thu, 01 Jul 2010 12:33:29 +0200
Subject: [RFC] remove the persistent filter
In-Reply-To: <87aaqcjjvc.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Wed, 30 Jun 2010 23:22:47 +0200")
References: <87aaqcjjvc.fsf@twilight.int.mornfall.net.>
Message-ID: <87pqz7ij9i.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again,

Petr Rockai <prockai@redhat.com> writes:
> I believe this may address at least RHBZ 606931 and possibly other BZs,
> and a deadlock we have reproduced locally on our bar cluster (which is
> not in bugzilla, as far as I know). The bug could certainly cause a lot
> of grief...
I have noticed that Mikul?? ran into a similar problem where real
filters are being skipped due to the persistent one. I am wondering what
is the actual performance improvement from the persistent filter?

Let's look at the individual cases:

- sysfs&proc: persistent only helps if it prevents *any* fall-through to
  real filters... this does not seem to be happening in practice;
  i.e. no benefit for sysfs
- regex: minimal to no benefit
- md: persistent saves a read on devices that get passed through this;
  however, this is dangerous as per RHBZ 598135
- lvm/suspended: this is outright wrong as per parent post
- lvm/partition: similar to the md case: saves IO in the good case,
  produces incorrect results sometimes

Basically, the persistent device cache is responsible for a few corner
cases (related to 598135 where the cache is out of sync with reality)
and a few bugs where the benefit of the persistent cache would be
nonexistent anyway.

Overall, we have a modest reduction in IO to non-LVM devices in exchange
for a couple deadlock and data corruption bugs. We can work around some
of those, but I reckon that the whole idea of the persistent cache is a
misfeature.

The only cases where this makes any sense is MD detection and partition
table detection (as per above; other filters don't issue IO to the
device and are simply too cheap to optimise in this way), with at least
the MD case being prone to introducing data corruption. This leaves
partition table detection, which only happens on a subset of the devices
and could be optimised for the positive case by looking into sysfs, eg.

So I think there are two basic options: either we can move the
persistent device filter down the chain to only cover filters where it
makes sense, or disable it altogether. I am not very fond of the option
#3, keep adding workarounds similar to the parent post.

Yours,
   Petr.



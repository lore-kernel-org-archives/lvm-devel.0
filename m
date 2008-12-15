From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 15 Dec 2008 19:37:53 +0000
Subject: Re: udev lvm permisions
In-Reply-To: <ac3eb2510812151038i7f8a459bo16e1906cfe39a9d9@mail.gmail.com>
References: <1229356523.21463.5.camel@quest>
	<1229360539.15208.5.camel@x61.fubar.dk>
	<1229360818.21463.7.camel@quest>
	<ac3eb2510812150914n7231a1afvb2719187f61b7c30@mail.gmail.com>
	<1229361483.21463.14.camel@quest>
	<ac3eb2510812150919x3e67f46fi4a14fadb0659c497@mail.gmail.com>
	<1229363958.21463.17.camel@quest>
	<ac3eb2510812151019i2ad8f0ebw8f9dcbf21108ef3f@mail.gmail.com>
	<1229365310.21463.20.camel@quest>
	<ac3eb2510812151038i7f8a459bo16e1906cfe39a9d9@mail.gmail.com>
Message-ID: <20081215193753.GG19917@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Dec 15, 2008 at 07:38:31PM +0100, Kay Sievers wrote:
> In fact, it's good that you started shipping these patches, so it
> shows how stuff should work. And it hopefully puts some pressure on
> the guys who should fix their stuff after all these years. Hint, hint
> to someone in the Cc: list. :)
 
Well let's try to summarise how far we got in those discussions:

1) udev able to query device-mapper to determine what the /dev/mapper
entry should be called.
- udev uses dmsetup.  Sorted.

2) udev able to query device-mapper to determine what the link should be
called.
- udev uses dmsetup, checks for the LVM prefix on the UUID then either
splits the name into components (vgname+lvname+layer) itself (remembering
to unquote doubled hyphens) or calls out to LVM2 to do that.  (There
may be some sequencing issues here.)

3) udev able to determine whether a link needs to exist in /dev/<vgname> or not
- work on the basis that the requirement is having the LVM uuid prefix and
  having no 'layer' in the name.  (This may change when we support internal
  stacking better.)

4) lvm2 able to sleep until udev has completed a particular sequence of async
operations (without second-guessing udev and looking if the right things have
appeared in /dev)
- unresolved.

Alasdair
-- 
agk at redhat.com



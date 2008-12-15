From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 15 Dec 2008 20:29:41 +0000
Subject: Re: udev lvm permisions
In-Reply-To: <1229372059.15208.63.camel@x61.fubar.dk>
References: <1229360818.21463.7.camel@quest>
	<ac3eb2510812150914n7231a1afvb2719187f61b7c30@mail.gmail.com>
	<1229361483.21463.14.camel@quest>
	<ac3eb2510812150919x3e67f46fi4a14fadb0659c497@mail.gmail.com>
	<1229363958.21463.17.camel@quest>
	<ac3eb2510812151019i2ad8f0ebw8f9dcbf21108ef3f@mail.gmail.com>
	<1229365310.21463.20.camel@quest>
	<ac3eb2510812151038i7f8a459bo16e1906cfe39a9d9@mail.gmail.com>
	<20081215193753.GG19917@agk.fab.redhat.com>
	<1229372059.15208.63.camel@x61.fubar.dk>
Message-ID: <20081215202941.GK19917@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Dec 15, 2008 at 03:14:19PM -0500, David Zeuthen wrote:
> > 1) udev able to query device-mapper to determine what the /dev/mapper
> > entry should be called.
> > - udev uses dmsetup.  Sorted.
> Just a small detail, As I said here
> I don't think this is sorted until device-mapper / LVM ships with actual
> udev rules. Yes, I'm nit-picking, sorry.

Sure - I'm not meaning by that that the change has been made:
I'm meaning there are no further technical problems to solve.

LVM2/device-mapper will not ship with the udev rules until *all* those
problems are resolved i.e. until the process works correctly.
 
Alasdair
-- 
agk at redhat.com



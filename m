From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 15 Dec 2008 19:51:08 +0000
Subject: Re: udev lvm permisions
In-Reply-To: <20081215193753.GG19917@agk.fab.redhat.com>
References: <1229360539.15208.5.camel@x61.fubar.dk>
	<1229360818.21463.7.camel@quest>
	<ac3eb2510812150914n7231a1afvb2719187f61b7c30@mail.gmail.com>
	<1229361483.21463.14.camel@quest>
	<ac3eb2510812150919x3e67f46fi4a14fadb0659c497@mail.gmail.com>
	<1229363958.21463.17.camel@quest>
	<ac3eb2510812151019i2ad8f0ebw8f9dcbf21108ef3f@mail.gmail.com>
	<1229365310.21463.20.camel@quest>
	<ac3eb2510812151038i7f8a459bo16e1906cfe39a9d9@mail.gmail.com>
	<20081215193753.GG19917@agk.fab.redhat.com>
Message-ID: <20081215195108.GJ19917@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Dec 15, 2008 at 07:37:53PM +0000, Alasdair G Kergon wrote:
> 1) udev able to query device-mapper to determine what the /dev/mapper
> entry should be called.
> - udev uses dmsetup.  Sorted.
 
BTW Milan sent me a patch today to make name and uuid available in sysfs.

Alasdair
-- 
agk at redhat.com



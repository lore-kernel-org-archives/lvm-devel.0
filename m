From: David Zeuthen <davidz@redhat.com>
Date: Mon, 15 Dec 2008 15:09:47 -0500
Subject: Re: [lvm-team] Soliciting feature requests for development of an LVM library / API
In-Reply-To: <20081215194541.GH19917@agk.fab.redhat.com>
References: <1227556378.8335.10.camel@localhost.localdomain>
	<1228490691.7218.64.camel@x61.fubar.dk>
	<ac3eb2510812050820x50eb14co43021c2836275c1d@mail.gmail.com>
	<1229131838.16499.55.camel@localhost.localdomain>
	<ac3eb2510812130628n782db746gab5c14186a928bce@mail.gmail.com>
	<20081213152328.GB19178@agk.fab.redhat.com>
	<ac3eb2510812150654m59118516o3a7ed00d9027f61d@mail.gmail.com>
	<20081215194541.GH19917@agk.fab.redhat.com>
Message-ID: <1229371787.15208.61.camel@x61.fubar.dk>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2008-12-15 at 19:45 +0000, Alasdair G Kergon wrote:
> Remind me - why does udev want to know about 'target type'?

The question is not so much why "udev" wants to know about it. Keep in
mind that udev is just a mechanism (a database). FWIW, the consumers of
the information in the udev database are

 - simple udev rules (shipped with the OS or written by users)
 - things like a desktop OS

As it is hard to imagine possible users that falls into these categories
it's a good idea to provide as much information as you can as long as
it's not prohibitively expensive to do so.

> Is it a hack so it can guess which program (lvm2, cryptsetup, multipath etc.)
> is responsible for creating the device?
> 
> We introduced a standard prefix on the UUID for this purpose instead.
> Next time we revise the ioctl interface it'll go in as a separate 'owning
> subsystem' field.  (Need to check if any of our packages still need this
> prefix adding.)

The reason someone (in this case the file manager in the desktop) might
want to know about the target type of a mapped device is such that we
can make an association between the cryto-block-device (could
be /dev/sdb1) and the unlocked clear text device (the mapped device)
such that we can paint just a single icon with either an open or locked
padlock. And implement all the policy too (like password dialogs).

     David




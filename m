From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 15 Dec 2008 19:45:41 +0000
Subject: Re: [lvm-team] Soliciting feature requests for development of an LVM library / API
In-Reply-To: <ac3eb2510812150654m59118516o3a7ed00d9027f61d@mail.gmail.com>
References: <1227556378.8335.10.camel@localhost.localdomain>
	<1228490691.7218.64.camel@x61.fubar.dk>
	<ac3eb2510812050820x50eb14co43021c2836275c1d@mail.gmail.com>
	<1229131838.16499.55.camel@localhost.localdomain>
	<ac3eb2510812130628n782db746gab5c14186a928bce@mail.gmail.com>
	<20081213152328.GB19178@agk.fab.redhat.com>
	<ac3eb2510812150654m59118516o3a7ed00d9027f61d@mail.gmail.com>
Message-ID: <20081215194541.GH19917@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remind me - why does udev want to know about 'target type'?

Is it a hack so it can guess which program (lvm2, cryptsetup, multipath etc.)
is responsible for creating the device?

We introduced a standard prefix on the UUID for this purpose instead.
Next time we revise the ioctl interface it'll go in as a separate 'owning
subsystem' field.  (Need to check if any of our packages still need this
prefix adding.)

Alasdair
-- 
agk at redhat.com



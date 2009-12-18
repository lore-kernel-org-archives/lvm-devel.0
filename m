From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Fri, 18 Dec 2009 12:54:30 -0800
Subject: [PATCH 2 of 4] Handle transient secondary mirror leg failures
In-Reply-To: <4B2BE44D.6090808@redhat.com>
References: <patchbomb.1260695922@localhost>
	<1e369d480df09d0fac6c.1260695924@localhost>
	<178B089F-0B8A-47B5-9DA8-75AC3ACE86EA@redhat.com>
	<4B2BC922.8040506@redhat.com> <20091218184940.GB23597@us.ibm.com>
	<4B2BE44D.6090808@redhat.com>
Message-ID: <20091218205430.GA24047@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui [tyasui at redhat.com] wrote:
> > IMHO, suspend/resume is doing two things if the kernel code blocks on
> > failure -- 1) letting the kernel module unblock 2) start resync. We
> > should separate those two actions. Maybe, we should do something here???
> > Have an ioctl to start resync or have a message to unblock....
> 
> I'm sorry I don't get your point to separate unblock and resync.
> Currently "unblock" is done by "suspend" and resync is done by "resume"
> We need to reset log_failure/leg_failre, but anything else?

Let us talk about suspend with noflush as the other case would fail the
I/O.  The suspend just REQUEUE's, so it really needs resume to send the
I/O down to a surviving leg. As far as the application goes, the I/O
gets blocked until the resume, anyway.

Also in do_writes(), we block any I/O that is going to a nosync region.
If I understand, The recent block on error patch just fails to do any
I/O on a "nosync" region. In other words, we don't entertain any mirror
with leg failures and still continue to function as a mirror!

We can reset log_failure/leg_failure in resume to make them work for now
as you say.

--Malahal.



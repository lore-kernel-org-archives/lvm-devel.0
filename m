From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 20 Jul 2010 09:20:34 -0500
Subject: [PATCH] check for running cluster log daemon, not just log module
In-Reply-To: <20100719210007.GC19063@agk-dp.fab.redhat.com>
References: <1279291187.4957.2.camel@hydrogen.msp.redhat.com>
	<20100716161656.GA6506@agk-dp.fab.redhat.com>
	<1F3F1266-F403-4350-8669-F3186B4EA0B9@redhat.com>
	<20100719210007.GC19063@agk-dp.fab.redhat.com>
Message-ID: <6AEE08E2-FFFC-40A3-993E-DF5764A15CC2@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The lock gets dropped if the process holding it dies, as I remember  
it.  This obviates the need to validate the PID.  Sure, a previous  
instance may have died and left the file in place, but the locks would  
have been release too - and this is what we are checking for.  I'm  
still not seeing what we gain - unless we can have the name of the  
executable to validate.  This would be the only thing - from my  
perspective - that would gain us anything.  However, you point out  
that this doesn't really matter, and I agree with you.

  brassow

On Jul 19, 2010, at 4:00 PM, Alasdair G Kergon wrote:

> The function is named 'daemon_is_running', so it really should
> still give the correct answer if the daemon is *not* running
> but a previous instance left the file behind for any reason.
> I.e. validate that the PID in the file does in fact still
> exist and have that lockfile open.
>
>>> Yes - check /proc/<pid>/fd/*  if available?
>
> Read pidfile to get PID.
>
> List /proc/<pid>/fd/* and check that one of them (a quick code
> audit might even enable you to guarantee which one and pass it
> in as another parameter) points back at the file.
>
> The daemon name doesn't really matter in this: if someone creates  
> other
> software that uses *our* lockfile then they've got bigger problems,  
> but yes,
> you could pass that in and check that too.
>
> Alasdair
>



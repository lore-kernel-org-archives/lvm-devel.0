From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 01 Dec 2008 21:26:08 -0500
Subject: [PATCH 1/4] Move guts of pvcreate into library area - prep for vgcreate.
In-Reply-To: <20081201135915.GB26097@agk.fab.redhat.com>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<20081130042620.GF13235@agk.fab.redhat.com>
	<1228057068.3315.33.camel@localhost.localdomain>
	<20081201135915.GB26097@agk.fab.redhat.com>
Message-ID: <1228184768.3256.25.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mon, 2008-12-01 at 13:59 +0000, Alasdair G Kergon wrote:
> On Sun, Nov 30, 2008 at 09:57:47AM -0500, Dave Wysochanski wrote:
> > On Sun, 2008-11-30 at 04:26 +0000, Alasdair G Kergon wrote:
> > > I'm a bit bothered that too much code may be getting dumped into the library here
> > > wholesale rather than getting broken up into separate calls.
> > > 
> > > - I don't think the library should be prompting, that should remain at tools level
> > > and the interface should allow for that.
> > > -- maybe yes_no_prompt needs some global mode (anaconda would set) to control
> > > whether it does anything or simply defaults to the value given in an additional
> > > parameter 
>  
> > Why global mode - why not just set 'force' and '-y' for the API call?  I
> > think this was similar to Thomas's argument - he always envisioned '-ff'
> > and '-y' on things like pvcreate.
> > To be specific, in pvcreate we prompt if:
> > 1) the device is already a PV
> > 2) we find an MD superblock
> > (and of course the user has not given the '-ff' and '-y')
> 
> To clarify: I mentioned two possible ways to proceed there.
> 
> 1) no prompting in the library (which was my original intention)
> => library calls are split at appropriate places
> In your example above, this would mean separate calls for the validation
> functions (which anaconda would also call) prior to the call
> that actually makes the change (which would not repeat the validation).
> 
I don't see how this is possible.  Are you suggesting we split the
validation into a separate API call(s), and let an app decide to call it
or not?

If you're not saying let the app decide, then if we split the validation
and the create APIs, the only way I can think of ensuring the app has
called the validation before calling the create is to somehow store a
"passed_validation" flag somewhere (maybe within struct cmd_context).
Seems kinda messy though since the "passed_validation" would depend on
the create parameters.

Maybe there is another way but I don't see it.


> 2) prompting within the library, with a guaranteed way for a caller
> to avoid it (e.g. a global setting that defaults to returning with
> an error whenever there would otherwise have been a prompt).
> In the pvcreate example, it would avoid returning with an error because when
> the equivalent of -ff and -y are given there would not be a prompt.
>  
This might be the only reasonable way to proceed.  This would be the
equivalent of a "--no" option without prompting I guess.



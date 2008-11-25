From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 25 Nov 2008 16:16:42 -0500
Subject: [PATCH] (7/11) API improvements
In-Reply-To: <87iqqd6rt0.fsf@eriador.mornfall.net>
References: <873aie3q69.fsf@eriador.mornfall.net>
	<1227499598.6608.27.camel@localhost.localdomain>
	<87iqqd6rt0.fsf@eriador.mornfall.net>
Message-ID: <1227647802.8335.66.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mon, 2008-11-24 at 16:56 +0100, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> > Although the comment explains the vg_exists() function may be just a
> > guess, it is misleading to have a function called "vg_exists()" that
> > takes a vg_t * and returns true of vg_t * is NULL.
> 
> It might be counterintuitive, but that's one of the reasons the function needs
> to exist. It's pretty likely that if people would try to implement that check
> themselves, they'd get it wrong.
> 
> > Also from what I can tell, all places that call vg_exists() is preceeded
> > immediately by a call to vg_read_error() which does the same check.
> 
> Yes, but you can't rely on that when designing an API. Requiring that
> vg_read_error() is checked before using vg_exists() is counterintuitive as
> well, and counterintuitive API is worse than counterintuitive implementation of
> certain details in it. Or so I think.
> 
You are right there - it is not good to assume API call sequence for
correctness.


> So if it was me, I'd keep that interface...
> 

Ok, let me think some more about this and the error code stuff.



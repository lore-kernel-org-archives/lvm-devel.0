From: Petr Rockai <prockai@redhat.com>
Date: Mon, 24 Nov 2008 16:56:43 +0100
Subject: [PATCH] (7/11) API improvements
In-Reply-To: <1227499598.6608.27.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Sun, 23 Nov 2008 23:06:38 -0500")
References: <873aie3q69.fsf@eriador.mornfall.net>
	<1227499598.6608.27.camel@localhost.localdomain>
Message-ID: <87iqqd6rt0.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> Although the comment explains the vg_exists() function may be just a
> guess, it is misleading to have a function called "vg_exists()" that
> takes a vg_t * and returns true of vg_t * is NULL.

It might be counterintuitive, but that's one of the reasons the function needs
to exist. It's pretty likely that if people would try to implement that check
themselves, they'd get it wrong.

> Also from what I can tell, all places that call vg_exists() is preceeded
> immediately by a call to vg_read_error() which does the same check.

Yes, but you can't rely on that when designing an API. Requiring that
vg_read_error() is checked before using vg_exists() is counterintuitive as
well, and counterintuitive API is worse than counterintuitive implementation of
certain details in it. Or so I think.

So if it was me, I'd keep that interface...

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation



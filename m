From: Tim Post <echo@echoreply.us>
Date: Tue, 16 Mar 2010 00:58:51 +0800
Subject: [PATCH] Remove the double open with same mode
In-Reply-To: <4B9DF6F2.5040403@redhat.com>
References: <ee77738483f149622d19.1268439476@localhost>
	<20100313041826.GB7267@agk-dp.fab.redhat.com>
	<4B9DF6F2.5040403@redhat.com>
Message-ID: <1268672331.4261.88.camel@tpost-desktop>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-03-15 at 09:59 +0100, Zdenek Kabelac wrote:
> On 13.3.2010 05:18, Alasdair G Kergon wrote:
> > On Fri, Mar 12, 2010 at 04:17:56PM -0800, Malahal Naineni wrote:
> >>  	if ((open("/dev/null", O_RDONLY) < 0) ||
> >> -	    (open("/dev/null", O_WRONLY) < 0) ||
> >>  	    (open("/dev/null", O_WRONLY) < 0))
> >>  		exit(EXIT_DESC_OPEN_FAILURE);
> > 
> > stdin, stdout, stderr
> > 
> > Alasdair
> > 
> 
> IMHO it's probably worth to add comment to code, so there will not be similar
> 'optimizations' proposed in the future.
> 
> Zdenek.

I don't see how its confusing?

Regards,
--Tim




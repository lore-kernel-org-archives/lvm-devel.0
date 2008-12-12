From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 11 Dec 2008 22:22:58 -0500
Subject: [PATCH 12/12] Remove init_full_scan_done(0) call after create_toolcontext().
In-Reply-To: <20081211231005.GM24785@agk.fab.redhat.com>
References: <1228965978-19132-1-git-send-email-dwysocha@redhat.com>
	<20081211231005.GM24785@agk.fab.redhat.com>
Message-ID: <1229052178.20795.38.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-12-11 at 23:10 +0000, Alasdair G Kergon wrote:

> > Is this a bug?  Why are we setting _full_scan_done = 0 here when we've
> > already read the config file(s) for the 'scan' and other variables, then
> > scanned the system for devices as shown above?  
> 
> We haven't scanned the system at that point.
> 
> This scanning code is certainly messy, but it will become 'legacy' when the
> udev integration work is done, so it's not worth spending much time on.
> (It's a while now since we've had a bug report against this scanning code
> so it's best not to change the behaviour of code paths.)
> 

You are right.  I don't know where I got lost in that code but I clearly
did because I could not reproduce the scanning from the persistent
filter file reading.  A simpler argument would have just started with 0
or 1 for _full_scan_done and explored alternatives.  As you say though,
it's not worth it!  ;-0



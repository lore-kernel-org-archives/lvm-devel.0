From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 19:36:31 +0100
Subject: [PATCH] (11/11) re-instantiate automatic VG recovery
Message-ID: <87fxme2amo.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Finally!

This one restores the functionality that has been severed from the toollib,
that is the automatic metadata recovery in case of running after an interrupted
commit. This could do with a better naming and all, but that will be dealt with
in later patches (in another series, I suppose).

All in all, this is a fairly big bundle, and hopefully it should hit CVS soon
after the dust from the device-mapper merge has settled. It is definitely work
in progress and there will be regressions. However, since it's now easier than
ever to write tests for the testsuite, using the new tools, I would welcome
this as a good opportunity to augment our suite with all the regressions we can
find that the bundle has created (and even more). This is essential to improve
confidence in new code and makes it a lot less hassle to change things. I have
been running the branch through our resident buildbot
(http://nevrast.englab.brq.redhat.com:8010/waterfall) for a while now -- and
it's pretty much green.

I would also like to thank everyone who's worked on the testsuite, it's already
been of great help in development -- and I hope it will become even much more
useful, as it covers more and more use-cases, bugs and, hopefully, all of our
favourite regressions.

Now, I'm done for. I have been staring at diffs just a little too long by now,
but I'll try to write up a summary on what still needs to be done, and some
ideas on how to approach that, in not-so-distant (I hope) future.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvmlib-recovery.diff
Type: text/x-diff
Size: 1924 bytes
Desc: lvmlib-recovery.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/d3811143/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation

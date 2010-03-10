From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 10 Mar 2010 12:53:17 +0000
Subject: PATCH: Replace mlockall() with interal implementation
In-Reply-To: <Pine.LNX.4.64.1003100334531.13100@hs20-bc2-1.build.redhat.com>
References: <4B87D947.4060300@redhat.com> <4B87F062.8090407@redhat.com>
	<4B90D58C.7090501@redhat.com>
	<Pine.LNX.4.64.1003100334531.13100@hs20-bc2-1.build.redhat.com>
Message-ID: <20100310125317.GC27306@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 10, 2010 at 04:07:46AM -0500, Mikulas Patocka wrote:
> First, you must understand the users' priorities:
> priority #1: the computer doesn't crash
> priority #2: lvm takes less memory
> priority #3: the user sees localized error messages
 
We *require* all 3 of those.
And you're not taking into account the relative likelihood of each, nor the
fact that different users have different priorities and we have to cater
for all of them.  E.g. if I have loads of memory on my system, #2 is
irrelevant to me and #1 (for reason of 'out of memory' which is what this
discussion is about is) may be so unlikely on my system I don't care about it.

> IMPOSSIBLE to prove that there will be no locale access in future glibc 
> versions. 

Of course - that's a ridiculous thing to expect!
We are not going to say to people "Sorry, we aren't prepared to give you
basic expected functionality X because even though it works today,
something outside this project team's direct control may change in
future and break it."

If we get new problems in future, we address them when they occur.  Just
as this particular problem is now being tackled.

Defensive programming is good of course, but not taken to the extreme of
removing useful functionality.


> Zdenek said that Alasdair's opinion is to solve these crashes only when 
> they happen. In my opinion, this approach is not good becase
> 1. you already hurt the user (cause crash) before starting to solve the 
> problem
> 2. if such crash happens, the user has no way to find out why, so he will 
> likely send a bug report "the machine hung when manipulating root LV and I 
> can't reproduce it" --- so linking this crash report to the mlocking 
> problem is impossible...
 
Actually no - such crashes should have characteristic signatures.
And as for 1, you only hurt the user if your testing didn't pick up the
potential problem, and while you'll never trap all problems in advance,
I am hoping we'll be able to put measures in place to give us a
reasonable chance of spotting regressions like that.

> See for example bug 193330 --- no one knew why the system crashed and it 
> was just closed because the crash couldn't be reproduced the developers 
> --- the crashes due to this selective mlock will be just like this :-(
 
Not so.  And that's a 2006 bug, and used '-v' which I don't think was
supported in a 'might run out of memory' case.  It was closed because
the reporter didn't know to obtain diagnostics from the crash.  No
different from many other bug reports on many other projects.  But if
failures are real software problems, they'll inevitably happen again to
someone else who *will* obtain diagnostics.

Anyway, enough hypotheticals for one day.

Alasdair



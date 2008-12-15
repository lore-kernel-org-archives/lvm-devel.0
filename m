From: Petr Rockai <prockai@redhat.com>
Date: Mon, 15 Dec 2008 16:56:20 +0100
Subject: [PATCH] (1/2) new library interface for vg_read
In-Reply-To: <1229104225.16499.21.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Fri, 12 Dec 2008 12:50:25 -0500")
References: <87y6ypcn7l.fsf@eriador.mornfall.net>
	<1229027813.20795.15.camel@localhost.localdomain>
	<87ljulbvgu.fsf@eriador.mornfall.net>
	<1229104225.16499.21.camel@localhost.localdomain>
Message-ID: <87r649a0uz.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Dave Wysochanski <dwysocha@redhat.com> writes:
> Well, doesn't this cause a bug in this path though for the !consistent
> case?  First patch drops the consistent variable in this vgremove path,
> but things like _process_one_vg() do not use the new APIs (which sets
> the proper error codes) until the second patch.  You mention in your
> patch intro this first patch should apply and make a completely workable
> LVM so I'm assuming you mean no bugs.
Oh, hm, you are apparently right. Interestingly enough, the presumably buggy
code does pass the testsuite, so something's wrong with the testsuite, I
suppose. It might be good to have a test triggering that problem. I will
re-split the patch and resubmit later today.

To jstava@:

Could you please apply the attached patch? Now lvm with this patch should break
down on certain error conditions. I won't be able to exactly tell you how to
reproduce the problem, or whether it's even possible from the commandline at
this time, but if there is a testcase, it'll likely include inconsistent
metadata. If it turns out to be too hard, feel free to leave it alone. You
might be able to find extra info in this thread on lvm-devel at .

-------------- next part --------------
A non-text attachment was scrubbed...
Name: new-all.diff
Type: text/x-diff
Size: 22464 bytes
Desc: new-all.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081215/baf57aec/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

PS: This version of the patch actually compiles, but has the abovementioned
bug. The previous failed to compile due to forgotten int vs uint32_t in
vg_check_status definition.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation

From: Brassow Jonathan <jbrassow@redhat.com>
Date: Tue, 22 Oct 2013 08:00:55 -0500
Subject: [PATCH]: Mirror: Fix hangs and lock-ups caused by attempting label reads of mirrors
In-Reply-To: <52664873.1060005@redhat.com>
References: <1382394852.4860.4.camel@f16> <52664873.1060005@redhat.com>
Message-ID: <01414C5C-7B2B-40EE-9A11-072F00268B85@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Oct 22, 2013, at 4:42 AM, Zdenek Kabelac wrote:

> Dne 22.10.2013 00:34, Jonathan Brassow napsal(a):
>> agk,
>> 
>> The patch below is designed to address bug 1009700:
>> https://bugzilla.redhat.com/show_bug.cgi?id=1009700
>> It is the simplest way with the most flexibility for users that I could
>> think of to handle the problem outside of doing the asynchronous label
>> reads.
>> 
> 
> 
> I believe the patch needs to go in different direction.
> 
> See the bug  https://bugzilla.redhat.com/show_bug.cgi?id=905028
> 
> Lvm2 should be smarter in it's scanning code and
> must avoid reading device it know it may block.
> 
> There are very similar problems i.e. with thin pools, so
> it's not practical to put in various hacks for individual
> targets.
> 
> The fix must be in the filter to skip known dm devices.

Yes, I've thought about that already.  One idea for a solution I had was to avoid reading DM devices that have UUID that indicate it is part of the VG being operated on.  That was a non-starter because at the point of the problem, we do not yet know the VGs UUID and therefore cannot use it as a filter.

As far as avoiding devices that are blocked, we already do that for mirrors - which is the problem I am trying to solve.  It is called lib/activate/dev_manager.c:'ignore_blocked_mirror_devices'.  In the header of the patch provided, I describe why this is not sufficient to solve the problem entirely.  To clean-up the code, we could put this function (and the whole of 'device_is_usable') into a filter of its own.  Again though, this doesn't solve the problem.

I like what you are saying.  I've been down that road.  This is why I've presented the solution as I have.

 brassow





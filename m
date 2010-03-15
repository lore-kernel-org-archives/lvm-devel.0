From: Milan Broz <mbroz@redhat.com>
Date: Mon, 15 Mar 2010 11:37:33 +0100
Subject: [PATCH] Fix segfault when destroying in-use filters in pvs -a.
In-Reply-To: <4B9A7253.3010201@redhat.com>
References: <1268257407-16371-1-git-send-email-mbroz@redhat.com>	<4B994B10.9080409@redhat.com>
	<4B9A7253.3010201@redhat.com>
Message-ID: <4B9E0DED.6040104@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/12/2010 05:56 PM, Takahiro Yasui wrote:
>>> Fix it by introducing simple reference counter and test
>>> it in refresh_filters() call.
>>>
>>> Fixes https://bugzilla.redhat.com/show_bug.cgi?id=571963
> 
> This patch worked fine in my test case, but I have one question about
> your patch. I assume that you added refresh_filters() because it was
> necessary, but this patch prevents filter from being refreshed if it
> is in use.
> 
> Don't we need to refresh the filter when in_use flag is decremented
> and becomes 0 after or in dev_iter_destroy()?

well, the patch is workaround. It should be correct fot _this_
one place.

The full refresh (including filter refresh) should be done in
scan_vgs_for_pvs() (before the iteration loop) so later refresh
should not be needed.
(So we should fix code to not full scan here in the first place...)

I see several more problems with repeated full refresh now,
so maybe some more intrusive solution will be needed.

Milan



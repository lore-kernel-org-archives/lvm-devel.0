From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 12 Mar 2010 11:56:51 -0500
Subject: [PATCH] Fix segfault when destroying in-use filters in pvs -a.
In-Reply-To: <4B994B10.9080409@redhat.com>
References: <1268257407-16371-1-git-send-email-mbroz@redhat.com>
	<4B994B10.9080409@redhat.com>
Message-ID: <4B9A7253.3010201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan,

On 03/11/10 14:57, Takahiro Yasui wrote:
> On 03/10/10 16:43, Milan Broz wrote:
>> Because pvs -a iterate throught the whole device cache
>> we should not refresh filters inside iteration.
>>
>> Fix it by introducing simple reference counter and test
>> it in refresh_filters() call.
>>
>> Fixes https://bugzilla.redhat.com/show_bug.cgi?id=571963

This patch worked fine in my test case, but I have one question about
your patch. I assume that you added refresh_filters() because it was
necessary, but this patch prevents filter from being refreshed if it
is in use.

Don't we need to refresh the filter when in_use flag is decremented
and becomes 0 after or in dev_iter_destroy()?

Thanks,
Taka



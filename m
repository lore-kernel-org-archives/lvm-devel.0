From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 26 Oct 2010 13:05:06 +0200
Subject: LVM2/daemons/clvmd clvmd.c
In-Reply-To: <20101026104619.GD29400@agk-dp.fab.redhat.com>
References: <20101026095704.18295.qmail@sourceware.org>
	<20101026104619.GD29400@agk-dp.fab.redhat.com>
Message-ID: <4CC6B5E2.7090003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26.10.2010 12:46, Alasdair G Kergon napsal(a):
> On Tue, Oct 26, 2010 at 09:57:04AM -0000, zkabelac at sourceware.org wrote:
>> +#ifdef __clang__
>>  		__builtin_unreachable();
>> +#endif
> 
> Please do not scatter #ifdefs like that through the code.
> If the standard /* NOTREACHED */ really doesn't work, then hide the
> ifdef in a header file and use a #define to make it available precisely
> where the compiler supports it, defining it to something empty
> elsewhere.

Yes - This patch only provides quick compilation hotfix - and I'll prepare
better solution later.

Zdenek



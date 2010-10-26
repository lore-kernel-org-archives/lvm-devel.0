From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 26 Oct 2010 16:14:58 +0200
Subject: [PATCH 0/5] Fix NULL dereference
In-Reply-To: <20101026135759.GL29400@agk-dp.fab.redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
	<20101026135759.GL29400@agk-dp.fab.redhat.com>
Message-ID: <4CC6E262.2010702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26.10.2010 15:57, Alasdair G Kergon napsal(a):
> On Tue, Oct 26, 2010 at 02:59:21PM +0200, Zdenek Kabelac wrote:
>> Updated patchset for NULL pointer dereferences issues reported by clang.
>>
>> Unlike the first version - this time less aggresive solution is used.
>> INTERNAL_ERRORs are reported in these moments (if they would ever happen),
>> and the execution path aborts when such conditions are met.
>> Previous version was rather ignoring these paths and could lead to 
>> unwanted execution of other code parts.
>  
> Well the ones I've looked at here seem to be more about dealing with
> shortcomings in the static analysis code rather than fixing real bugs.
> 


Some of them can never be triggered within current LVM code.
Static analyzer is currently incapable to model data structure behavior
to understand, that some settings can never happen and sometimes it creates
very complex code path to model NULL pointer at the end.
(Also instrumentation  nonnull would be handy here - but it's long term goal)

However my small patches here really just try to clean warning - the price for
checks seems to be quite low  and we do not need to look into analyzer output
again and again.

We may also put them into

#ifdef __clang__
#endif

section to avoid any runtime overheads - but I don't like spreading such
ifdefs everywhere.

I can also keep these patches in my private branch - to not be always bothered
with same error.

For now I did not want to spend too much time on this so I've rather fixed
easily and quickly what I've considered to be even worth to look at.

Of course deeper analysis here will require some time - so - placing them to
my low-prio background queue....

Zdenek



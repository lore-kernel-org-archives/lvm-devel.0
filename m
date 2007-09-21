From: Jim Meyering <jim@meyering.net>
Date: Fri, 21 Sep 2007 13:58:35 +0200
Subject: revised error output: Run ... --help for more information
In-Reply-To: <20070921115330.GX18444@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Fri, 21 Sep 2007 12:53:30 +0100")
References: <878x75cuy9.fsf@rho.meyering.net>
	<20070917190950.GM18444@agk.fab.redhat.com>
	<877imkfe84.fsf_-_@rho.meyering.net>
	<20070921115330.GX18444@agk.fab.redhat.com>
Message-ID: <87vea4dyc4.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> On Fri, Sep 21, 2007 at 01:30:03PM +0200, Jim Meyering wrote:
>>     $ ./lvchange
>>       Need 1 or more of -a, -C, -j, -m, -M, -p, -r, --resync, --refresh, --alloc, --addtag, --deltag or --monitor
>>       lvchange: Run `lvchange --help' for more information.
>
> So we should certainly drop the 'lvchange:' now from the second line of output.

Good.  It's already gone in my current sources.

>>       lvchange: Need 1 or more of -a, -C, -j, -m, -M, -p, -r, --resync, --refresh, --alloc, --addtag, --deltag or --monitor
>
> So should we add a new option (command_names = 2, perhaps)
> that only applies it to messages produced using log_error()
> rather than for all output?  [And make this the default setting.]
>
> Or do we only want it (roughly speaking) for EINVALID_CMD_LINE not for
> ECMD_FAILED?

Personally, I'd like the "command_name: " prefix
on all "real" diagnostic lines -- and that'd be consistent
with what other tools do.  In my experience, the "Run ... --help"
diagnostic is most useful on EINVALID_CMD_LINE failures.



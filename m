From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 21 Sep 2007 12:53:30 +0100
Subject: revised error output: Run ... --help for more information
In-Reply-To: <877imkfe84.fsf_-_@rho.meyering.net>
References: <878x75cuy9.fsf@rho.meyering.net>
	<20070917190950.GM18444@agk.fab.redhat.com>
	<877imkfe84.fsf_-_@rho.meyering.net>
Message-ID: <20070921115330.GX18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Sep 21, 2007 at 01:30:03PM +0200, Jim Meyering wrote:
>     $ ./lvchange
>       Need 1 or more of -a, -C, -j, -m, -M, -p, -r, --resync, --refresh, --alloc, --addtag, --deltag or --monitor
>       lvchange: Run `lvchange --help' for more information.
 
So we should certainly drop the 'lvchange:' now from the second line of output.

>       lvchange: Need 1 or more of -a, -C, -j, -m, -M, -p, -r, --resync, --refresh, --alloc, --addtag, --deltag or --monitor

So should we add a new option (command_names = 2, perhaps)
that only applies it to messages produced using log_error()
rather than for all output?  [And make this the default setting.]

Or do we only want it (roughly speaking) for EINVALID_CMD_LINE not for
ECMD_FAILED?

Alasdair
-- 
agk at redhat.com



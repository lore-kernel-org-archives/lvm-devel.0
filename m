From: Jim Meyering <jim@meyering.net>
Date: Fri, 21 Sep 2007 13:49:03 +0200
Subject: revised error output: Run ... --help for more information
In-Reply-To: <20070921114356.GW18444@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Fri, 21 Sep 2007 12:43:56 +0100")
References: <878x75cuy9.fsf@rho.meyering.net>
	<20070917190950.GM18444@agk.fab.redhat.com>
	<877imkfe84.fsf_-_@rho.meyering.net>
	<20070921114356.GW18444@agk.fab.redhat.com>
Message-ID: <871wcsfdcg.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> Be aware that this is partly configurable already, but
> can still come out looking a bit of a mess.
> E.g. In lvm.conf set log { command_names = 1 prefix = ": " }

Oh!  Thanks.

It'd be nice to make that the default,
but I guess there are reasons.

All the more reason to make the new tests use their own /etc and /dev
directories.



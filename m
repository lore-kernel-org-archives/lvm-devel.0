From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 4 Jul 2014 18:22:18 +0100
Subject: master - dev-type: print log_sys_debug
In-Reply-To: <20140704103204.1476260C22@fedorahosted.org>
References: <20140704103204.1476260C22@fedorahosted.org>
Message-ID: <20140704172218.GB27805@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jul 04, 2014 at 10:32:04AM +0000, Zdenek Kabelac wrote:
> For non-fatal error use log_sys_debug as the tool
> is not stopping on these errors.

To be clear about the criteria for the different message levels:

If the code exits with an error status code there MUST have been a log_error.

But issuing a log_error does NOT mean the code must stop processing and exit.

Using log_error means "This is something the user needs to be told about".

That might include something that should never occur on a properly-functioning
system, but which if it does occur is not fatal to the continued processing
of the command.

Look at it the other way around:
  Given that the error *has* occurred, what can be deduced about the likely
  cause and does the user need to be aware of that cause in case they
  want to investigate it?

However, the cases where a log_error is non-fatal should be quite rare in the
code.

log_warn is for something that MIGHT lead to unexpected behaviour, incorrect
processing or irreversible change etc. but which MIGHT also be perfectly OK if
it was indeed the user's intention.  If there are NO circumstances where the
thing being reported is normal or expected, log_warn should NOT be used.

Alasdair



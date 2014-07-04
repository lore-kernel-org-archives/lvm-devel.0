From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 04 Jul 2014 22:15:27 +0200
Subject: master - dev-type: print log_sys_debug
In-Reply-To: <20140704172218.GB27805@agk-dp.fab.redhat.com>
References: <20140704103204.1476260C22@fedorahosted.org>
	<20140704172218.GB27805@agk-dp.fab.redhat.com>
Message-ID: <53B70B5F.9030309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 4.7.2014 19:22, Alasdair G Kergon napsal(a):
> On Fri, Jul 04, 2014 at 10:32:04AM +0000, Zdenek Kabelac wrote:
>> For non-fatal error use log_sys_debug as the tool
>> is not stopping on these errors.
>
> To be clear about the criteria for the different message levels:
>
> If the code exits with an error status code there MUST have been a log_error.
>
> But issuing a log_error does NOT mean the code must stop processing and exit.
>
> Using log_error means "This is something the user needs to be told about".
>
> That might include something that should never occur on a properly-functioning
> system, but which if it does occur is not fatal to the continued processing
> of the command.
>
> Look at it the other way around:
>    Given that the error *has* occurred, what can be deduced about the likely
>    cause and does the user need to be aware of that cause in case they
>    want to investigate it?
>
> However, the cases where a log_error is non-fatal should be quite rare in the
> code.


Then we most likely need something like

log_non_fatal_error() -

since log_error is tracked and checked if there has been error for the
reason the command has exited with error code.

If we would left log_error() as is - then 'error' usage is already marked,
and the 'real' error might not be actually printed (forgotten to be added to 
the code) - thus user could get misleading idea what's been the real reason 
for error.

(Thought in this particular case - it really looked rather like debug,
since nothing bad happens - and user could be just more confused)

Zdenek



From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 15 Mar 2013 11:30:26 -0500
Subject: [PATCH 4/5] lvm2app: Move core lv re-size code (v2)
In-Reply-To: <5142D8FD.5000107@redhat.com>
References: <1363284884-20506-1-git-send-email-tasleson@redhat.com>
	<1363284884-20506-4-git-send-email-tasleson@redhat.com>
	<5142D8FD.5000107@redhat.com>
Message-ID: <51434CA2.1040401@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/15/2013 03:17 AM, Zdenek Kabelac wrote:
> The issue is of course bigger - since the current   1/0  internal lvm
> logic doesn't support well the public API where you really want to know
> the 'reason' for failure - which ATM is just logged with log_error()
> deeply from liblvm/libdm code.
> 
> We need here some decision  -  I guess - the best would be probably to
> define
> the list of error codes we want to expose to the lvm2api users first.
> 
> Should the API user know about dm errors?
> Parameter errors ?
> Memory errors ?
> Internal errors ?

I believe the answer to all of these is yes.  If the operation cannot
succeed the user of the library is going to want to know why.  The
library interface should be more informational than the command line
interface.

As for error codes, I don't think we need to get specific with the error
codes unless the library caller can actually make a useful decision
based on that error code to execute some other code which may allow them
to succeed in the operation.

The library already has functions to return an error specific code
(lvm_errno) and error message text (lvm_errmsg).  It also appears that
the logging code already stores messages it can retrieve.

I need to look at the error logging code some more to understand what is
missing or needs to be changed.  We definitely need to make sure we
won't log to stdout/stderr when executing in the context of a library.

Regards,
-Tony



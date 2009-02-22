From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 22 Feb 2009 23:39:42 +0000
Subject: [PATCH 08/12] Add lvm_errno(), lvm_strerror, lvm_vg_mode.
In-Reply-To: <20090222231111.GF15443@agk.fab.redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-2-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-3-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-4-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-5-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-6-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-7-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-8-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-9-git-send-email-dwysocha@redhat.com>
	<20090222231111.GF15443@agk.fab.redhat.com>
Message-ID: <20090222233942.GG15443@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Feb 22, 2009 at 11:11:11PM +0000, Alasdair G Kergon wrote:
> As we discussed on the call last week, let't see first if we can get an error
> number and messages integrated into the existing log_error() reporting
> mechanism.
 
So take those as two separate problems.

(1) Add another output mechanism to print_log() to cache messages in memory.
Like the other mechanisms, the application should be able to configure what severity
of message it wants recording.
Needs a way to obtain the cached messages (returned as a single multi-line
string?) and a way to clear them (hooked automatically at the start of every
library function).

(2) Setting the library return code.
Have the level that wants to generate the error set it explicitly.
There'd be a default value that would be returned if it has not
been set to something else.  Only the first value would be returned - if
the function to set it is called a second time, that call would not
change the value.  This has the advantage that we only have to deal with
the places where it's actually useful to distinguish between different
errors - and I still don't think there are many such places.

Alasdair
-- 
agk at redhat.com



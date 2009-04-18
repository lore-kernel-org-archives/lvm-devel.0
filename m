From: Steven Dake <sdake@redhat.com>
Date: Sat, 18 Apr 2009 05:53:47 -0000
Subject: recent stabilization changes to corosync and openais API/ABIs
Message-ID: <1240034017.5808.135.camel@sdake-laptop>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

Some people on these lists may be interested to know what is happening
with Corosync and OpenAIS ABIs as well as our schedules for 1.0.

We are currently planning the following dates for our releases:
Corosync 1.0 - May 15, 2009
OpenAIS 1.0 - June 1, 2009

We have made great progress and the code is seeing good stabilization.
Over the past few weeks, our community team has sanitized the corosync
ABI and APIs.

Specifically the following types of changes were made to corosync:
* A const qualifier was added to any parameter that was a constant
buffer or struct
* Any size parameter was changed from int/unsigned int, to size_t
* Any buffer that was copied into in a calling function added a length
parameter which has a size_t type.
* All of the external headers had these changes applied as well as
coroapi.h.

No significant changes were made to the openais ABI, however, because of
changes to internal apis, we are bumping the so major version requiring
a recompile if you use the SA Forum APIs as dependencies or any corosync
APIs.

We are targeting a new release with these changes to be introduced into
distributions that ship this software in early May.

Regards
-steve




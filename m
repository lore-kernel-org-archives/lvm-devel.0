From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 2 Mar 2012 02:31:30 +0000
Subject: LVM2/tools pvremove.c
In-Reply-To: <20120301214632.14532.qmail@sourceware.org>
References: <20120301214632.14532.qmail@sourceware.org>
Message-ID: <20120302023130.GC1328@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Mar 01, 2012 at 09:46:32PM -0000, zkabelac at sourceware.org wrote:
> 	Replace goto with just log_debug
> 	FIXME: temporal quick hack to make things green
> 	There might be a better reaction.

The problem here is that this code is not distinguishing between a successful
communication with the daemon but with a reply that indicates the device is
unknown - which is an error we can ignore - and a failure in the code
trying to communicate with the daemon - which should give log_error.

The second case is more important to know about than the first so until the
code can distinguish, failing with an error should take precedence.

IOW the 'reason' the daemon gives needs checking, or else it could return
something like 'not_found' rather than 'failed' so the caller can decide
whether that's OK or not.

(Other parts of the code may need a similar change. Older LVM2 lookup code
knows that 'not found' is not necessarily an error and it depends on the
context.)

Alasdair



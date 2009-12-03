From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 3 Dec 2009 01:14:38 +0000
Subject: [PATCH] #define and use INTERNAL_ERROR
In-Reply-To: <87eine4w1y.fsf@twilight.int.mornfall.net.>
References: <87eine4w1y.fsf@twilight.int.mornfall.net.>
Message-ID: <20091203011438.GQ22702@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 01, 2009 at 03:18:33PM +0100, Peter Rockai wrote:
> patch attached to #define an INTERNAL_ERROR macro and use it throughout
> LVM. There's a couple of internal errors in libdm as well, and it seems
> that the log_error used by libdm actually comes from lib/ (i.e. LVM) so
> it may make sense to convert those as well.
 
Ack.

Each source file includes (normally via another header) either
dm-logging.h or lvm-logging.h which deals with routing the messages to
the right logging function and with the right set of parameters.  log.h
contains the part they have in common.

Alasdair



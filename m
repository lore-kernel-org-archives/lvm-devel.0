From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 7 Sep 2007 12:03:42 +0100
Subject: dev-io.c: give a better diagnostic upon failed stat
In-Reply-To: <87y7fi3gq3.fsf@rho.meyering.net>
References: <87y7fi3gq3.fsf@rho.meyering.net>
Message-ID: <20070907110342.GA2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Sep 07, 2007 at 12:36:04PM +0200, Jim Meyering wrote:
> The main change here is to report strerror(errno) upon stat failure:
> i.e., the s/log_error/log_sys_error/ part.  Also made the "device changed"
> diagnostic more definite.  Ok to commit?
 
Yes.

Alasdair


